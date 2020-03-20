//
//  UserSession.swift
//  Mensaplan
//

import Foundation

/// Class holding information about the current User Session.
class UserSession {
    /// Session Token of the user. Needed for identification of the user to the backend service.
    static var SESSION_TOKEN = 0;
    
    // MARK: Static Functions
    /**
     Set Session Token.
     - Parameter token: The token to set as Session Token.
    */
    static func setSessionToken(_ token: Int) {
        SESSION_TOKEN = token
    }
    
    /**
     Get Session Token.
     - Returns: The Session Token of the logged in user.
     */
    static func getSessionToken() -> Int {
        return SESSION_TOKEN
    }
    
    /// End the current User Session.
    static func endSession() {
        SESSION_TOKEN = 0;
    }
}
