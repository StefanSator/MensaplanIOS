//
//  RegisterViewController.swift
//  Mensaplan
//
//  Created by Stefan Sator on 07.11.19.
//  Copyright © 2019 Stefan Sator. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {
    @IBOutlet weak var registerButton: RoundedButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: Actions
    @IBAction func registerButtonClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "registerSuccessfulSegue", sender: self)
    }
    

}
