//
//  StatisticsManager.swift
//  My Dojo
//
//  Created by Andreas Hörberg on 2016-11-08.
//  Copyright © 2016 Andreas Hörberg. All rights reserved.
//

import Foundation
import CoreData

class StatisticsManager {
    static let sharedInstance = StatisticsManager()
    
    fileprivate init() {}
    
    open func getNumberOfTrainings() -> Int {
        
        let count = 0
        
        if let trainingCount = try? DatabaseManager.context.count(for: NSFetchRequest<NSFetchRequestResult>(entityName:"Training")){
            return trainingCount
        }
        return count
    }
    
    
    open func getNumberOfTrainedTechniques() -> Int {
        var count = 0
        let request = NSFetchRequest<NSFetchRequestResult>(entityName:"Training")
        request.predicate = NSPredicate(format: "ANY techniques.@count > 0")
        
        if let trainings = try? DatabaseManager.context.fetch(request) as? [Training] {
            for training in trainings! {
                count += training.techniques!.count
            }
            return count
        }
        return 0
    }
    
    open func updateCurrentStreak(with training: Training) -> Int {
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
                        return streak
                    }
                } else {
                    lastTrainingWeek = trainingDate.weekOfYear!
                    streak += 1
                }
            }
            return streak
        }
        
        return streak
    }
    
    open func printStatistics() {
        print("\(getNumberOfTrainings()) Trainings")
        print("\(getNumberOfTrainedTechniques()) Techniques")
       // print("\(getCurrentStreak()) Current streak")
    }
}
