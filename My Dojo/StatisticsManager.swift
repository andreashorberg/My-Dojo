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
    
    private init() {}
    
    public func getNumberOfTrainings() -> Int {
        
        let count = 0
        
        if let trainingCount = try? DatabaseManager.context.count(for: NSFetchRequest<NSFetchRequestResult>(entityName:"Training")){
            return trainingCount
        }
        return count
    }
    
    
    public func getNumberOfTrainedTechniques() -> Int {
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
    
    public func printStatistics() {
        print("\(getNumberOfTrainings()) Trainings")
        print("\(getNumberOfTrainedTechniques()) Techniques")
    }
}
