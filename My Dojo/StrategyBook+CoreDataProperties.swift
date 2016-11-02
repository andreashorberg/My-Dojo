//
//  StrategyBook+CoreDataProperties.swift
//  My Dojo
//
//  Created by Andreas Hörberg on 2016-10-21.
//  Copyright © 2016 Andreas Hörberg. All rights reserved.
//

import Foundation
import CoreData

extension StrategyBook {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StrategyBook> {
        return NSFetchRequest<StrategyBook>(entityName: "StrategyBook");
    }

    @NSManaged public var japaneseName: String?
    @NSManaged public var unique: String?
    @NSManaged public var chapters: NSSet?

}

// MARK: Generated accessors for chapters
extension StrategyBook {

    @objc(addChaptersObject:)
    @NSManaged public func addToChapters(_ value: Chapter)

    @objc(removeChaptersObject:)
    @NSManaged public func removeFromChapters(_ value: Chapter)

    @objc(addChapters:)
    @NSManaged public func addToChapters(_ values: NSSet)

    @objc(removeChapters:)
    @NSManaged public func removeFromChapters(_ values: NSSet)

}
