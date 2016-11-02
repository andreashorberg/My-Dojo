//
//  Technique+CoreDataClass.swift
//  My Dojo
//
//  Created by Andreas Hörberg on 2016-09-20.
//  Copyright © 2016 Andreas Hörberg. All rights reserved.
//

import Foundation
import CoreData


public class Technique: NSManagedObject {
    class func techniqueWithName(name: String, andId id: String, for chapter: Chapter, inManagedObjectContext context: NSManagedObjectContext) -> Technique?
    {
        
        if let technique = getTechnique(with: name, id: id, context: context) {
            return technique
        } else if let technique = techniqueWithName(name: name, andId: id, for: chapter, isWarmup: false, isAlonePractice: false, isTogetherPractice: false, inManagedObjectContext: context) {
            debugPrint("\(id) Technique \(name) from chapter \(technique.chapter?.japaneseName!) and strategybook \(technique.chapter?.strategyBook?.japaneseName) inserted in database")
            return technique
        }
        
        return nil
    }
    
    class func techniqueWithName(name: String, andId id: String, for chapter: Chapter, isWarmup: Bool, isAlonePractice: Bool, isTogetherPractice: Bool, inManagedObjectContext context: NSManagedObjectContext) -> Technique? {
        
        if let technique = getTechnique(with: name, id: id, context: context) {
            return technique
        } else if let technique = NSEntityDescription.insertNewObject(forEntityName: "Technique", into: context) as? Technique {
            technique.japaneseName = name
            technique.unique = id
            technique.chapter = chapter
            technique.isWarmup = isWarmup
            technique.isAlonePractice = isAlonePractice
            technique.isTogetherPractice = isTogetherPractice
            return technique
        }
        return nil
    }
    
    private class func getTechnique(with name: String, id: String, context: NSManagedObjectContext) -> Technique? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Technique")
        
        request.predicate = NSPredicate(format: "japaneseName = %@ and unique = %@", name, id)
        if let technique = (try? context.fetch(request))?.first as? Technique {
            debugPrint("Technique \(name) from chapter \(technique.chapter?.japaneseName) and strategybook \(technique.chapter?.strategyBook?.japaneseName) found in database")
            return technique
        }
        return nil
    }
    
    // MARK: Selection
    // Used for keeping track of selection in Techniques Table View
    public var isSelected: Bool = false
}
