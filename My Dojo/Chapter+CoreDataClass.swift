//
//  Chapter+CoreDataClass.swift
//  My Dojo
//
//  Created by Andreas Hörberg on 2016-09-20.
//  Copyright © 2016 Andreas Hörberg. All rights reserved.
//

import Foundation
import CoreData


public class Chapter: NSManagedObject {
    class func chapterWithName(name: String, andId id: String, for strategyBook: StrategyBook, inManagedObjectContext context: NSManagedObjectContext) -> Chapter?
    {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Chapter")
        request.predicate = NSPredicate(format: "japaneseName = %@ and unique = %@", name, id)
        
        if let chapter = (try? context.fetch(request))?.first as? Chapter {
            print("Chapter \(name) from strategy book \(chapter.strategyBook?.japaneseName) found in database")
            return chapter
        } else if let chapter = NSEntityDescription.insertNewObject(forEntityName: "Chapter", into: context) as? Chapter {
            chapter.japaneseName = name
            chapter.unique = id
            chapter.strategyBook = strategyBook
            print("\(id) Chapter \(name) from strategy book \(chapter.strategyBook?.japaneseName) inserted in database")
            return chapter
        }
        
        return nil
    }
}
