//
//  Toast.swift
//  Mensaplan
//
//  Created by Stefan Sator on 16.09.19.
//  Copyright © 2019 Stefan Sator. All rights reserved.
//

import UIKit

/* Custom Class that copys functionality of a Toast in Android for iOS */
/* Unfortunately Subclassing the UIAlertController is not allowed, so i had to bypass this. */
class Toast {
    let alert : UIAlertController
    let controller : UIViewController
    let title: String
    let message: String
    
    init(controller: UIViewController, title: String, message: String) {
        self.alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        self.controller = controller
        self.title = title
        self.message = message
    }
    
    func showToast() {
        controller.present(alert, animated: true, completion: nil)
        
        // Dismiss the alert after a short period of time, like a Toast in Android would
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            self.alert.dismiss(animated: true, completion: nil)
        })
    }

}
