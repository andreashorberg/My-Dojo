//
//  Dojo+CoreDataProperties.swift
//  My Dojo
//
//  Created by Andreas Hörberg on 2016-10-21.
//  Copyright © 2016 Andreas Hörberg. All rights reserved.
//

import Foundation
import CoreData

extension Dojo {

    @nonobjc open override class func fetchRequest() -> NSFetchRequest<NSFetchRequestResult> {
        return NSFetchRequest<Dojo>(entityName: "Dojo") as! NSFetchRequest<NSFetchRequestResult>;
    }

    @NSManaged public var addressDictionary: NSObject?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var mapImage: NSObject?

}
