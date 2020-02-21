//
//  UserSession.swift
//  Mensaplan
//
//  Created by Stefan Sator on 13.11.19.
//  Copyright © 2019 Stefan Sator. All rights reserved.
//

import Foundation

class UserSession {
    static var SESSION_TOKEN = 0;
    
    //MARK: Static Functions
    static func setSessionToken(_ token: Int) {
        SESSION_TOKEN = token
    }
    
    static func getSessionToken() -> Int {
        return SESSION_TOKEN
    }
    
    static func endSession() {
        SESSION_TOKEN = 0;
    }
}
