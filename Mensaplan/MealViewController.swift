//
//  ViewController.swift
//  Mensaplan
//
//  Created by Stefan Sator on 10.09.19.
//  Copyright © 2019 Stefan Sator. All rights reserved.
//

import UIKit

protocol ChangedFavoritesDelegate {
    func changesInFavorites(_ changes: Bool)
}

class MealViewController: UIViewController {
    //MARK: Properties
    var delegate: ChangedFavoritesDelegate?
    var meal : Meal?
    @IBOutlet weak var mealImage: UIImageView!
    @IBOutlet weak var mealName: UILabel!
    @IBOutlet weak var studentPrize: UILabel!
    @IBOutlet weak var guestPrize: UILabel!
    @IBOutlet weak var employeePrize: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    
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
    
    @IBAction func subscribe(_ sender: UIButton) {
        saveMealToFavorites()
        let toast = Toast(controller: self, title: "", message: "Als Favorit gespeichert.")
        toast.showToast()
    }
    
    //MARK: NSCoding
    private func saveMealToFavorites() {
        guard meal != nil else {
            fatalError("No Meal defined for Archiving.")
        }
        var savedFavorites = NSKeyedUnarchiver.unarchiveObject(withFile: Meal.ArchiveURL.path) as? [Meal]
        if savedFavorites != nil {
            print("data saved. Number of meal data saved: \(savedFavorites!.count)")
            savedFavorites!.append(meal!)
        } else {
            print("No data saved. Create new Meal Array to archive meal data.")
            savedFavorites = [Meal]()
            savedFavorites!.append(meal!)
        }
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: savedFavorites!, requiringSecureCoding: false)
            try data.write(to: Meal.ArchiveURL)
        } catch let error {
            print("Error by trying to save meal object as favorite of the user. Meal Object not saved! Error: \(error.localizedDescription)")
        }
        print("Meal saved as Favorite of the user.")
        // Tell the Delegate that there where changes
        self.delegate?.changesInFavorites(true)
    }
    
    //Delete Persisted Meal Data
    private func deleteArchivedFavoriteMeals() {
        do {
            let manager = FileManager.default
            try manager.removeItem(at: Meal.ArchiveURL)
        } catch let error {
            print("Error by trying to delete favorite meals. Error: \(error.localizedDescription)")
        }
    }

}

