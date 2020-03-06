//
//  PopularMealsViewController.swift
//  Mensaplan
//
//  Created by Stefan Sator on 16.11.19.
//  Copyright © 2019 Stefan Sator. All rights reserved.
//

import UIKit
import Lottie
import MaterialComponents.MaterialCards

/// Controller for implementing the Most Popular and Unpopular Meal Functionality. It displays the Most
/// Popular and Most Unpopular Meal of the current day.
class PopularMealsViewController: UIViewController, ChangesLikeDislikeDelegate {
    /// Current Calendar Object.
    var calendar = NSCalendar.current
    /// Most Popular Meal of the current day.
    var mostPopularMeal: Meal?
    /// Most Unpopular Meal of the current day.
    var mostUnpopularMeal: Meal?
    /// View for the Trophy Animation.
    @IBOutlet weak var trophyAnimationView: AnimationView!
    /// Viewe for the Thumbs Down Animation.
    @IBOutlet weak var thumbsAnimationView: AnimationView!
    /// Label containing the Name of the Most Popular Meal.
    @IBOutlet weak var mostPopularNameLabel: UILabel!
    /// Label containing the Name of the Most Unpopular Meal.
    @IBOutlet weak var mostUnpopularNameLabel: UILabel!
    /// Card containing the Content for the Most Popular Meal.
    @IBOutlet weak var mostPopularCard: MDCCard!
    /// Card containing the Content for the Most Unpopular Meal.
    @IBOutlet weak var mostUnpopularCard: MDCCard!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loadPopularAndUnpopularMeal()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        mostPopularCard.tag = 0
        mostUnpopularCard.tag = 1
        
        trophyAnimationView.play()
        trophyAnimationView.loopMode = LottieLoopMode.loop
        
        thumbsAnimationView.play()
        thumbsAnimationView.loopMode = LottieLoopMode.loop
    }
    
    //MARK: ChangesLikeDislikeDelegate
    func changesInLikesDislikes(_ changes: Bool) {
        loadPopularAndUnpopularMeal()
    }
    
    //MARK: Actions
    /// Opens the Meal Detail Dialog if the Card for the Most Popular Meal is clicked.
    ///
    /// - Parameter sender: The Most Popular Meal Card.
    @IBAction func showMostPopularMeal(_ sender: MDCCard) {
        performSegue(withIdentifier: "showMealSegue", sender: sender)
    }
    
    /// Opens the Meal Detail Dialog if the Card for the Most Unpopular Meal is clicked.
    ///
    /// - Parameter sender: The Most Unpopular Meal Card.
    @IBAction func showMostUnpopularMeal(_ sender: MDCCard) {
        performSegue(withIdentifier: "showMealSegue", sender: sender)
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
            guard let senderCard = sender as? MDCCard else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            if (senderCard.tag == 0) {
                mealViewController.meal = mostPopularMeal
                mealViewController.delegate = self
            } else {
                mealViewController.meal = mostUnpopularMeal
                mealViewController.delegate = self
            }
        default:
            fatalError("Segue Identifier unknown: \(String(describing: segue.identifier))")
        }
    }
    
    //MARK: Private Functions
    /// Starts GET-Request to Backend to retrieve the most popular and most unpopular Meal of current day.
    private func loadPopularAndUnpopularMeal() {
        let calendarWeek = calendar.component(.weekOfYear, from: Date())
        let year = calendar.component(.year, from: Date())
        var weekDayID = calendar.component(.weekday, from: Date())
        if (weekDayID == 1 || weekDayID == 7) { // when Sa or Su, set weekday = Fri
            weekDayID = 6
        }
        let weekDay = transformWeekdayIntToString(weekDayID: weekDayID)
        NetworkingManager.shared.GETRequestToBackend(route: "/meals/popular", queryParams: "?weekday='\(weekDay)'&calendarweek=\(calendarWeek)&year=\(year)", completionHandler: loadPopularAndUnpopularMealHandler)
    }
    
    /// Completion Handler for GET-Request to get most popular and most unpopular Meal.
    ///
    /// - Parameters:
    ///   - data: The data returned from the backend service as response.
    ///   - response: Metadata associated with the request, e.g. the status code of the response.
    ///   - error: Contains the Error if an error has occurred.
    private func loadPopularAndUnpopularMealHandler(_ data: Data?, _ response: URLResponse?, _ error: Error?) {
        guard error == nil else {
            fatalError("An Error occurred on client side, while executing REST Call. Error: \(error!.localizedDescription)")
        }
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            fatalError("An Error occurred on server side, while executing REST Call.")
        }
        do {
            if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                guard let popularMealJSON = json["popular"] as? NSDictionary else {
                    fatalError("Error in trying to get popular Meal Data from Json Response of Backend.")
                }
                guard let unpopularMealJSON = json["unpopular"] as? NSDictionary else {
                    fatalError("Error in trying to get unpopular Meal Data from Json Response of Backend.")
                }
                mostPopularMeal = Meal(dictionary: popularMealJSON)
                mostUnpopularMeal = Meal(dictionary: unpopularMealJSON)
                DispatchQueue.main.async {
                    self.mostPopularNameLabel.text = self.mostPopularMeal?.name
                    self.mostUnpopularNameLabel.text = self.mostUnpopularMeal?.name
                }
            }
        } catch let error {
            fatalError("Error: \(error.localizedDescription)")
        }
    }
    
    /// Returns the String Identifier of a weekday for a given int.
    ///
    /// - Parameter weekDayID: Current weekday as int.
    /// - Returns: Current weekday as String.
    private func transformWeekdayIntToString(weekDayID: Int) -> String {
        switch (weekDayID) {
        case 1:
            return "Su";
        case 2:
            return "Mo";
        case 3:
            return "Tu";
        case 4:
            return "We";
        case 5:
            return "Th";
        case 6:
            return "Fr";
        case 7:
            return "Sa";
        default:
            return "Mo";
        }
    }

}
