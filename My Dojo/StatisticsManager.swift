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

class StatisticsManager : CustomStringConvertible, CustomDebugStringConvertible {
    var description: String {
        get {
            return "# of trainings: \(getNumberOfTrainings()), # of trained techniques: \(getNumberOfTrainedTechniques()), current streak: \(getCurrentStreak())"
        }
    }
    
    var debugDescription: String {
        get {
            return "# of trainings: \(getNumberOfTrainings()), # of trained techniques: \(getNumberOfTrainedTechniques()), current streak: \(getCurrentStreak()), statistics: \(statistics)"
        }
    }
    
    static let sharedInstance = StatisticsManager()
    
    fileprivate init() {}
    
    fileprivate var _statistics = Statistics.getStatistics()
    fileprivate var statistics: Statistics? {
        get {
            return _statistics
        }
    }
    
    open func updateStatistics() {
        updateCurrentStreak()
        updateNumberOfTrainings()
        updateNumberOfTrainedTechniques()
        
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
        
//        printStatistics()
    }
    
    fileprivate func updateNumberOfTrainings() {
        
        let count = 0
        
        if let trainingCount = try? DatabaseManager.context.count(for: NSFetchRequest<NSFetchRequestResult>(entityName:"Training")){
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
                if lastTrainingWeek > 0  {
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
    
    open func getNumberOfTrainings() -> Int {
        return statistics != nil ? Int(statistics!.numberOfTrainings) : 0
    }
    open func getNumberOfTrainedTechniques() -> Int {
        return statistics != nil ? Int(statistics!.numberOfTrainedTechniques) : 0
    }
    
    open func getCurrentStreak() -> Int {
        return statistics != nil ? Int(statistics!.currentTrainingStreak) : 0
    }
    
    /*open func printStatistics() {
        print("\(getNumberOfTrainings()) Trainings")
        print("\(getNumberOfTrainedTechniques()) Techniques")
        print("\(getCurrentStreak()) Current streak")
    }*/
}
