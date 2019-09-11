//
//  Meal.swift
//  Mensaplan
//
//  Created by Stefan Sator on 10.09.19.
//  Copyright © 2019 Stefan Sator. All rights reserved.
//

import Foundation

class Meal : CustomStringConvertible {
    //MARK: Properties
    let name: String
    let day: String
    let category: String
    var cost: (students: Double, employees: Double, guests: Double)
    public var description: String {
        return "Meal: \(name), Day: \(day), Category: \(category), studentPrize: \(cost.students), employeePrize: \(cost.employees), guestPrize: \(cost.guests)"
    }
    
    //MARK: Initialization
    init(name: String, day: String, category: String, studentPrice: Double, employeePrice: Double, guestPrice: Double) {
        self.name = name
        self.day = day
        self.category = category
        self.cost = (studentPrice, employeePrice, guestPrice)
    }
    
    init?(dictionary: NSDictionary) {
        guard let name = dictionary["name"] as? String,
            let day = dictionary["day"] as? String,
            let category = dictionary["category"] as? String,
            let costsJSON = dictionary["cost"] as? [String : String],
            let studentCosts = costsJSON["students"],
            let employeeCosts = costsJSON["employees"],
            let guestCosts = costsJSON["guests"],
            let studentPrice = Double(studentCosts.replacingOccurrences(of: ",", with: ".")),
            let employeePrice = Double(employeeCosts.replacingOccurrences(of: ",", with: ".")),
            let guestPrice = Double(guestCosts.replacingOccurrences(of: ",", with: "."))
        else {
            return nil
        }
        self.name = name
        self.day = day
        self.category = category
        self.cost = (studentPrice, employeePrice, guestPrice)
    }
}
