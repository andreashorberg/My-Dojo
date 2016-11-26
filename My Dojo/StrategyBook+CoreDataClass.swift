//
//  StrategyBook+CoreDataClass.swift
//  My Dojo
//
//  Created by Andreas Hörberg on 2016-09-20.
//  Copyright © 2016 Andreas Hörberg. All rights reserved.
//

import Foundation
import CoreData

open class StrategyBook: NSManagedObject {

    class func strategyBook(withName name: String, andId unique: String, inManagedObjectContext context: NSManagedObjectContext) -> StrategyBook? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "StrategyBook")
        request.predicate = NSPredicate(format: "japaneseName = %@ and unique = %@", name, unique)
        
        if let strategyBook = (try? context.fetch(request))?.first as? StrategyBook {
            return strategyBook
        } else if let strategyBook = NSEntityDescription.insertNewObject(forEntityName: "StrategyBook", into: context) as? StrategyBook {
            strategyBook.japaneseName = name
            strategyBook.unique = unique

            return strategyBook
        }
        
        return nil
    }
    
}
