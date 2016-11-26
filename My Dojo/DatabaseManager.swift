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

    public static var context: NSManagedObjectContext {
        get {
            return (UIApplication.shared.delegate as? AppDelegate)!.persistentContainer.viewContext
        }
    }

    fileprivate static var strategyBooks: [StrategyBook] = []
    fileprivate static var chapters: [Chapter] = []
    
    fileprivate static func parseStrategyBooks(with array: [[String : String]]) {
        for book in array {
            guard
                let name: String = book["japaneseName"],
                let unique: String = book["unique"],
                let index: Int = Int(unique)
                else { fatalError("Wrong parameters for books") }
            if let newStrategyBook = StrategyBook.strategyBook(withName: name, andId: unique, inManagedObjectContext: context) {
                strategyBooks.insert(newStrategyBook, at: index)
            } else { fatalError("Couldn't create Strategybook") }
        }
    }
    
    fileprivate static func parseChapters(with array: [[String : Any]]) {
        for chapter in array {
            guard
                let name: String = chapter["japaneseName"] as? String,
                let unique: String = chapter["unique"] as? String,
                let index = Int(unique),
                let strategyBook: Int = chapter["strategyBook"] as? Int
                else { fatalError("Wrong parameters for chapters") }
            
            if let newChapter = Chapter.chapterWithName(name,
                                                        andId: unique,
                                                        for: strategyBooks[strategyBook],
                                                        inManagedObjectContext: context) {
                chapters.insert(newChapter, at: index)
            }
        }
    }
    
    fileprivate static func parseTechniques(with array: [[String : Any]]) {
        for technique in array {
            guard
                let name: String = technique["japaneseName"] as? String,
                let unique: String = technique["unique"] as? String,
                let chapter: Int = technique["chapter"] as? Int
                else { fatalError("Wrong parameters for techniques") }
            guard let _ = Technique.techniqueWith(name: name, andId: unique, for: chapters[chapter], inManagedObjectContext: context)
                else { return }
        }
    }
    
    open static func populateDatabase(with propertyList: Any?) {
        guard let plist = propertyList as? [String : Any] else { fatalError("Wrong format for techniques propertyList") }

        context.perform {
            
            for array in plist {
                switch array.key {
                case "Strategy Books":
                    guard let bookArray = array.value as? [[String : String]] else { fatalError("Wrong format for books") }
                    parseStrategyBooks(with: bookArray)
                    break
                    
                case "Chapters":
                    guard let chapterArray = array.value as? [[String : Any]] else { fatalError("Wrong format for chapters") }
                    parseChapters(with: chapterArray)
                    
                    break
                case "Techniques":
                    guard let techniqueArray = array.value as? [[String : Any]] else { fatalError("Wrong format for techniques") }
                    parseTechniques(with: techniqueArray)
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

    open static func populateDatabase(with jsonUrl: URL, and context: NSManagedObjectContext) {
        var 🛠_TODO_IMPLEMENT: Any?
    }

    open static func read(propertyList name: String) {

        var data: Data?
        var plist: Any?

        if let path = Bundle.main.path(forResource: name, ofType: "plist") {
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

    public static func save(dojo: MKMapItem?, mapImage: UIImage?) {
        context.perform {
            guard let _ = Dojo.dojo(with: dojo, and: mapImage, inManagedObjectContext: context) else { fatalError("Couldn't create Dojo object") }
            do {
                try context.save()
            } catch {
                debugPrint ("Error saving dojo: \(error)")
            }
        }
    }

//    static let restoreDojoNotification = "restoreDojoNotification"

    public static func getDojo(from sender: Any?) {
        context.perform {
            if let dojo = Dojo.dojo(with: nil, and: nil, inManagedObjectContext: context) {
                // notify anyone who might be interested in dojo restored notifications
                let notification = Notification(name: .getDojoNotification, object: self, userInfo: ["dojo" : dojo, "sender": sender!])
                NotificationCenter.default.post(notification)
            } else {
                let notification = Notification(name: .getDojoNotification, object: self, userInfo: ["sender": sender!])
                NotificationCenter.default.post(notification)
            }
        }
    }

    public static func createMainMenu() {
        let menuTitle = "Main Menu"
        let menuId = "0"
        guard let menu = Menu.menu(withName: menuTitle, andId: menuId, inManagedObjectContext: context) else {
            print("Couldn't create Main Menu")
            return
        }

        guard let _ = MenuItem.menuItem(with: "Techniques",
                                        unique: "0",
                                        action: "Techniques Table",
                                        imageAsset: "Techniques Button",
                                        sortOrder: 2,
                                        reusableIdentifier: "Small Tile",
                                        for: menu,
                                        inManagedObjectContext: DatabaseManager.context) else {
            print("Couldn't create techniques menu item")
            return
        }

        guard let _ = MenuItem.menuItem(with: "New Training",
                                        unique: "1",
                                        action: "New Training",
                                        imageAsset: "New Training Button",
                                        sortOrder: 3,
                                        reusableIdentifier: "Small Tile",
                                        for: menu,
                                        inManagedObjectContext: DatabaseManager.context) else {
            print("Couldn't create new training menu item")
            return
        }

        guard let _ = MenuItem.menuItem(with: "My Dojo",
                                        unique: "2",
                                        action: "Selected Dojo",
                                        imageAsset: "Dojo",
                                        sortOrder: 4,
                                        reusableIdentifier: "Large Tile",
                                        for: menu,
                                        inManagedObjectContext: DatabaseManager.context) else {
            print("Couldn't create my dojo menu item")
            return
        }

        guard let _ = MenuItem.menuItem(with: "Progress",
                                        unique: "3",
                                        action: "Progress",
                                        imageAsset: "Progress Button",
                                        sortOrder: 0,
                                        reusableIdentifier: "Small Tile",
                                        for: menu,
                                        inManagedObjectContext: DatabaseManager.context) else {
            print("Couldn't create progress menu item")
            return
        }

        guard let _ = MenuItem.menuItem(with: "Suggest training",
                                        unique: "4",
                                        action: "Suggest Training",
                                        imageAsset: "Suggest Button",
                                        sortOrder: 1,
                                        reusableIdentifier: "Small Tile",
                                        for: menu,
                                        inManagedObjectContext: DatabaseManager.context) else {
            print("Couldn't create progress menu item")
            return
        }
    }

    public static func getMainMenu(from sender: Any?) {
        context.perform {
            if let mainMenu = Menu.menu(withName: "Main Menu", andId: "0", inManagedObjectContext: context) {
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
