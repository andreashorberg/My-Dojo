//
//  Menu+CoreDataClass.swift
//  My Dojo
//
//  Created by Andreas Hörberg on 2016-10-26.
//  Copyright © 2016 Andreas Hörberg. All rights reserved.
//

import Foundation
import CoreData


open class Menu: NSManagedObject {
    class func menu(withName name: String, andId id: String, inManagedObjectContext context: NSManagedObjectContext) -> Menu?
    {
        let request = NSFetchRequest<Menu>(entityName: "Menu")
        request.predicate = NSPredicate(format: "name = %@ and unique = %@", name, id)
        
        if let menu = (try? context.fetch(request as! NSFetchRequest<NSFetchRequestResult>))?.first as? Menu {
            print("Menu \(name) found in database")
            return menu
        } else if let menu = NSEntityDescription.insertNewObject(forEntityName: "Menu", into: context) as? Menu {
            menu.name = name
            menu.unique = id
            print("\(id) Menu \(name) inserted in database")
            return menu
        }
        
        return nil
    }
    
    open func getMenuItem(at index: Int) -> MenuItem?
    {
        if let menuItems = self.menuItems?.allObjects as? [MenuItem] {
            for item: MenuItem in menuItems {
                if Int(item.sortOrder) == index {
                    return item
                }
            }
        }
        return nil
    }
}
