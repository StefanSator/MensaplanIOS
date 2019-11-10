//
//  FavoritesViewController.swift
//  Mensaplan
//
//  Created by Stefan Sator on 16.09.19.
//  Copyright © 2019 Stefan Sator. All rights reserved.
//

import UIKit

class FavoritesTableViewController: UITableViewController, ChangedFavoritesDelegate {
    //MARK: Properties
    var favoriteMeals = [Meal]()
    @IBOutlet weak var favoritesTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loadTableData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Use of the edit button item provided by the table view controller
        navigationItem.leftBarButtonItem = editButtonItem
        loadTableData()
    }
    
    //MARK: Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteMeals.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "FavoritesTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? FavoritesTableViewCell else {
            fatalError("Error in trying to downcast UITableViewCell to Type: MealTableViewCell.")
        }
        // Configure the cell
        let meal = favoriteMeals[indexPath.row]
        cell.mealImage.image = meal.image
        cell.mealNameLabel.text = meal.name
        cell.mealPrizeLabel.text = "\(meal.cost.students), \(meal.cost.employees), \(meal.cost.guests)"
        
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            favoriteMeals.remove(at: indexPath.row)
            saveFavoriteMeals()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    //MARK: ChangedFavoritesDelegate
    func changesInFavorites(_ changes: Bool) {
        if changes == true {
            loadTableData()
        }
    }
    
    //MARK: Actions
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showMealSegue", sender: self)
    }
    
    @IBAction func deletaAllFavoriteMeals(_ sender: UIBarButtonItem) {
        deleteArchivedFavoriteMeals()
        favoriteMeals = [Meal]()
        favoritesTableView.reloadData()
    }
    
    
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch (segue.identifier ?? "") {
        case "showMealSegue":
            guard let mealViewController = segue.destination as? MealViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let indexPath = favoritesTableView.indexPathForSelectedRow else {
                fatalError("Selected Cell not being displayed in table.")
            }
            let selectedMeal = favoriteMeals[indexPath.row]
            mealViewController.meal = selectedMeal
            mealViewController.delegate = self
        default:
            fatalError("Segue Identifier unknown: \(String(describing: segue.identifier))")
        }
    }
    
    //MARK: NSCoding
    private func loadFavoriteMeals() -> [Meal]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Meal.ArchiveURL.path) as? [Meal]
    }
    
    private func saveFavoriteMeals() {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: favoriteMeals, requiringSecureCoding: false)
            try data.write(to: Meal.ArchiveURL)
        } catch let error {
            print("Error by trying to save meals as favorite of the user. Meals not saved! Error: \(error.localizedDescription)")
        }
        print("Meals saved as Favorites of the user.")
    }
    
    //Delete Persisted Meal Data
    private func deleteArchivedFavoriteMeals() {
        do {
            let manager = FileManager.default
            try manager.removeItem(at: Meal.ArchiveURL)
            print("All Favorites deleted.")
        } catch let error {
            print("Error by trying to delete favorite meals. Error: \(error.localizedDescription)")
        }
    }
    
    // Private Functions
    private func loadTableData() {
        let savedFavoriteMeals = loadFavoriteMeals()
        if savedFavoriteMeals != nil {
            favoriteMeals = savedFavoriteMeals!
            favoritesTableView.reloadData()
        }
    }

}
