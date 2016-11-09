//
//  Chapter+CoreDataProperties.swift
//  My Dojo
//
//  Created by Andreas Hörberg on 2016-10-21.
//  Copyright © 2016 Andreas Hörberg. All rights reserved.
//

import Foundation
import CoreData

extension Chapter {

    @nonobjc open override class func fetchRequest() -> NSFetchRequest<NSFetchRequestResult> {
        return NSFetchRequest<Chapter>(entityName: "Chapter") as! NSFetchRequest<NSFetchRequestResult>;
    }

    @NSManaged public var japaneseName: String?
    @NSManaged public var unique: String?
    @NSManaged public var strategyBook: StrategyBook?
    @NSManaged public var techniques: NSSet?

}

// MARK: Generated accessors for techniques
extension Chapter {

    @objc(addTechniquesObject:)
    @NSManaged public func addToTechniques(_ value: Technique)

    @objc(removeTechniquesObject:)
    @NSManaged public func removeFromTechniques(_ value: Technique)

    @objc(addTechniques:)
    @NSManaged public func addToTechniques(_ values: NSSet)

    @objc(removeTechniques:)
    @NSManaged public func removeFromTechniques(_ values: NSSet)

}
