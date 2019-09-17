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
    var delegate : ChangedFavoritesDelegate?
    var meal : Meal?
    var savedFavorites : [Meal]?
    var subscribedToMeal : Bool = false
    @IBOutlet weak var mealImage: UIImageView!
    @IBOutlet weak var mealName: UILabel!
    @IBOutlet weak var studentPrize: UILabel!
    @IBOutlet weak var guestPrize: UILabel!
    @IBOutlet weak var employeePrize: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var subscribeButton: UIButton!
    @IBOutlet weak var subscribeLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
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
        // If meal is a favorite of the user, change Subscribe Button to Unsubscribe Button
        loadMealFavorites()
        if savedFavorites!.contains(where: {(data) in return data.name == self.meal!.name}) {
            setUnsubscribeButton()
        } else {
            setSubscribeButton()
        }
    }
    
    //MARK: Actions
    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func subscribe(_ sender: UIButton) {
        if subscribedToMeal == false {
            saveMealToFavorites()
            let toast = Toast(controller: self, title: "", message: "Als Favorit hinzugefügt.")
            toast.showToast()
            setUnsubscribeButton()
        } else {
            deleteMealFromFavorites()
            let toast = Toast(controller: self, title: "", message: "Als Favorit entfernt.")
            toast.showToast()
            setSubscribeButton()
        }
    }
    
    //MARK: NSCoding
    private func loadMealFavorites() {
        savedFavorites = NSKeyedUnarchiver.unarchiveObject(withFile: Meal.ArchiveURL.path) as? [Meal]
        if savedFavorites != nil {
            print("data saved. Number of meal data saved: \(savedFavorites!.count)")
        } else {
            print("No data saved. Create new Meal Array to archive meal data.")
            savedFavorites = [Meal]()
        }
    }
    
    private func saveMealToFavorites() {
        guard meal != nil else {
            fatalError("No Meal defined for Archiving.")
        }
        savedFavorites!.append(meal!)
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
    
    private func deleteMealFromFavorites() {
        guard meal != nil else {
            fatalError("No meal defined for deleting from Archive.")
        }
        if let index = savedFavorites!.firstIndex(where: {(data) in return data.name == self.meal!.name}) {
            savedFavorites!.remove(at: index)
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: savedFavorites!, requiringSecureCoding: false)
                try data.write(to: Meal.ArchiveURL)
            } catch let error {
                print("Error by trying to save meals as favorites of the user. Meal Objects not saved! Error: \(error.localizedDescription)")
            }
            print("Meal saved as Favorite of the user.")
            // Tell the Delegate that there where changes
            self.delegate?.changesInFavorites(true)
        } else {
            print("Meal Item could not be found in saved Favorites of the user.")
        }
    }
    
    //MARK: Private functions
    private func setUnsubscribeButton() {
        subscribeButton.setTitle("-", for: .normal)
        subscribeLabel.text = "Als Favorit entfernen"
        subscribedToMeal = true
    }
    
    private func setSubscribeButton() {
        subscribeButton.setTitle("+", for: .normal)
        subscribeLabel.text = "Als Favorit hinzufügen"
        subscribedToMeal = false
    }

}
