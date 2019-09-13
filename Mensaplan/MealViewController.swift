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
    var meal : Meal?
    @IBOutlet weak var mealImage: UIImageView!
    @IBOutlet weak var mealName: UILabel!
    @IBOutlet weak var studentPrize: UILabel!
    @IBOutlet weak var guestPrize: UILabel!
    @IBOutlet weak var employeePrize: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard meal != nil else {
            fatalError("No meal defined.")
        }
        mealImage.image = meal!.image
        mealName.text = meal!.name
        studentPrize.text = "Studenten:  \(meal!.cost.students) €"
        guestPrize.text = "Gäste:  \(meal!.cost.guests) €"
        employeePrize.text = "Angestellte:  \(meal!.cost.employees) €"
    }
    
    //MARK: Actions
    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    

}

