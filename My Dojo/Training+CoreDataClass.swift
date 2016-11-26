//
//  Training+CoreDataClass.swift
//  My Dojo
//
//  Created by Andreas Hörberg on 2016-11-03.
//  Copyright © 2016 Andreas Hörberg. All rights reserved.
//

import Foundation
import CoreData

open class Training: NSManagedObject {
    class func createTraining(at date: String, journal: String, inManagedObjectContext context: NSManagedObjectContext) -> Training? {
        if let training = NSEntityDescription.insertNewObject(forEntityName: "Training", into: context) as? Training {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            dateFormatter.timeZone = TimeZone.current
                        
            training.date =  dateFormatter.date(from: date)!
            training.journal = journal
            training.unique = UUID.init().uuidString
            
            return training
        }
        return nil
    }
    
    override open func didSave() {
        super.didSave()
        
        let notification = Notification(name: .newTrainingCreatedNotification, object: self, userInfo: nil)
        NotificationCenter.default.post(notification)
    }
}
