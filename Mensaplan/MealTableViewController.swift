//
//  MealTableViewController.swift
//  Mensaplan
//
//  Created by Stefan Sator on 11.09.19.
//  Copyright © 2019 Stefan Sator. All rights reserved.
//

import UIKit
import Foundation
import MaterialComponents.MaterialCards

class MealTableViewController: UIViewController, UITableViewDataSource {
    //MARK: Properties
    let backendUrl = "https://young-beyond-20476.herokuapp.com/meals"
    var meals = [Meal]()
    var calendar = NSCalendar.current
    private var mealsDictionary = [ 0: [Meal](),
                            1: [Meal](),
                            2: [Meal](),
                            3: [Meal]()]
    @IBOutlet weak var mealTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mealTableView.dataSource = self
        mealTableView.rowHeight = 200
        //weekOfYear = calendar.component(.weekOfYear, from: Date())
        loadMealData(weekDay: "Mo")
    }

    //MARK: Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return mealsDictionary.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mealsDictionary[section]!.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "MealTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MealTableViewCell else {
            fatalError("Error in trying to downcast UITableViewCell to Type: MealTableViewCell.")
        }
        // Configure the cell
        let meal = mealsDictionary[indexPath.section]![indexPath.row]
        cell.mealImage.image = meal.image
        cell.mealNameLabel.text = meal.name

        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionTitle: String?
        switch section {
        case 0:
            sectionTitle = "Suppen"
        case 1:
            sectionTitle = "Hauptgerichte"
        case 2:
            sectionTitle = "Nebengerichte"
        case 3:
            sectionTitle = "Desserts"
        default:
            sectionTitle = nil
        }
        return sectionTitle
    }
    
    // MARK: Actions
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        clearAllMealData()
        switch sender.selectedSegmentIndex {
        case 0:
            loadMealData(weekDay: "Mo")
        case 1:
            loadMealData(weekDay: "Tu")
        case 2:
            loadMealData(weekDay: "We")
        case 3:
            loadMealData(weekDay: "Th")
        case 4:
            loadMealData(weekDay: "Fr")
        default:
            fatalError("The selected Index in UISegmentedControl doesn't exist.")
        }
    }
    
    @IBAction func itemSelected(_ sender: MDCCard) {
        performSegue(withIdentifier: "showMealSegue", sender: self)
    }
    
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch (segue.identifier ?? "") {
        case "showMealSegue":
            guard let mealViewController = segue.destination as? MealViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let indexPath = mealTableView.indexPathForSelectedRow else {
                fatalError("Selected Cell not being displayed in table.")
            }
            guard let meals = mealsDictionary[indexPath.section] else {
                fatalError("Could not retrieve array of meals in the section.")
            }
            let selectedMeal = meals[indexPath.row]
            mealViewController.meal = selectedMeal
        default:
            fatalError("Segue Identifier unknown: \(String(describing: segue.identifier))")
        }
    }
    
    //MARK: Private Functions
    /* Starts GET-Request to the Backend to get Meal Data */
    private func loadMealData(weekDay: String) {
        let calendarWeek = calendar.component(.weekOfYear, from: Date())
        let year = calendar.component(.year, from: Date())
        NetworkingManager.shared.GETRequestToBackend(route: "/meals", queryParams: "?weekDay='\(weekDay)'&calendarWeek=\(calendarWeek)&year=\(year)", completionHandler: loadMealDataHandler)
    }
    
    /* Handles the functional Logic after GET-Request completed */
    private func loadMealDataHandler(_ data: Data?, _ response: URLResponse?, _ error: Error?) {
        guard error == nil else {
            fatalError("An Error occurred on client side, while executing REST Call. Error: \(error!.localizedDescription)")
        }
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            fatalError("An Error occurred on server side, while executing REST Call.")
        }
        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: data!, options: []) as? [NSDictionary] {
                self.initializeMealDictionary(jsonArray: jsonArray)
            }
        } catch let error {
            fatalError("Error: \(error.localizedDescription)")
        }
        // Reload Meal Table in Main-Thread
        DispatchQueue.main.async {
            self.mealTableView.reloadData()
        }
    }
    
    private func clearAllMealData() {
        mealsDictionary[0]!.removeAll()
        mealsDictionary[1]!.removeAll()
        mealsDictionary[2]!.removeAll()
        mealsDictionary[3]!.removeAll()
    }
    
    /* Initialize the mealsDictionary by passing a JSON-Array */
    private func initializeMealDictionary(jsonArray: [NSDictionary]) {
        for jsonObject in jsonArray {
            guard let meal = Meal(dictionary: jsonObject) else {
                fatalError("An Error occurred while trying to create a Meal Object from a JSON-Object.");
            }
            if meal.category.hasPrefix("S") {
                mealsDictionary[0]!.append(meal)
            } else if meal.category.hasPrefix("HG") {
                mealsDictionary[1]!.append(meal)
            } else if meal.category.hasPrefix("B") {
                mealsDictionary[2]!.append(meal)
            } else if meal.category.hasPrefix("N") {
                mealsDictionary[3]!.append(meal)
            } else {
                fatalError("The meal category doesn't exist.")
            }
        }
    }
    
}
