//
//  StatisticsManager.swift
//  My Dojo
//
//  Created by Andreas Hörberg on 2016-11-08.
//  Copyright © 2016 Andreas Hörberg. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class StatisticsManager: CustomStringConvertible, CustomDebugStringConvertible {
    var description: String {
        get {

            let mostPracticed: (name: String, count: Int) = getMostPracticedTechnique()!
            // description method
            // swiftlint:disable:next line_length
            return "# of trainings: \(getNumberOfTrainings()), # of trained techniques: \(getNumberOfTrainedTechniques()), current streak: \(getCurrentStreak()), most practiced technique: \(mostPracticed.name) (\(mostPracticed.count) times)"
        }
    }

    var debugDescription: String {
        get {
            let mostPracticed: (name: String, count: Int) = getMostPracticedTechnique()!
            // swiftlint:disable:next line_length
            return "# of trainings: \(getNumberOfTrainings()), # of trained techniques: \(getNumberOfTrainedTechniques()), current streak: \(getCurrentStreak()), most practiced technique: \(mostPracticed.name) (\(mostPracticed.count) times)"
        }
    }

    static let sharedInstance = StatisticsManager()

    fileprivate init() {}

    fileprivate var statistics: Statistics? {
        get {
            return Statistics.getStatistics()
        }
    }

    // MARK: - Update functions

    open func updateStatistics() {
        updateCurrentStreak()
        updateNumberOfTrainings()
        updateNumberOfTrainedTechniques()

        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
        let notification = Notification(name: .statisticsUpdatedNotification, object: self, userInfo: nil)
        NotificationCenter.default.post(notification)
    }

    fileprivate func updateNumberOfTrainings() {

        let count = 0

        if let trainingCount = try? DatabaseManager.context.count(for: NSFetchRequest<NSFetchRequestResult>(entityName:"Training")) {
            statistics?.numberOfTrainings = Int64(trainingCount)
            return
        }
        statistics?.numberOfTrainings = Int64(count)
    }

    fileprivate func updateNumberOfTrainedTechniques() {
        var count = 0
        let request = NSFetchRequest<NSFetchRequestResult>(entityName:"Training")
        request.predicate = NSPredicate(format: "ANY techniques.@count > 0")

        if let trainings = try? DatabaseManager.context.fetch(request) as? [Training] {
            for training in trainings! {
                count += training.techniques!.count
            }
            statistics?.numberOfTrainedTechniques = Int64(count)
            return
        }
        statistics?.numberOfTrainedTechniques = Int64(count)
        return
    }

    fileprivate func updateCurrentStreak() {
        var streak = 0

        let request = NSFetchRequest<NSFetchRequestResult>(entityName:"Training")
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sortDescriptor]

        if let trainings = try? DatabaseManager.context.fetch(request) as? [Training] {

            var lastTrainingWeek: Int = -1
            let streakInterval = 1 //week

            let calendar = Calendar.current

            for training in trainings! {
                let trainingDate = calendar.dateComponents([.weekOfYear], from: training.date!)
                if lastTrainingWeek > 0 {
                    if trainingDate.weekOfYear == lastTrainingWeek - streakInterval {
                        streak += 1
                        lastTrainingWeek = trainingDate.weekOfYear!
                    } else if trainingDate.weekOfYear == lastTrainingWeek {
                        continue
                    } else {
                        statistics?.currentTrainingStreak = Int64(streak)
                        return
                    }
                } else {
                    lastTrainingWeek = trainingDate.weekOfYear!
                    streak += 1
                }
            }
            statistics?.currentTrainingStreak = Int64(streak)
            return
        }
        statistics?.currentTrainingStreak = Int64(streak)
        return
    }

    // MARK: - Get functions

    open func getNumberOfTrainings() -> Int {
        return statistics != nil ? Int(statistics!.numberOfTrainings) : 0
    }
    open func getNumberOfTrainedTechniques() -> Int {
        return statistics != nil ? Int(statistics!.numberOfTrainedTechniques) : 0
    }

    open func getCurrentStreak() -> Int {
        return statistics != nil ? Int(statistics!.currentTrainingStreak) : 0
    }

    open func getMostPracticedTechnique() -> (String, Int)? {
        var mostPracticed: (name: String, count: Int)? = ("No data", 0)

        var practicedTechniques: [String : Int] = [:]

        let request = NSFetchRequest<NSFetchRequestResult>(entityName:"Training")
        
        guard let trainings = (try? DatabaseManager.context.fetch(request)) as? [Training] else { fatalError("Couldn't fetch trainings") }
        for training in trainings {
            if let techniques = training.techniques {
                for technique in techniques {
                    if let technique = technique as? Technique {
                        if practicedTechniques[technique.japaneseName!] != nil {
                            practicedTechniques[technique.japaneseName!]? += 1
                        } else {
                            practicedTechniques[technique.japaneseName!] = 1
                        }
                    }
                }
            }
        }

        for technique in practicedTechniques {
            if technique.value > mostPracticed!.count {
                mostPracticed = (technique.key, technique.value)
            }
        }

        return mostPracticed
    }
}
