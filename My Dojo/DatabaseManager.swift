//
//  DatabaseManager.swift
//  My Dojo
//
//  Created by Andreas Hörberg on 2016-09-28.
//  Copyright © 2016 Andreas Hörberg. All rights reserved.
//

import Foundation
import CoreData
import MapKit

class DatabaseManager {
    
    static var context: NSManagedObjectContext {
        get {
            return (UIApplication.shared.delegate as? AppDelegate)!.persistentContainer.viewContext
        }
    }
    
    open static func populateDatabase(with propertyList: Any?) {
        let plist = propertyList
        
        context.perform {
            
            var strategyBooks: [StrategyBook] = []
            var chapters: [Chapter] = []
            
            for array in (plist as? [String : Any])!
            {
                switch array.key
                {
                case "Strategy Books":
                    for book in (array.value as? [[String : String]])!
                    {
                        var name: String?
                        var unique: String?
                        
                        for item in book
                        {
                            switch item.key {
                            case "japaneseName": name = item.value
                            case "unique": unique = item.value
                            default: break
                            }
                        }
                        if let newStrategyBook = StrategyBook.strategyBook(withName: name!, andId: unique!, inManagedObjectContext: context) {
                            strategyBooks.insert(newStrategyBook, at: Int(newStrategyBook.unique!)!)
                        }
                    }
                    break
                case "Chapters":
                    for chapter in (array.value as? [[String : Any]])!
                    {
                        var name: String?
                        var unique: String?
                        var strategyBook: Int?
                        
                        for item in chapter {
                            switch item.key {
                            case "japaneseName": name = item.value as? String
                            case "unique": unique = item.value as? String
                            case "strategyBook": strategyBook = item.value as? Int
                            default: break
                            }
                        }
                        if let newChapter = Chapter.chapterWithName(name!, andId: unique!, for: strategyBooks[strategyBook!], inManagedObjectContext: context) {
                            chapters.insert(newChapter, at: Int(unique!)!)
                        }
                    }
                    break
                case "Techniques":
                    for technique in (array.value as? [[String : Any]])!
                    {
                        var name: String?
                        var unique: String?
                        var chapter: Int?
                        
                        for item in technique {
                            switch item.key {
                            case "japaneseName": name = item.value as? String
                            case "unique": unique = item.value as? String
                            case "chapter": chapter = item.value as? Int
                            default: break
                            }
                        }
                        guard let _ = Technique.techniqueWith(name: name!, andId: unique!, for: chapters[chapter!], inManagedObjectContext: context) else { return }
                    }
                    break
                default: debugPrint("I dont know"); break
                }
            }
            
            do {
                try context.save()
                debugPrint ("Context saved")
            } catch let error {
                debugPrint ("Core Data Error: \(error)")
            }
        }
    }
    
    open static func populateDatabase(with jsonUrl: URL, and context:NSManagedObjectContext)
    {
        var 🛠_TODO_IMPLEMENT: Any?
    }
    
    open static func read(propertyList name: String) {
        
        var data: Data?
        var plist: Any?
        
        if let path = Bundle.main.path(forResource: name, ofType: "plist")
        {
            let url = URL(fileURLWithPath: path)
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    data = try Data(contentsOf: url)
                    
                    plist = try PropertyListSerialization.propertyList(from: data!, options: .mutableContainersAndLeaves, format: nil)
                } catch {
                    debugPrint ("Error reading plist: \(error)")
                }
                
                let notification = Notification(name: .plistReadNotification, object: self, userInfo: ["plist" : plist!, "name": name])
                NotificationCenter.default.post(notification)
            }
        } else {
            debugPrint("Couldn't read plist: \(name)")
        }
        debugPrint("Finished loading plist from string")
    }
    
    public static func save(dojo: MKMapItem?, mapImage: UIImage?)
    {
        context.perform {
            guard let _ = Dojo.dojo(with: dojo, and: mapImage, inManagedObjectContext: context) else { debugPrint("Couldn't create Dojo object"); return }
            do {
                try context.save()
            } catch {
                debugPrint ("Error saving dojo: \(error)")
            }
        }
    }
    

//    static let restoreDojoNotification = "restoreDojoNotification"
    
    public static func getDojo(from sender: Any?)
    {
        context.perform {
            if let dojo = Dojo.dojo(with: nil, and: nil, inManagedObjectContext: context)
            {
                // notify anyone who might be interested in dojo restored notifications
                let notification = Notification(name: .getDojoNotification, object: self, userInfo: ["dojo" : dojo, "sender": sender!])
                NotificationCenter.default.post(notification)
            } else {
                let notification = Notification(name: .getDojoNotification, object: self, userInfo: ["sender": sender!])
                NotificationCenter.default.post(notification)
            }
        }
    }
    
    public static func createMainMenu()
    {
        let menuTitle = "Main Menu"
        let menuId = "0"
        guard let menu = Menu.menu(withName: menuTitle, andId: menuId, inManagedObjectContext: context) else {
            print("Couldn't create Main Menu")
            return
        }
        
        guard let _ = MenuItem.menuItem(with: "Techniques", id: "0", action: "Techniques Table", imageAsset: "Techniques Button", sortOrder: 0, reusableIdentifier: "Small Tile", for: menu, inManagedObjectContext: DatabaseManager.context) else {
            print("Couldn't create techniques menu item")
            return
        }
        
        guard let _ = MenuItem.menuItem(with: "New Training", id: "1", action: "New Training", imageAsset: "New Training Button", sortOrder: 1, reusableIdentifier: "Small Tile", for: menu, inManagedObjectContext: DatabaseManager.context) else {
            print("Couldn't create new training menu item")
            return
        }
        
        guard let _ = MenuItem.menuItem(with: "My Dojo", id: "2", action: "Selected Dojo", imageAsset: "Dojo", sortOrder: 2, reusableIdentifier: "Large Tile", for: menu, inManagedObjectContext: DatabaseManager.context) else {
            print("Couldn't create my dojo menu item")
            return
        }
    }
    
    public static func getMainMenu(from sender: Any?)
    {
        context.perform{
            if let mainMenu = Menu.menu(withName: "Main Menu", andId: "0", inManagedObjectContext: context)
            {
                // notify anyone who might be interested in menu restored notifications
                let notification = Notification(name: .getMainMenuNotification, object: self, userInfo: ["menu" : mainMenu, "sender": sender!])
                NotificationCenter.default.post(notification)
            } else {
                let notification = Notification(name: .getMainMenuNotification, object: self, userInfo: ["sender": sender!])
                NotificationCenter.default.post(notification)
            }
        }
    }
}

