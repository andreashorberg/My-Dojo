//
//  MenuItem+CoreDataClass.swift
//  My Dojo
//
//  Created by Andreas Hörberg on 2016-10-26.
//  Copyright © 2016 Andreas Hörberg. All rights reserved.
//

import Foundation
import CoreData


public class MenuItem: NSManagedObject {
    class func menuItem(with title: String, id: String, action: String, imageAsset: String, sortOrder: Int, reusableIdentifier: String, for menu: Menu, inManagedObjectContext context: NSManagedObjectContext) -> MenuItem?
    {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "MenuItem")
        request.predicate = NSPredicate(format: "title = %@ and unique = %@", title, id)
        
        if let menuItem = (try? context.fetch(request))?.first as? MenuItem {
            print("MenuItem \(title) from menu \(menuItem.menu?.name) found in database")
            return menuItem
        } else if let menuItem = NSEntityDescription.insertNewObject(forEntityName: "MenuItem", into: context) as? MenuItem {
            menuItem.title = title
            menuItem.unique = id
            menuItem.action = action
            menuItem.imageAsset = imageAsset
            menuItem.sortOrder = Int64(sortOrder)
            menuItem.reusableIdentifier = reusableIdentifier
            menuItem.menu = menu
            print("\(id) MenuItem \(title) from menu \(menuItem.menu?.name) inserted in database")
            return menuItem
        }
        
        return nil
    }
}
