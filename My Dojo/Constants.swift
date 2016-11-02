//
//  Constants.swift
//  My Dojo
//
//  Created by Andreas Hörberg on 2016-10-15.
//  Copyright © 2016 Andreas Hörberg. All rights reserved.
//

import Foundation
import MapKit

public struct Constants {
    
    // MARK: My Dojo
    static let buttonTransitionDuration = 0.25 //seconds
    static let viewTitle = "My Dojo"
    
    // MARK: New Dojo
    static let zoomLevelLatitude = 0.05
    static let zoomLevelLongitude = 0.05
    static let locationAccuracy = kCLLocationAccuracyKilometer
    static let mapImageHeight: CGFloat = 150.0 // same as myDojoButton height from MyDojoViewController
    
    // MARK:  Selected Dojo
    static let areYouSureTitle = "Are you sure?"
    static let areYouSureMessage = "Pressing OK will remove your Dojo, press Cancel to go back"
    static let okTitle = "OK"
    static let cancelTitle = "Cancel"
    
    // MARK: Segues
    static let techniquesTable = "Techniques Table"
    static let techniqueDetailsSegue = "Technique Detail"
    static let selectedDojoSegue = "Selected Dojo"
    static let newDojoSegue = "New Dojo"
    static let newTrainingSegue = "New Training"
    static let selectTechniques = "Select Techniques"
    
    // MARK: StoryBoard Items
    static let largeTileSize = CGSize(width: UIScreen.main.bounds.size.width, height: 150)
    static let smallTileSize = CGSize(width: UIScreen.main.bounds.size.width / 2, height: 150)
    static let minButtonHeight = CGFloat(44)
    
    static let largeTile = "Large Tile"
    static let smallTile = "Small Tile"
    
    // MARK: View tags
    static let dojoImageView = 100
    
}


extension Notification.Name
{
    static let getDojoNotification = Notification.Name("getDojoNotification")
    static let getMainMenuNotification = Notification.Name("getMainMenuNotification")
    static let plistReadNotification = Notification.Name("plistReadNotification")
}
