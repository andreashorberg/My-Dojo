//
//  Menu+CoreDataProperties.swift
//  My Dojo
//
//  Created by Andreas Hörberg on 2016-10-26.
//  Copyright © 2016 Andreas Hörberg. All rights reserved.
//

import Foundation
import CoreData 

extension Menu {

    @nonobjc open override class func fetchRequest() -> NSFetchRequest<NSFetchRequestResult> {
        return NSFetchRequest<Menu>(entityName: "Menu") as! NSFetchRequest<NSFetchRequestResult>;
    }

    @NSManaged public var name: String?
    @NSManaged public var unique: String?
    @NSManaged public var menuItems: NSSet?

}

// MARK: Generated accessors for menuItems
extension Menu {

    @objc(addMenuItemsObject:)
    @NSManaged public func addToMenuItems(_ value: MenuItem)

    @objc(removeMenuItemsObject:)
    @NSManaged public func removeFromMenuItems(_ value: MenuItem)

    @objc(addMenuItems:)
    @NSManaged public func addToMenuItems(_ values: NSSet)

    @objc(removeMenuItems:)
    @NSManaged public func removeFromMenuItems(_ values: NSSet)

}
