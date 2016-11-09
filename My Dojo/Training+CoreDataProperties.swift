//
//  Training+CoreDataProperties.swift
//  My Dojo
//
//  Created by Andreas Hörberg on 2016-11-03.
//  Copyright © 2016 Andreas Hörberg. All rights reserved.
//

import Foundation
import CoreData


extension Training {

    @nonobjc open override class func fetchRequest() -> NSFetchRequest<NSFetchRequestResult> {
        return NSFetchRequest<Training>(entityName: "Training") as! NSFetchRequest<NSFetchRequestResult>;
    }

    @NSManaged public var date: Date?
    @NSManaged public var journal: String?
    @NSManaged public var unique: String?
    @NSManaged public var techniques: NSSet?

}

// MARK: Generated accessors for techniques
extension Training {

    @objc(addTechniquesObject:)
    @NSManaged public func addToTechniques(_ value: Technique)

    @objc(removeTechniquesObject:)
    @NSManaged public func removeFromTechniques(_ value: Technique)

    @objc(addTechniques:)
    @NSManaged public func addToTechniques(_ values: NSSet)

    @objc(removeTechniques:)
    @NSManaged public func removeFromTechniques(_ values: NSSet)

}
