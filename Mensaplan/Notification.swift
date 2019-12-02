//
//  Notification.swift
//  Mensaplan
//
//  Created by Stefan Sator on 02.12.19.
//  Copyright © 2019 Stefan Sator. All rights reserved.
//

import Foundation

class Notification {
    // MARK: Properties
    var id: String
    var title: String
    var body: String
    var datetime: DateComponents
    
    // MARK: Constructors
    init(id: String, title: String, body: String, datetime: DateComponents) {
        self.id = id
        self.title = title
        self.body = body
        self.datetime = datetime
    }
    
}
