//
//  Dojo+CoreDataClass.swift
//  My Dojo
//
//  Created by Andreas Hörberg on 2016-10-02.
//  Copyright © 2016 Andreas Hörberg. All rights reserved.
//

import Foundation
import CoreData
import MapKit

open class Dojo: NSManagedObject {
    
    fileprivate var placemark: MKPlacemark? {
        get {
            return MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), addressDictionary: addressDictionary as! [String : Any]?)
        }
    }
    
    var mapItem: MKMapItem? {
        get {
            return placemark != nil ? MKMapItem(placemark: placemark!) : nil
        }
    }
    
    class func dojo(with mapItem: MKMapItem?, and mapImage: UIImage?, inManagedObjectContext context: NSManagedObjectContext) -> Dojo?
    {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Dojo")
        
        // this is when we have a dojo in the database already
        if let dojo = (try? context.fetch(request))?.first as? Dojo {
            debugPrint("Found dojo in database")
            return dojo
            // this is the case when querying the database to see if we have a saved dojo but there is none
        } else if mapItem == nil {
            return nil
            // this is the case when querying the database returned none but we have a dojo to save
            // missing in this feature is when we have a dojo and we want to select a new one
        } else if let dojo = NSEntityDescription.insertNewObject(forEntityName: "Dojo", into: context) as? Dojo {
            dojo.latitude = (mapItem?.placemark.coordinate.latitude)!
            dojo.longitude = (mapItem?.placemark.coordinate.longitude)!
            dojo.addressDictionary = mapItem?.placemark.addressDictionary as NSObject?
            dojo.mapImage = mapImage ?? nil
            debugPrint("Dojo inserted in database")
            return dojo
        }
        
        return nil
    }
    
    open func remove() {
        
        DatabaseManager.context.delete(self)
        do {
            try DatabaseManager.context.save()
        } catch {
            debugPrint(error)
            return
        }
        
        let notification = Notification(name: .dojoRemovedNotification, object: self, userInfo: nil)
        NotificationCenter.default.post(notification)
    }
    
}

extension Notification.Name
{
    static let dojoRemovedNotification = Notification.Name("dojoRemoved")
}
