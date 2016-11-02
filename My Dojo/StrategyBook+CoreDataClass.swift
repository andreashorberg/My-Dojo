//
//  StrategyBook+CoreDataClass.swift
//  My Dojo
//
//  Created by Andreas Hörberg on 2016-09-20.
//  Copyright © 2016 Andreas Hörberg. All rights reserved.
//

import Foundation
import CoreData


public class StrategyBook: NSManagedObject {

    class func strategyBook(withName name: String, andId id: String, inManagedObjectContext context: NSManagedObjectContext) -> StrategyBook?
    {
        let request = NSFetchRequest<StrategyBook>(entityName: "StrategyBook")
        request.predicate = NSPredicate(format: "japaneseName = %@ and unique = %@", name, id)
        
        if let strategyBook = (try? context.fetch(request as! NSFetchRequest<NSFetchRequestResult>))?.first as? StrategyBook {
            print("Strategybook \(name) found in database")
            return strategyBook
        } else if let strategyBook = NSEntityDescription.insertNewObject(forEntityName: "StrategyBook", into: context) as? StrategyBook {
            strategyBook.japaneseName = name
            strategyBook.unique = id
            print("\(id) Strategybook \(name) inserted in database")
            return strategyBook
        }
        
        return nil
    }
    
}
