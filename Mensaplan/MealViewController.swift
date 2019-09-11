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
        loadMealData()
        mealListLabel.text = "Essen"
    }

    //MARK: Private Functions
    private func loadMealData() {
        // Set up the http request with URLSession
        let session = URLSession.shared
        // Check the Request URL
        guard let url = URL(string: "https://regensburger-forscher.de:9001/mensa/uni/fr") else {
            print("The URL could not be resolved!")
            return
        }
        // Make the request with URLSessionDataTask
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            // Check for error on client side
            guard error == nil else {
                self.handleClientError(error)
                return
            }
            /* Check for error on server side */
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                self.handleServerError(response)
                return
            }
            // Parse response data to JSON
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as! NSArray
                self.initializeMealArray(withArray: json)
                
            } catch let error {
                print("JSON error: \(error.localizedDescription)")
            }
        })
        task.resume()
    }
    
    private func initializeMealArray(withArray: NSArray) {
        for object in withArray {
            guard let dictionary = object as? NSDictionary else {
                print("An Error occurred while converting JSON Object to NSDictionary.")
                return
            }
            guard let meal = Meal(dictionary: dictionary) else {
                print("An Error occurred while trying to create a Meal Object.")
                return
            }
            meals.append(meal)
        }
    }
    
    private func handleClientError(_ error: Error?) {
        print("An Error occurred on client side, while executing REST Call.")
    }
    
    private func handleServerError(_ response: URLResponse?) {
        print("An Error occurred on server side, while executing REST Call.")
    }

}

