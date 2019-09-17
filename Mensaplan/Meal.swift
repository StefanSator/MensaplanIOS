//
//  Meal.swift
//  Mensaplan
//
//  Created by Stefan Sator on 10.09.19.
//  Copyright © 2019 Stefan Sator. All rights reserved.
//

import Foundation
import UIKit

class Meal : NSObject, NSCoding {
    //MARK: Properties
    let name: String
    let day: String
    let category: String
    var cost: (students: Double, employees: Double, guests: Double)
    var image: UIImage?
    override public var description: String {
        return "Meal: \(name), Day: \(day), Category: \(category), studentPrize: \(cost.students), employeePrize: \(cost.employees), guestPrize: \(cost.guests)"
    }
    
    //MARK: Archiving Paths
    /* static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("favorites") */
    static var ArchiveURL : URL {
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first!
        return url.appendingPathComponent("favorites")
    }
    
    //MARK:Types
    struct PropertyKey {
        static let name = ""
        static let day = "day"
        static let category = "category"
        static let studentCosts = "studentcosts"
        static let employeeCosts = "employeecosts"
        static let guestCosts = "guestcosts"
        static let image = "image"
    }
    
    //MARK: Initialization
    init(name: String, day: String, category: String, studentPrice: Double, employeePrice: Double, guestPrice: Double) {
        self.name = name
        self.day = day
        self.category = category
        self.cost = (studentPrice, employeePrice, guestPrice)
        super.init()
        setRightImage(category: category)
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
        super.init()
        setRightImage(category: category)
    }
    
    //MARK: NSCoding
    // A protocol that enables an object to be encoded and decoded for archiving and distribution
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(day, forKey: PropertyKey.day)
        aCoder.encode(category, forKey: PropertyKey.category)
        aCoder.encode(cost.students, forKey: PropertyKey.studentCosts)
        aCoder.encode(cost.employees, forKey: PropertyKey.employeeCosts)
        aCoder.encode(cost.guests, forKey: PropertyKey.guestCosts)
    }
    
    /* Initializing the object by decoding the local saved data with NSCoder */
    required convenience init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            fatalError("Unable to decode the name property which is required for a Meal Object.")
        }
        guard let day = aDecoder.decodeObject(forKey: PropertyKey.day) as? String else {
            fatalError("Unable to decode the day property which is required for a Meal Object.")
        }
        guard let category = aDecoder.decodeObject(forKey: PropertyKey.category) as? String else {
            fatalError("Unable to decode the category property which is required for a Meal Object.")
        }
        // TODO: Error Solving
        let studentCosts = aDecoder.decodeDouble(forKey: PropertyKey.studentCosts)
        let employeeCosts = aDecoder.decodeDouble(forKey: PropertyKey.employeeCosts)
        let guestCosts = aDecoder.decodeDouble(forKey: PropertyKey.guestCosts)
        /* guard let studentCosts = aDecoder.decodeObject(forKey: PropertyKey.studentCosts) as? String,
            let employeeCosts = aDecoder.decodeObject(forKey: PropertyKey.employeeCosts) as? String,
            let guestCosts = aDecoder.decodeObject(forKey: PropertyKey.guestCosts) as? String
        else {
            fatalError("Unable to decode the cost property which is required for a Meal Object.")
        } */
        
        self.init(name: name, day: day, category: category, studentPrice: studentCosts, employeePrice: employeeCosts, guestPrice: guestCosts)
    }
    
    //MARK: Private Functions
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
