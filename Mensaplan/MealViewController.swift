//
//  ViewController.swift
//  Mensaplan
//
//  Created by Stefan Sator on 10.09.19.
//  Copyright © 2019 Stefan Sator. All rights reserved.
//

import UIKit

class MealViewController: UIViewController {
    //MARK: Properties
    @IBOutlet weak var mealListLabel: UILabel!
    var meals = [Meal]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mealListLabel.text = "Essen"
    }

}

