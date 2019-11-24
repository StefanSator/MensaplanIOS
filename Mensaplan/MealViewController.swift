//
//  ViewController.swift
//  Mensaplan
//
//  Created by Stefan Sator on 10.09.19.
//  Copyright © 2019 Stefan Sator. All rights reserved.
//

import UIKit

protocol ChangesLikeDislikeDelegate {
    func changesInLikesDislikes(_ changes: Bool)
}

class MealViewController: UIViewController {
    //MARK: Properties
    var delegate : ChangesLikeDislikeDelegate?
    var meal : Meal?
    let likeRoute = "/likes"
    var likeState = LikeStates.neutral;
    //var savedFavorites : [Meal]?
    //var likesMeal : Bool?
    @IBOutlet weak var mealImage: UIImageView!
    @IBOutlet weak var mealName: UILabel!
    @IBOutlet weak var studentPrize: UILabel!
    @IBOutlet weak var guestPrize: UILabel!
    @IBOutlet weak var employeePrize: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dislikeButton: UIButton!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var dislikeCountLabel: UILabel!
    @IBOutlet weak var mealDialog: UIView!
    
    //MARK: Types
    struct LikeStates {
        static let like = "like"
        static let dislike = "dislike"
        static let neutral = "neutral"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mealDialog.layer.cornerRadius = 5
        guard meal != nil else {
            fatalError("No meal defined.")
        }
        mealImage.image = meal!.image
        mealName.text = meal!.name
        studentPrize.text = "Studenten:  \(meal!.cost.students) €"
        guestPrize.text = "Gäste:  \(meal!.cost.guests) €"
        employeePrize.text = "Angestellte:  \(meal!.cost.employees) €"
        // If meal is a Like of the user, highlight Like Button or if it is a dislike highlight the Dislike Button
        // and set number of likes and dislikes
        getLikeDislikeState()
    }
    
    //MARK: Actions
    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func like(_ sender: UIButton) {
        if (likeState == LikeStates.like) {
            // Delete Like from DB
            deleteLikeDislikeInDB()
            // Remove highlighting of Like Button
            highlightLikeDislikeButtons(like: false, dislike: false)
            // Decrement Like Count by 1
            if let text = likeCountLabel.text, let count = Int(text) {
                likeCountLabel.text = String(count - 1)
            }
            // Update Like State
            updateLikeState(type: 0)
        } else if (likeState == LikeStates.dislike) {
            // Update Like in DB
            insertOrUpdateLikeDislikeInDB(type: 1)
            // Highlight Like Button, while removing highlighting of Dislike Button
            highlightLikeDislikeButtons(like: true, dislike: false)
            // Increment Like Count by 1, while decrementing Dislike Count by 1
            if let text = likeCountLabel.text, let count = Int(text) {
                likeCountLabel.text = String(count + 1)
            }
            if let text = dislikeCountLabel.text, let count = Int(text) {
                dislikeCountLabel.text = String(count - 1)
            }
            // Update Like State
            updateLikeState(type: 1)
        } else {
            // Insert Like in DB
            insertOrUpdateLikeDislikeInDB(type: 1)
            // Highlight Like Button
            highlightLikeDislikeButtons(like: true, dislike: false)
            // Increment Like Count by 1
            if let text = likeCountLabel.text, let count = Int(text) {
                likeCountLabel.text = String(count + 1)
            }
            // Update Like State
            updateLikeState(type: 1)
        }
    }
    
