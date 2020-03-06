//
//  Meal.swift
//  Mensaplan
//
//  Created by Stefan Sator on 10.09.19.
//  Copyright © 2019 Stefan Sator. All rights reserved.
//

import Foundation
import UIKit

/// Class representing a Mensa Meal.
class Meal : NSObject {
    //MARK: Properties
    /// ID of the Meal.
    let id: Int
    /// Name of the Meal.
    let name: String
    /// Weekday on which the meal is available in the mensa.
    let weekday: String
    /// Day of month on which the meal is available in the mensa.
    let day: Int
    /// Month on which the meal is available in the mensa.
    let month: Int
    /// Year on which the meal is available in the mensa.
    let year: Int
    /// Category of the meal.
    let category: String
    /// Costs of the meal.
    var cost: (students: Double, employees: Double, guests: Double)
    /// Number of likes.
    let likes: Int
    /// Number of dislikes.
    let dislikes: Int
    /// Image of the meal representing the category of the meal.
    var image: UIImage?
    /// String describing the contents of the Meal Object.
    override public var description: String {
        return "Meal: \(name), weekday: \(weekday), Category: \(category), studentPrize: \(cost.students), employeePrize: \(cost.employees), guestPrize: \(cost.guests)"
    }
    
    //MARK: Initialization
    /// Initializes a new Meal Object.
    ///
    /// - Parameters:
    ///   - id: ID of the meal.
    ///   - name: Name of the meal.
    ///   - day: Day of Month on which the meal is available.
    ///   - month: Month on which the meal is available.
    ///   - year: Year on which the meal is available.
    ///   - weekday: Day of week on which the meal is available.
    ///   - category: Category of the meal.
    ///   - studentPrice: Price for students.
    ///   - employeePrice: Price for employees.
    ///   - guestPrice: Price for guests.
    ///   - likes: Number of likes.
    ///   - dislikes: Number of dislikes.
    init(id: Int, name: String, day: Int, month: Int, year: Int, weekday: String, category: String, studentPrice: Double, employeePrice: Double, guestPrice: Double, likes: Int, dislikes: Int) {
        self.id = id
        self.name = name
        self.day = day
        self.month = month
        self.year = year
        self.weekday = weekday
        self.category = category
        self.cost = (studentPrice, employeePrice, guestPrice)
        self.likes = likes
        self.dislikes = dislikes
        super.init()
        setRightImage(category: category)
    }
    
    /// Initializes a new Meal Object from an existing dictionary.
    ///
    /// - Parameter dictionary: The dictionary to create the meal object from.
    init?(dictionary: NSDictionary) {
        guard let id = dictionary["mealid"] as? Int,
            let name = dictionary["mealname"] as? String,
            let day = dictionary["day"] as? Int,
            let month = dictionary["month"] as? Int,
            let year = dictionary["year"] as? Int,
            let weekday = dictionary["weekday"] as? String,
            let category = dictionary["category"] as? String,
            let studentPrice = Double(dictionary["studentprice"] as! String),
            let employeePrice = Double(dictionary["employeeprice"] as! String),
            let guestPrice = Double(dictionary["guestprice"] as! String),
            let likes = Int(dictionary["likes"] as! String),
            let dislikes = Int(dictionary["dislikes"] as! String)
        else {
            return nil;
        }
        self.id = id;
        self.name = name;
        self.day = day;
        self.month = month + 1;
        self.year = year;
        self.weekday = weekday;
        self.category = category;
        self.cost = (studentPrice, employeePrice, guestPrice)
        self.likes = likes
        self.dislikes = dislikes
        super.init()
        setRightImage(category: category)
    }
    
    //MARK: Private Functions
    /// Select the right image for the category of the meal.
    ///
    /// - Parameter category: Category of the meal.
    private func setRightImage(category: String) {
        if category.hasPrefix("S") {
            image = UIImage(named: "Soup")
        } else if category.hasPrefix("HG") {
            image = UIImage(named: "MainDish")
        } else if category.hasPrefix("B") {
            image = UIImage(named: "SideDish")
        } else if category.hasPrefix("N") {
            image = UIImage(named: "Dessert")
        } else {
            image = nil
        }
    }
}
