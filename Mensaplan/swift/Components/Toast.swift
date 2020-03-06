//
//  Toast.swift
//  Mensaplan
//
//  Created by Stefan Sator on 16.09.19.
//  Copyright © 2019 Stefan Sator. All rights reserved.
//

import UIKit

/// Custom Class that copys functionality of a Toast in Android for iOS.
class Toast {
    /// Alert Controller for displaying alerts.
    let alert : UIAlertController
    /// Current application context.
    let controller : UIViewController
    /// Title to display in Toast.
    let title: String
    /// Message to display in Toast.
    let message: String
    
    /// Initializes a new Toast Object.
    ///
    /// - Parameters:
    ///   - controller: Current application context.
    ///   - title: Title to display in Toast.
    ///   - message: Message to display in Toast.
    init(controller: UIViewController, title: String, message: String) {
        self.alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        self.controller = controller
        self.title = title
        self.message = message
    }
    
    /// Shows a Toast displaying the title and message for a short period of time to the user of the app.
    func showToast() {
        controller.present(alert, animated: true, completion: nil)
        
        // Dismiss the alert after a short period of time, like a Toast in Android would
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            self.alert.dismiss(animated: true, completion: nil)
        })
    }

}