    @IBAction func dislike(_ sender: UIButton) {
        if (likeState == LikeStates.dislike) {
            // Delete Like from DB
            deleteLikeDislikeInDB()
            // Remove highlighting of Dislike Button
            highlightLikeDislikeButtons(like: false, dislike: false)
            // Decrement Dislike Count by 1
            if let text = dislikeCountLabel.text, let count = Int(text) {
                dislikeCountLabel.text = String(count - 1)
            }
            // Update Like State
            updateLikeState(type: 0)
        } else if (likeState == LikeStates.like) {
            // Update Like in DB
            insertOrUpdateLikeDislikeInDB(type: -1)
            // Highlight Dislike Button, while removing highlighting of Like Button
            highlightLikeDislikeButtons(like: false, dislike: true)
            // Increment Dislike Count by 1, while decrementing Like Count by 1
            if let text = dislikeCountLabel.text, let count = Int(text) {
                dislikeCountLabel.text = String(count + 1)
            }
            if let text = likeCountLabel.text, let count = Int(text) {
                likeCountLabel.text = String(count - 1)
            }
            // Update Like State
            updateLikeState(type: -1)
        } else {
            // Insert Dislike in DB
            insertOrUpdateLikeDislikeInDB(type: -1)
            // Highlight Dislike Button
            highlightLikeDislikeButtons(like: false, dislike: true)
            // Increment Dislike Count by 1
            if let text = dislikeCountLabel.text, let count = Int(text) {
                dislikeCountLabel.text = String(count + 1)
            }
            // Update Like State
            updateLikeState(type: -1)
        }
    }
    
    //MARK: Private Functions
    /* Starts Backend DELETE-Request to delete likes or dislikes from DB */
    private func deleteLikeDislikeInDB() {
        let like = [
            "userId": UserSession.getSessionToken(),
            "mealId": meal!.id
        ]
        NetworkingManager.shared.DELETERequestToBackend(route: "/meals\(likeRoute)", body: like, completionHandler: deleteLikeDislikeHandler)
    }
    
