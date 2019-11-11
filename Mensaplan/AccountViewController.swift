//
//  AccountViewController.swift
//  Mensaplan
//
//  Created by Stefan Sator on 11.11.19.
//  Copyright © 2019 Stefan Sator. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController {
    @IBOutlet weak var logoutButton: RoundedButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: Actions
    @IBAction func logoutButtonClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "logoutSegue", sender: self)
    }
    
}
