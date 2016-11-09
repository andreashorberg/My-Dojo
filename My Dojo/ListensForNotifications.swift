//
//  ListensForNotifications.swift
//  My Dojo
//
//  Created by Andreas Hörberg on 2016-11-09.
//  Copyright © 2016 Andreas Hörberg. All rights reserved.
//

import Foundation

protocol ListensForNotifications {
    func addNotificationObservers()
    func removeNotificationObservers()
    
    var notificationObservers: [NSObjectProtocol?] { get set }
    var notificationCenter: NotificationCenter { get }
}
