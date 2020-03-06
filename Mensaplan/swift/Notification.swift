//
//  Notification.swift
//  Mensaplan
//
//  Created by Stefan Sator on 02.12.19.
//  Copyright © 2019 Stefan Sator. All rights reserved.
//

import Foundation

/// Class representing a Notification.
class Notification {
    // MARK: Properties
    /// ID of the Notification
    var id: String
    /// Title of the Notification
    var title: String
    /// Text of the Notification
    var body: String
    /// Date and Time on which the Notification should be scheduled.
    var datetime: DateComponents
    
    // MARK: Constructors
    /**
     Initializes a new Notification.
     - Parameters:
        - id: ID of the Notification.
        - title: Title of the Notification.
        - body: Text of the Notification.
        - datetime: Date and Time on which the Notification should be scheduled.
     */
    init(id: String, title: String, body: String, datetime: DateComponents) {
        self.id = id
        self.title = title
        self.body = body
        self.datetime = datetime
    }
    
}
