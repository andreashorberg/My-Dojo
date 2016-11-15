//
//  SelectedDojoViewController.swift
//  My Dojo
//
//  Created by Andreas Hörberg on 2016-10-02.
//  Copyright © 2016 Andreas Hörberg. All rights reserved.
//

import UIKit
import MapKit

class SelectedDojoViewController: UIViewController {

    open var myDojo: Dojo?
    fileprivate var areYouSure: UIAlertController?
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func changeDojoAction(_ sender: AnyObject) {
        areYouSure = UIAlertController.init(title: Constants.areYouSureTitle, message: Constants.areYouSureMessage, preferredStyle: .alert)
        
        let okAction = UIAlertAction.init(title: Constants.okTitle, style: .default) { Void in
            self.myDojo!.remove()
        }
        
        let cancelAction = UIAlertAction.init(title: Constants.cancelTitle, style: .cancel) { [unowned self] _ in
            self.areYouSure?.dismiss(animated: true, completion: nil)
        }
        
        areYouSure?.addAction(okAction)
        areYouSure?.addAction(cancelAction)
        
        self.present(areYouSure!, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addNotificationObservers()
        DispatchQueue.main.async { [unowned self] in
            self.prepareMapView()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeNotificationObservers()
    }
    
    fileprivate func prepareMapView()
    {
        guard let dojo = myDojo else { return }
        guard let placemark = dojo.mapItem?.placemark else { return }
        
        mapView.removeAnnotations(mapView.annotations)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality, let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        
        mapView.addAnnotation(annotation)
        
        let span = MKCoordinateSpanMake(Constants.zoomLevelLatitude, Constants.zoomLevelLongitude)
        let region = MKCoordinateRegion(center: (dojo.mapItem?.placemark.location?.coordinate)!, span: span)
        mapView.setRegion(region, animated: true)
        
        mapView.selectAnnotation(annotation, animated: true)
    }
    
    // MARK: - Notifications
    var notificationObservers: [NSObjectProtocol?] = []
    var notificationCenter: NotificationCenter {
        get {
            return NotificationCenter.default
        }
    }
}

extension SelectedDojoViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let reuseID = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
        pinView?.pinTintColor = UIColor.orange
        pinView?.canShowCallout = true
        
        let button = UIButton.init(type: .contactAdd)
        button.addTarget(self, action: #selector(getDirections), for: .touchUpInside)
        pinView?.rightCalloutAccessoryView = button
        return pinView
    }
    
    func getDirections(){
        if let mapItem = myDojo?.mapItem {
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOptions)
        }
    }
}

extension SelectedDojoViewController : ListensForNotifications {
    func addNotificationObservers() {
        let dojoRemovedObserver: NSObjectProtocol? = notificationCenter.addObserver(forName: .dojoRemovedNotification, object: nil, queue: OperationQueue.main) { [unowned self] _ in
            self.performSegue(withIdentifier: Constants.unwindToMainSeuge, sender: self)
        }
        notificationObservers.append(dojoRemovedObserver)
    }
    
    func removeNotificationObservers() {
        if !notificationObservers.isEmpty {
            for observer in notificationObservers {
                notificationCenter.removeObserver(observer!)
            }
            notificationObservers.removeAll()
            debugPrint("Remove notification observers")
        }
        debugPrint("Notification observers are already removed")
    }
}

