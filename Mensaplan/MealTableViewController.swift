//
//  MealTableViewController.swift
//  Mensaplan
//
//  Created by Stefan Sator on 11.09.19.
//  Copyright © 2019 Stefan Sator. All rights reserved.
//

import UIKit

class MealTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    //MARK: Properties
    var meals = [Meal]()
    @IBOutlet weak var mealTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mealTableView.dataSource = self
        mealTableView.delegate = self
        loadMealData(weekDay: "mo")
    }

    //MARK: Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meals.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "MealTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MealTableViewCell else {
            fatalError("Error in trying to downcast UITableViewCell to Type: MealTableViewCell.")
        }
        // Configure the cell
        let meal = meals[indexPath.row]
        cell.mealImage.image = meal.image
        cell.mealNameLabel.text = meal.name
        cell.mealPrizeLabel.text = "\(meal.cost.students), \(meal.cost.employees), \(meal.cost.guests)"

        return cell
    }
    
    //MARK: Actions
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        clearAllMealData()
        switch sender.selectedSegmentIndex {
        case 0:
            loadMealData(weekDay: "mo")
        case 1:
            loadMealData(weekDay: "di")
        case 2:
            loadMealData(weekDay: "mi")
        case 3:
            loadMealData(weekDay: "do")
        case 4:
            loadMealData(weekDay: "fr")
        default:
            fatalError("The selected Index in UISegmentedControl doesn't exist.")
        }
    }
    
    //MARK: Private Functions
    private func loadMealData(weekDay: String) {
        // Set up the http request with URLSession
        let session = URLSession.shared
        // Check the Request URL
        guard let url = URL(string: "https://regensburger-forscher.de:9001/mensa/uni/\(weekDay)") else {
            fatalError("The URL could not be resolved.")
        }
        // Make the request with URLSessionDataTask
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            // Check for error on client side
            guard error == nil else {
                fatalError("An Error occured on client side, while executing REST Call. Error: \(error!.localizedDescription)")
            }
            // Check for error on server side
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                fatalError("An Error occured on server side, while executing REST Call.")
            }
            // Parse response data to JSON
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as! NSArray
                self.initializeMealArray(withArray: json)
            } catch let error {
                fatalError("JSON error: \(error.localizedDescription)")
            }
            // Reload Table: UITask so i need to call reloadData() on Main-Thread
            DispatchQueue.main.async {
                self.mealTableView.reloadData()
            }
        })
        // Start the Task
        task.resume()
    }
    
    private func clearAllMealData() {
        meals = [Meal]()
    }
    
    private func initializeMealArray(withArray: NSArray) {
        for object in withArray {
            guard let dictionary = object as? NSDictionary else {
                fatalError("An Error occurred while converting Object to NSDictionary.")
            }
            guard let meal = Meal(dictionary: dictionary) else {
                fatalError("An Error occurred while trying to create a Meal Object from a Dictionary.")
            }
            meals.append(meal)
        }
    }

}
