//
//  Chapter+CoreDataClass.swift
//  My Dojo
//
//  Created by Andreas Hörberg on 2016-09-20.
//  Copyright © 2016 Andreas Hörberg. All rights reserved.
//

import Foundation
import CoreData

open class Chapter: NSManagedObject {
    class func chapterWithName(_ name: String,
                               andId unique: String,
                               for book: StrategyBook,
                               inManagedObjectContext context: NSManagedObjectContext) -> Chapter? {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Chapter")
        request.predicate = NSPredicate(format: "japaneseName = %@ and unique = %@", name, unique )

        if let chapter = (try? context.fetch(request))?.first as? Chapter {
            return chapter
        } else if let chapter = NSEntityDescription.insertNewObject(forEntityName: "Chapter", into: context) as? Chapter {
            chapter.japaneseName = name
            chapter.unique = unique 
            chapter.strategyBook = book
            return chapter
        }

        return nil
    }
}
