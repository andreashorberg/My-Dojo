//
//  Statistics+CoreDataClass.swift
//  My Dojo
//
//  Created by Andreas Hörberg on 2016-11-09.
//  Copyright © 2016 Andreas Hörberg. All rights reserved.
//

import Foundation
import CoreData

public class Statistics: NSManagedObject {
    class func getStatistics() -> Statistics? {
        let context = DatabaseManager.context
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Statistics")
        
        if let statistics = (try? context.fetch(request))?.first as? Statistics {
            return statistics
        } else if let statistics = NSEntityDescription.insertNewObject(forEntityName: "Statistics", into: context) as? Statistics {
            
            statistics.currentTrainingStreak = 0
            statistics.numberOfTrainings = 0
            statistics.numberOfTrainedTechniques = 0
            
            return statistics
        }
        return nil
    }
}