    /* Completion Handler for Backend DELETE-Request for deleting likes and dislikes */
    private func deleteLikeDislikeHandler(_ data: Data?, _ response: URLResponse?, _ error: Error?) {
        // Check for error on client side
        guard error == nil else {
            fatalError("An Error occured on client side, while executing REST Call. Error: \(error!.localizedDescription)")
        }
        // Check for error on server side
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            fatalError("An Error occured on server side, while executing REST Call.")
        }
        do {
            if let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                print(jsonResponse)
                // TODO: Error Handling
                DispatchQueue.main.async {
                    self.informDelegate()
                }
            }
        } catch {
            fatalError("Failed to retrieve JSON Response from Backend");
        }
    }
    
    /* Starts Backend POST-Request to update or insert like, dislike in DB */
    private func insertOrUpdateLikeDislikeInDB(type: Int) {
        let like = [
            "userId": UserSession.getSessionToken(),
            "mealId": meal!.id,
            "type": type
        ]
        NetworkingManager.shared.POSTRequestToBackend(route: "/meals\(likeRoute)", body: like, completionHandler: insertOrUpdateLikeDislikeHandler)
    }
    
    /* Completion Handler for Backend POST-Request for updating or inserting Likes and Dislikes of a sepecified Meal */
    private func insertOrUpdateLikeDislikeHandler(_ data: Data?, _ response: URLResponse?, _ error: Error?) {
        // Check for error on client side
        guard error == nil else {
            fatalError("An Error occured on client side, while executing REST Call. Error: \(error!.localizedDescription)")
        }
        // Check for error on server side
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            fatalError("An Error occured on server side, while executing REST Call.")
        }
        do {
            if let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                print(jsonResponse)
                // TODO: Error Handling
                DispatchQueue.main.async {
                    self.informDelegate()
                }
            }
        } catch {
            fatalError("Failed to retrieve JSON Response from Backend");
        }
    }
    
    /* Starts Backend GET-Request to check if user likes, dislikes or is neutral to the displayed Meal */
    private func getLikeDislikeState() {
        NetworkingManager.shared.GETRequestToBackend(route: "/meals\(likeRoute)", queryParams: "?mealid=\(meal!.id)&userid=\(UserSession.getSessionToken())", completionHandler: likeDislikeStateHandler)
    }
    
    /* Completion Handler for Backend GET-Request for Like-/Dislike State of User regarding the displayed Meal */
    private func likeDislikeStateHandler(_ data: Data?, _ response: URLResponse?, _ error: Error?) {
        guard error == nil else {
            fatalError("An Error occurred on client side, while executing REST Call. Error: \(error!.localizedDescription)")
        }
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            fatalError("An Error occurred on server side, while executing REST Call.")
        }
        do {
            if let state = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                DispatchQueue.main.async {
                    self.updateAndShowLikeDislikes(state: state);
                }
            } else {
                fatalError("JSON Serialization went wrong.")
            }
        } catch let error {
            fatalError("Error: \(error.localizedDescription)")
        }
    }
    
    /* Change Button Colors specific to the Like-State of the user regarding this meal and set Number of Likes and Dislikes */
    private func updateAndShowLikeDislikes(state: NSDictionary) {
        guard let dislikes = state["dislikes"] as? String,
            let likes = state["likes"] as? String,
            let status = state["state"] as? Int
        else {
            fatalError("Type Casting Error in function updateAndShowLikeDislikes()")
        }
        // Show the number of likes and dislikes in total of the meal
        likeCountLabel.text = likes
        dislikeCountLabel.text = dislikes
        // Check if user has liked / disliked the meal or nothing of both
        switch (status) {
            case 1:
                likeState = LikeStates.like
                highlightLikeDislikeButtons(like: true, dislike: false)
            case -1:
                likeState = LikeStates.dislike
                highlightLikeDislikeButtons(like: false, dislike: true)
            default:
                likeState = LikeStates.neutral
                highlightLikeDislikeButtons(like: false, dislike: false)
        }
    }
    
    /* Higlight the Buttons depending on if User has liked / disliked the Meal or nothing of both */
    private func highlightLikeDislikeButtons(like: Bool, dislike: Bool) {
        if like == true {
            likeButton.setTitleColor(.blue, for: .normal)
        } else {
            likeButton.setTitleColor(.gray, for: .normal)
        }
        if dislike == true {
            dislikeButton.setTitleColor(.red, for: .normal)
        } else {
            dislikeButton.setTitleColor(.gray, for: .normal)
        }
    }
    
    /* Update the Like State for a given Like type: 0: neutral, 1: like, -1: dislike */
    private func updateLikeState(type: Int) {
        switch type {
        case 1:
            likeState = LikeStates.like
        case -1:
            likeState = LikeStates.dislike
        default:
            likeState = LikeStates.neutral
        }
    }
    
    /* Informs the Delegate that changes occurred */
    private func informDelegate() {
        delegate?.changesInLikesDislikes(true)
    }
    
    //MARK: NSCoding
    /* private func loadMealFavorites() {
        savedFavorites = NSKeyedUnarchiver.unarchiveObject(withFile: Meal.ArchiveURL.path) as? [Meal]
        if savedFavorites != nil {
            print("data saved. Number of meal data saved: \(savedFavorites!.count)")
        } else {
            print("No data saved. Create new Meal Array to archive meal data.")
            savedFavorites = [Meal]()
        }
    }
    
    private func saveMealToFavorites() {
        guard meal != nil else {
            fatalError("No Meal defined for Archiving.")
        }
        savedFavorites!.append(meal!)
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: savedFavorites!, requiringSecureCoding: false)
            try data.write(to: Meal.ArchiveURL)
        } catch let error {
            print("Error by trying to save meal object as favorite of the user. Meal Object not saved! Error: \(error.localizedDescription)")
        }
        print("Meal saved as Favorite of the user.")
        // Tell the Delegate that there where changes
        self.delegate?.changesInFavorites(true)
    }
    
    private func deleteMealFromFavorites() {
        guard meal != nil else {
            fatalError("No meal defined for deleting from Archive.")
        }
        if let index = savedFavorites!.firstIndex(where: {(data) in return data.name == self.meal!.name}) {
            savedFavorites!.remove(at: index)
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: savedFavorites!, requiringSecureCoding: false)
                try data.write(to: Meal.ArchiveURL)
            } catch let error {
                print("Error by trying to save meals as favorites of the user. Meal Objects not saved! Error: \(error.localizedDescription)")
            }
            print("Meal saved as Favorite of the user.")
            // Tell the Delegate that there where changes
            self.delegate?.changesInFavorites(true)
        } else {
            print("Meal Item could not be found in saved Favorites of the user.")
        }
    } */

}
