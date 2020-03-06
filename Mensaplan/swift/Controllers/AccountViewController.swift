//
//  AccountViewController.swift
//  Mensaplan
//
//  Created by Stefan Sator on 11.11.19.
//  Copyright © 2019 Stefan Sator. All rights reserved.
//

import UIKit

/// Controller implementing the Logout Process of the app.
class AccountViewController: UIViewController {
    @IBOutlet weak var logoutButton: RoundedButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: Actions
    /// Action Listener which gets triggered when Logout Button is clicked.
    /// Ends the current session and logs out the user.
    ///
    /// - Parameter sender: The Logout Button.
    @IBAction func logoutButtonClicked(_ sender: UIButton) {
        UserSession.endSession()
        performSegue(withIdentifier: "logoutSegue", sender: self)
    }
    
}
