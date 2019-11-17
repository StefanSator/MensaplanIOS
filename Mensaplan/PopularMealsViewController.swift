//
//  PopularMealsViewController.swift
//  Mensaplan
//
//  Created by Stefan Sator on 16.11.19.
//  Copyright © 2019 Stefan Sator. All rights reserved.
//

import UIKit
import Lottie
import MaterialComponents

class PopularMealsViewController: UIViewController, ChangesLikeDislikeDelegate {
    var calendar = NSCalendar.current
    var mostPopularMeal: Meal?
    var mostUnpopularMeal: Meal?
    @IBOutlet weak var trophyAnimationView: AnimationView!
    @IBOutlet weak var thumbsAnimationView: AnimationView!
    @IBOutlet weak var mostPopularNameLabel: UILabel!
    @IBOutlet weak var mostUnpopularNameLabel: UILabel!
    @IBOutlet weak var mostPopularCard: MDCCard!
    @IBOutlet weak var mostUnpopularCard: MDCCard!
    
    /* override func viewDidLoad() {
        super.viewDidLoad()
        
        trophyAnimationView.play()
        trophyAnimationView.loopMode = LottieLoopMode.loop
        
        thumbsAnimationView.play()
        thumbsAnimationView.loopMode = LottieLoopMode.loop
    } */
    
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
    @IBAction func showMostPopularMeal(_ sender: MDCCard) {
        performSegue(withIdentifier: "showMealSegue", sender: sender)
    }
    
    @IBAction func showMostUnpopularMeal(_ sender: MDCCard) {
        performSegue(withIdentifier: "showMealSegue", sender: sender)
    }
    
    //MARK: Navigation
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
    /* Starts GET-Request to Heroku Backend to get the current most popular and most unpopular Meal */
    private func loadPopularAndUnpopularMeal() {
        //let calendarWeek = calendar.component(.weekOfYear, from: Date())
        let calendarWeek = 46 // TODO
        let year = calendar.component(.year, from: Date())
        var weekDayID = calendar.component(.weekday, from: Date())
        if (weekDayID == 1 || weekDayID == 7) { // when Sa or Su, set weekday = Fri
            weekDayID = 6
        }
        let weekDay = transformWeekdayIntToString(weekDayID: weekDayID)
        NetworkingManager.shared.GETRequestToBackend(route: "/meals/popular", queryParams: "?weekday='\(weekDay)'&calendarweek=\(calendarWeek)&year=\(year)", completionHandler: loadPopularAndUnpopularMealHandler)
    }
    
    /* Completion Handler for GET-Request to get most popular and most unpopular Meal */
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
    
    /* Returns the String Identifier of a weekday for a given weekdayID */
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
