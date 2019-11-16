//
//  FavoritesViewController.swift
//  Mensaplan
//
//  Created by Stefan Sator on 16.09.19.
//  Copyright © 2019 Stefan Sator. All rights reserved.
//

import UIKit

class FavoritesTableViewController: UITableViewController, ChangesLikeDislikeDelegate {
    //MARK: Properties
    var favoriteMeals = [Meal]()
    var likes = [Int]()
    var dislikes = [Int]()
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
            fatalError("Error in trying to downcast UITableViewCell to Type: FavoritesTableViewCell.")
        }
        // Configure the cell
        let meal = favoriteMeals[indexPath.row]
        cell.mealNameLabel.text = meal.name
        if (likes.contains(meal.id)) {
            cell.kindLabel.textColor = UIColor.blue
            cell.kindLabel.text = "✓"
        } else if (dislikes.contains(meal.id)) {
            cell.kindLabel.textColor = UIColor.red
            cell.kindLabel.text = "×"
        }
        
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
            // DELETE-Request to Backend
            deleteLikeOrDislikeOfUserFor(meal: favoriteMeals[indexPath.row])
            // Delete the row from the data source
            favoriteMeals.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    //MARK: ChangesLikeDislikeDelegate
    func changesInLikesDislikes(_ changes: Bool) {
        if changes == true {
            loadTableData()
        }
    }
    
    //MARK: Actions
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showMealSegue", sender: self)
    }
    
    @IBAction func deletaAllFavoriteMeals(_ sender: UIBarButtonItem) {
        // DELETE-Request for Deletion of all meals which user liked or disliked
        deleteAllLikesOrDislikes()
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
    
    //MARK: Private Functions
    /* Starts DELETE-Request to Backend to delete ALL likes or dislikes of a specified user */
    private func deleteAllLikesOrDislikes() {
        let user = [
            "userId": UserSession.getSessionToken()
        ]
        NetworkingManager.shared.DELETERequestToBackend(route: "/meals/alllikes", body: user, completionHandler: deleteAllLikesOrDislikesHandler)
    }
    
    /* Completion Handler for DELETE-Request to delete all likes and dislikes of a user */
    private func deleteAllLikesOrDislikesHandler(_ data: Data?, _ response: URLResponse?, _ error: Error?) {
        guard error == nil else {
            fatalError("An Error occurred on client side, while executing REST Call. Error: \(error!.localizedDescription)")
        }
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            fatalError("An Error occurred on server side, while executing REST Call.")
        }
        do {
            if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                // TODO: Error Handling
                print(json)
            }
        } catch let error {
            fatalError("Error: \(error.localizedDescription)")
        }
    }
    
    /* Starts DELETE-Request to Backend to delete a like or dislike of a specified user regarding a specified Meal */
    private func deleteLikeOrDislikeOfUserFor(meal: Meal) {
        let like = [
            "userId": UserSession.getSessionToken(),
            "mealId": meal.id
        ]
        NetworkingManager.shared.DELETERequestToBackend(route: "/meals/likes", body: like, completionHandler: deleteLikeOrDislikeHandler)
    }
    
    /* Completion Handler for DELETE-Request to Backend to delete a like or dislike */
    private func deleteLikeOrDislikeHandler(_ data: Data?, _ response: URLResponse?, _ error: Error?) {
        guard error == nil else {
            fatalError("An Error occurred on client side, while executing REST Call. Error: \(error!.localizedDescription)")
        }
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            fatalError("An Error occurred on server side, while executing REST Call.")
        }
        do {
            if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                // TODO: Error Handling
                print(json)
            }
        } catch let error {
            fatalError("Error: \(error.localizedDescription)")
        }
    }
    
    /* Starts GET-Request to Backend to get all meals the user either liked or disliked */
    private func loadTableData() {
        NetworkingManager.shared.GETRequestToBackend(route: "/meals/userlikes", queryParams: "?userid=\(UserSession.getSessionToken())", completionHandler: loadTableDataHandler)
    }
    
    /* Completion Handler for GET-Request to Backend to get all meals the user either liked or disliked */
    private func loadTableDataHandler(_ data: Data?, _ response: URLResponse?, _ error: Error?) {
        guard error == nil else {
            fatalError("An Error occurred on client side, while executing REST Call. Error: \(error!.localizedDescription)")
        }
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            fatalError("An Error occurred on server side, while executing REST Call.")
        }
        do {
            if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                self.initializeMealArray(json: json)
            }
        } catch let error {
            fatalError("Error: \(error.localizedDescription)")
        }
        // Reload Meal Table in Main-Thread
        DispatchQueue.main.async {
            self.favoritesTableView.reloadData()
        }
    }
    
    /* Initializes the Meals Array and fills the likes and dislikes Array with the appropriate mealId's */
    private func initializeMealArray(json: [String: Any]) {
        clearTableData()
        if let jsonMeals = json["meals"] as? [NSDictionary] {
            for jsonMeal in jsonMeals {
                guard let meal = Meal(dictionary: jsonMeal) else {
                    fatalError("An Error occurred while trying to create a Meal Object from a JSON-Object.");
                }
                favoriteMeals.append(meal)
            }
        }
        if let jsonLikes = json["likes"] as? [NSDictionary] {
            for jsonLike in jsonLikes {
                if let mealId = jsonLike["mealid"] as? Int {
                    likes.append(mealId)
                }
            }
        }
        if let jsonDislikes = json["dislikes"] as? [NSDictionary] {
            for jsonDislike in jsonDislikes {
                if let mealId = jsonDislike["mealid"] as? Int {
                    dislikes.append(mealId)
                }
            }
        }
    }
    
    /* Clears the current Data Set of the Table */
    private func clearTableData() {
        favoriteMeals = [Meal]()
        likes = [Int]()
        dislikes = [Int]()
    }
    
    /*
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
    } */

}
