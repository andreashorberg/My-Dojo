//
//  Training+CoreDataClass.swift
//  My Dojo
//
//  Created by Andreas Hörberg on 2016-11-03.
//  Copyright © 2016 Andreas Hörberg. All rights reserved.
//

import Foundation
import CoreData


public class Training: NSManagedObject {
    class func createTraining(at date: String, journal: String, inManagedObjectContext context: NSManagedObjectContext) -> Training? {
        if let training = NSEntityDescription.insertNewObject(forEntityName: "Training", into: context) as? Training {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            dateFormatter.timeZone = NSTimeZone.local
            
            training.date = dateFormatter.date(from: date) as NSDate?
            training.journal = journal
            training.unique = NSUUID.init().uuidString
            
            return training
        }
        return nil
    }
}
