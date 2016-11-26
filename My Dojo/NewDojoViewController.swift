//
//  NewDojoViewController.swift
//  My Dojo
//
//  Created by Andreas Hörberg on 2016-09-27.
//  Copyright © 2016 Andreas Hörberg. All rights reserved.
//

import UIKit
import MapKit

protocol HandleMapSearch {
    func dropPinZoomIn(_ placemark: MKPlacemark)
}

class NewDojoViewController: UIViewController {

    let locationManager = CLLocationManager()
    var selectedPin: MKPlacemark?

    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = Constants.locationAccuracy
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()

        let identifier = "DojoSearchTable"
        guard let dojoSearchTable = storyboard?.instantiateViewController(withIdentifier: identifier) as? DojoSearchTableViewController else {
            fatalError("Not a Dojo Search TableView")
        }
        resultSearchController = UISearchController(searchResultsController: dojoSearchTable)
        resultSearchController?.searchResultsUpdater = dojoSearchTable

        guard let searchBar = resultSearchController?.searchBar else { fatalError("Couldn't get the dojo searchbar") }
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for dojos"
//        navigationItem.titleView = resultSearchController?.searchBar
        navigationItem.titleView = searchBar

        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true

        dojoSearchTable.mapView = mapView
        dojoSearchTable.handleMapSearchDelegate = self

        backToHomeButton.isHidden = true
        loadingLabel.isHidden = true

    }

    var resultSearchController: UISearchController? = nil

    @IBOutlet weak var blurEffect: UIVisualEffectView!
    @IBOutlet weak var backToHomeButton: UIButton!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

    func selectDojo() {
        if let selectedPin = selectedPin {
            let mapItem = MKMapItem(placemark: selectedPin)
            var image: UIImage? = nil

            // save a picture of the map to put on the dojobutton on the front page
            let snapShotOptions = MKMapSnapshotOptions()
            snapShotOptions.size = CGSize(width: mapView.bounds.size.width, height: Constants.mapImageHeight)
            snapShotOptions.camera = mapView.camera
            snapShotOptions.scale = UIScreen.main.scale
            snapShotOptions.mapType = .standard

            loadingLabel.isHidden = false
            loadingIndicator.startAnimating()
            let snapShotter = MKMapSnapshotter(options: snapShotOptions)
            UIApplication.shared.beginIgnoringInteractionEvents()
            snapShotter.start() { snapshot, error in

                guard snapshot != nil else {
                    debugPrint(error as Any)
                    UIApplication.shared.endIgnoringInteractionEvents()
                    return
                }
                image = snapshot?.image != nil ? snapshot!.image : nil

                DatabaseManager.save(dojo: mapItem, mapImage: image)

                self.loadingIndicator.stopAnimating()
                self.loadingLabel.isHidden = true
                self.backToHomeButton.isHidden = false
                UIApplication.shared.endIgnoringInteractionEvents()
            }

            blurEffect.isHidden = false
        }
    }
}

extension NewDojoViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpanMake(Constants.zoomLevelLatitude, Constants.zoomLevelLongitude)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
}

extension NewDojoViewController: HandleMapSearch {
    func dropPinZoomIn(_ placemark: MKPlacemark) {
        // cache the pin
        selectedPin = placemark

        //clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality, let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(Constants.zoomLevelLatitude, Constants.zoomLevelLongitude)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
}

extension NewDojoViewController : MKMapViewDelegate {
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
        button.addTarget(self, action: #selector(selectDojo), for: .touchUpInside)
        pinView?.rightCalloutAccessoryView = button
        return pinView
    }
}
