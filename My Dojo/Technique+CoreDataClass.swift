//
//  Technique+CoreDataClass.swift
//  My Dojo
//
//  Created by Andreas Hörberg on 2016-09-20.
//  Copyright © 2016 Andreas Hörberg. All rights reserved.
//

import Foundation
import CoreData

open class Technique: NSManagedObject {
    class func techniqueWith(name: String,
                             andId unique: String,
                             for chapter: Chapter,
                             inManagedObjectContext context: NSManagedObjectContext) -> Technique? {

        if let technique = getTechnique(with: name, unique: unique, context: context) {
            return technique
        } else if let technique = techniqueWith(name: name,
                                                andId: unique,
                                                for: chapter,
                                                isWarmup: false,
                                                isAlonePractice: false,
                                                isTogetherPractice: false,
                                                inManagedObjectContext: context) {
            return technique
        }

        return nil
    }
    
    // this is an initializer that need to take many arguments
    // swiftlint:disable:next function_parameter_count
    class func techniqueWith(name: String,
                             andId unique: String,
                             for chapter: Chapter,
                             isWarmup: Bool,
                             isAlonePractice: Bool,
                             isTogetherPractice: Bool,
                             inManagedObjectContext context: NSManagedObjectContext) -> Technique? {

        if let technique = getTechnique(with: name, unique: unique, context: context) {
            return technique
        } else if let technique = NSEntityDescription.insertNewObject(forEntityName: "Technique", into: context) as? Technique {
            technique.japaneseName = name
            technique.unique = unique
            technique.chapter = chapter
            technique.isWarmup = isWarmup
            technique.isAlonePractice = isAlonePractice
            technique.isTogetherPractice = isTogetherPractice
            return technique
        }
        return nil
    }

    fileprivate class func getTechnique(with name: String, unique: String, context: NSManagedObjectContext) -> Technique? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Technique")

        request.predicate = NSPredicate(format: "japaneseName = %@ and unique = %@", name, unique)
        if let technique = (try? context.fetch(request))?.first as? Technique {
            return technique
        }
        return nil
    }

    // MARK: Selection
    // Used for keeping track of selection in Techniques Table View
    open var isSelected: Bool = false
}
