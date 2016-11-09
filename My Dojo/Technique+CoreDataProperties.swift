//
//  Technique+CoreDataProperties.swift
//  My Dojo
//
//  Created by Andreas Hörberg on 2016-11-03.
//  Copyright © 2016 Andreas Hörberg. All rights reserved.
//

import Foundation
import CoreData


extension Technique {

    @nonobjc open override class func fetchRequest() -> NSFetchRequest<NSFetchRequestResult> {
        return NSFetchRequest<Technique>(entityName: "Technique") as! NSFetchRequest<NSFetchRequestResult>;
    }

    @NSManaged public var isAlonePractice: Bool
    @NSManaged public var isTogetherPractice: Bool
    @NSManaged public var isWarmup: Bool
    @NSManaged public var japaneseName: String?
    @NSManaged public var unique: String?
    @NSManaged public var chapter: Chapter?
    @NSManaged public var trainings: NSSet?

}

// MARK: Generated accessors for trainings
extension Technique {

    @objc(addTrainingsObject:)
    @NSManaged public func addToTrainings(_ value: Training)

    @objc(removeTrainingsObject:)
    @NSManaged public func removeFromTrainings(_ value: Training)

    @objc(addTrainings:)
    @NSManaged public func addToTrainings(_ values: NSSet)

    @objc(removeTrainings:)
    @NSManaged public func removeFromTrainings(_ values: NSSet)

}
