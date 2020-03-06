//
//  StartViewController.swift
//  Mensaplan
//
//  Created by Stefan Sator on 07.11.19.
//  Copyright © 2019 Stefan Sator. All rights reserved.
//

import UIKit


/// The controller for handling the Start Screen of the app.
class StartViewController: UIViewController {
    /// Login Button.
    @IBOutlet weak var loginButton: RoundedButton!
    /// Registration Button.
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: Actions
    
    /// Action which is executed when the login button is clicked by the user.
    ///
    /// - Parameter sender: The button which was clicked.
    @IBAction func loginButtonClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "loginSegue", sender: self)
    }
    
    /// Action which is executed when the registration button is clicked by the user.
    ///
    /// - Parameter sender: The button which was clicked.
    @IBAction func registerButtonClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "registerSegue", sender: self)
    }
}
