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
    static let techniquesTableSegue = "Techniques Table"
    static let techniqueDetailsSegue = "Technique Detail"
    static let selectedDojoSegue = "Selected Dojo"
    static let newDojoSegue = "New Dojo"
    static let newTrainingSegue = "New Training"
    static let selectTechniquesSegue = "Select Techniques"
    static let addTechniquesSegue = "Add Technique"
    static let unwindToMainSeuge = "Unwind to Main Menu"
    
    // MARK: StoryBoard Items
    static let largeTileSize = CGSize(width: UIScreen.main.bounds.size.width, height: 150)
    static let smallTileSize = CGSize(width: UIScreen.main.bounds.size.width / 2, height: 150)
    static let minButtonHeight = CGFloat(44)
    
    static let largeTile = "Large Tile"
    static let smallTile = "Small Tile"
    
    static let newTrainingTechniqueCell = "New Training Technique Cell"
    
    // MARK: View tags
    static let dojoImageView = 100
    
    
    // MARK: Colors
    static let backgroundColor = UIColor(red: scalar(31), green: scalar(31), blue: scalar(31), alpha: 1)
    static let systemColor = UIColor(red: scalar(186), green: scalar(217), blue: scalar(181), alpha: 1)
    static let userColor = UIColor(red: scalar(239), green: scalar(247), blue: scalar(207), alpha: 1)
    static let actionColor = UIColor(red: scalar(255), green: scalar(127), blue: scalar(0), alpha: 1)
    static let accentColor = UIColor(red: scalar(212), green: scalar(198), blue: scalar(133), alpha: 1)
    
    fileprivate static func scalar(_ value: Int) -> CGFloat {
        return CGFloat(value)/255
    }
}

extension Notification.Name
{
    static let getDojoNotification = Notification.Name("getDojoNotification")
    static let getMainMenuNotification = Notification.Name("getMainMenuNotification")
    static let plistReadNotification = Notification.Name("plistReadNotification")
    static let newTrainingCreatedNotification = Notification.Name("newTrainingCreatedNotification")
}
