//
//  MenuItem+CoreDataProperties.swift
//  My Dojo
//
//  Created by Andreas Hörberg on 2016-10-31.
//  Copyright © 2016 Andreas Hörberg. All rights reserved.
//

import Foundation
import CoreData


extension MenuItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MenuItem> {
        return NSFetchRequest<MenuItem>(entityName: "MenuItem");
    }

    @NSManaged public var imageAsset: String?
    @NSManaged public var reusableIdentifier: String?
    @NSManaged public var action: String?
    @NSManaged public var sortOrder: Int64
    @NSManaged public var title: String?
    @NSManaged public var unique: String?
    @NSManaged public var menu: Menu?

}
