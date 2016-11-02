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
    public var myDojo: Dojo?
    private var areYouSure: UIAlertController?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBAction func changeDojoAction(_ sender: AnyObject) {
        areYouSure = UIAlertController.init(title: Constants.areYouSureTitle, message: Constants.areYouSureMessage, preferredStyle: .alert)
        
        let okAction = UIAlertAction.init(title: Constants.okTitle, style: .default) { Void in
            switch self.myDojo!.remove() {
            case true:
                var 🛠_TODO_IMPLEMENT_maybe_try_unwind_segue_here: Any?
                break
            case false:
                var 🛠_TODO_IMPLEMENT: Any?
                break
            }
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
        
        DispatchQueue.main.async { [unowned self] in
            self.addressLabel.text = self.myDojo?.mapItem?.placemark.title
            self.prepareMapView()
        }
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

