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

class MealTableViewController: UIViewController, UITableViewDataSource, ChangesLikeDislikeDelegate {
    //MARK: Properties
    /// List containing the current Mensa Meals.
    var meals = [Meal]()
    /// Current Calendar Object.
    var calendar = NSCalendar.current
    /// Dictionary containing meals ordered by categories of the meals.
    private var mealsDictionary = [ 0: [Meal](),
                            1: [Meal](),
                            2: [Meal](),
                            3: [Meal]()]
    /// Table View for displaying the list containing the Mensa Meals.
    @IBOutlet weak var mealTableView: UITableView!
    /// Segmented Control used for switching through a tab bar between different days of the week.
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mealTableView.dataSource = self
        mealTableView.rowHeight = 200
        loadMealDataDependingOnSelectedIndex(segmentedControl: segmentedControl)
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
        cell.likeNumberLabel.text = "\(meal.likes)"
        cell.dislikeNumberLabel.text = "\(meal.dislikes)"

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
    
    //MARK: ChangesLikeDislikeDelegate
    func changesInLikesDislikes(_ changes: Bool) {
        if (changes == true) {
            loadMealDataDependingOnSelectedIndex(segmentedControl: segmentedControl)
        }
    }
    
    // MARK: Actions
    /// Action automatically triggered if a tab in the SegmentedControl was selected. Loads Meal Data
    /// depending on the selected index of the Segmented Control.
    ///
    /// - Parameter sender: The Segmented Control View.
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        loadMealDataDependingOnSelectedIndex(segmentedControl: sender)
    }
    
    
    /// Action automatically triggered if a element in the list is selected. Opens the Meal Detail Window
    /// to show Details to the selected Meal.
    ///
    /// - Parameter sender: The List item.
    @IBAction func itemSelected(_ sender: MDCCard) {
        performSegue(withIdentifier: "showMealSegue", sender: self)
    }
    
    //MARK: Navigation
    /// Make Preparations before switching to another screen of the app.
    ///
    /// - Parameters:
    ///   - segue: The Segue which was triggered.
    ///   - sender: The object that initiated the segue.
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
            mealViewController.delegate = self
        default:
            fatalError("Segue Identifier unknown: \(String(describing: segue.identifier))")
        }
    }
    
    //MARK: Private Functions
    /// Get Meal Data for a selected week day from the backend service through a rest call.
    ///
    /// - Parameter weekDay: Selected Weekday.
    private func loadMealData(weekDay: String) {
        let calendarWeek = calendar.component(.weekOfYear, from: Date())
        let year = calendar.component(.year, from: Date())
        NetworkingManager.shared.GETRequestToBackend(route: "/meals", queryParams: "?weekDay='\(weekDay)'&calendarWeek=\(calendarWeek)&year=\(year)", completionHandler: loadMealDataHandler)
    }
    
    /// Handles the functional Logic after GET-Request in function loadMealData() has completed.
    ///
    /// - Parameters:
    ///   - data: The data returned from the backend service as response.
    ///   - response: Metadata associated with the request, e.g. the status code of the response.
    ///   - error: Contains the Error if an error has occurred.
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
    
    /// Clears the Data Set of the Table View.
    private func clearAllMealData() {
        mealsDictionary[0]!.removeAll()
        mealsDictionary[1]!.removeAll()
        mealsDictionary[2]!.removeAll()
        mealsDictionary[3]!.removeAll()
    }
    
    /// Fill the Data Set with data from the JSONArray Response returned by the backend.
    ///
    /// - Parameter jsonArray: The JSON Array response returned from the backend service.
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
    
    /// Loads the right Meal Data depending on which index in the UISegmentedControl has been selected.
    ///
    /// - Parameter segmentedControl: The Segmented Control View.
    private func loadMealDataDependingOnSelectedIndex(segmentedControl: UISegmentedControl) {
        clearAllMealData()
        switch segmentedControl.selectedSegmentIndex {
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
    
}
