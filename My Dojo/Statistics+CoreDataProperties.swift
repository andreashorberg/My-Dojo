//
//  Statistics+CoreDataProperties.swift
//  My Dojo
//
//  Created by Andreas Hörberg on 2016-11-10.
//  Copyright © 2016 Andreas Hörberg. All rights reserved.
//

import Foundation
import CoreData

extension Statistics {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Statistics> {
        return NSFetchRequest<Statistics>(entityName: "Statistics")
    }

    @NSManaged public var currentTrainingStreak: Int64
    @NSManaged public var numberOfTrainings: Int64
    @NSManaged public var numberOfTrainedTechniques: Int64

}
