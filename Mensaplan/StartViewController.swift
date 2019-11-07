//
//  StartViewController.swift
//  Mensaplan
//
//  Created by Stefan Sator on 07.11.19.
//  Copyright © 2019 Stefan Sator. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {
    @IBOutlet weak var loginButton: RoundedButton!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: Actions
    @IBAction func loginButtonClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "loginSegue", sender: self)
    }
    
    @IBAction func registerButtonClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "registerSegue", sender: self)
    }
}
