//
//  Technique+CoreDataProperties.swift
//  My Dojo
//
//  Created by Andreas Hörberg on 2016-10-21.
//  Copyright © 2016 Andreas Hörberg. All rights reserved.
//

import Foundation
import CoreData

extension Technique {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Technique> {
        return NSFetchRequest<Technique>(entityName: "Technique");
    }

    @NSManaged public var isAlonePractice: Bool
    @NSManaged public var isTogetherPractice: Bool
    @NSManaged public var isWarmup: Bool
    @NSManaged public var japaneseName: String?
    @NSManaged public var unique: String?
    @NSManaged public var chapter: Chapter?

}
