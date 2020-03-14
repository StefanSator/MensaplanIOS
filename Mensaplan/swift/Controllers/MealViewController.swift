//
//  ViewController.swift
//  Mensaplan
//
//  Created by Stefan Sator on 10.09.19.
//  Copyright © 2019 Stefan Sator. All rights reserved.
//

import UIKit

/// Classes who implement this interface can be informed by a Delegator
/// if changes occurred to a Meal Object, e.g. User disliked a Meal.
/// They can then implement the Function to perform appropriate reactions to the changes,
/// e.g. by updating the right element in the list to show the changes immediately to the user.
protocol ChangesLikeDislikeDelegate {
    /// Implementors of the interface can define this function to be informed if changes to a Meal
    /// Object occurred and react to it appropriately.
    ///
    /// - Parameter changes: true, if changes have occurred.
    func changesInLikesDislikes(_ changes: Bool)
}

/// Controller for controlling the Detail Screen of a Meal, which is shown if a user wants to look
/// at detailed information of a Meal in the app.
class MealViewController: UIViewController {
    //MARK: Properties
    /// The Delegate which gets informed if changes to the displayed Meal occurred.
    var delegate : ChangesLikeDislikeDelegate?
    /// The Meal Object which holds the information about the displayed Mensa Meal.
    var meal : Meal?
    /// Holds the Route for Liking Functionality in the Backendservice.
    let likeRoute = "/likes"
    /// Current Like State of the user. A Like State tells if a user has liked, disliked or is neutral to the meal.
    var likeState = LikeStates.neutral;
    /// The UIImageView showing the approriate image for a meal.
    @IBOutlet weak var mealImage: UIImageView!
    /// Label containing the name of the meal.
    @IBOutlet weak var mealName: UILabel!
    /// Label containing the price for students for the meal.
    @IBOutlet weak var studentPrize: UILabel!
    /// Label containing the price for guests for the meal.
    @IBOutlet weak var guestPrize: UILabel!
    /// Label containing the price for employees for the meal.
    @IBOutlet weak var employeePrize: UILabel!
    /// Button for closing the window.
    @IBOutlet weak var cancelButton: UIButton!
    /// Button for liking a meal.
    @IBOutlet weak var likeButton: UIButton!
    /// Button for disliking a meal.
    @IBOutlet weak var dislikeButton: UIButton!
    /// Label containing the number of likes.
    @IBOutlet weak var likeCountLabel: UILabel!
    /// Label containing the number of dislikes.
    @IBOutlet weak var dislikeCountLabel: UILabel!
    /// Button which can be pressed to schedule a notification for the meal.
    @IBOutlet weak var notificationButton: UIButton!
    /// The dialog window
    @IBOutlet weak var mealDialog: UIView!
    
    //MARK: Types
    /// Struct holding the possible like types as static members of the struct.
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
    /// Click Listener for the cancelButton. Closes the Dialog Window and returns to previous window.
    ///
    /// - Parameter sender: The Cancel Button.
    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    /// Click Listener for the likeButton. Is called if user clicks on likeButton. Performs the
    /// appropriate actions for liking a meal by communicating with the backend and updating views.
    ///
    /// - Parameter sender: The Like Button.
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
    
    /// Click Listener for the dislikeButton. Is called if user clicks on dislikeButton. Performs the
    /// appropriate actions for disliking a meal by communicating with the backend and updating views.
    ///
    /// - Parameter sender: The Dislike Button.
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
    
    /// Action which is called automatically if user clicks the notificationButton. Sets Notification for displayed Meal
    /// and informs user when Meal is available. Even if user is absent and not in the app.
    ///
    /// - Parameter sender: The Notification Button.
    @IBAction func setNotificationForMeal(_ sender: UIButton) {
        guard meal != nil else {
            print("No meal defined to set notification for user.")
            return;
        }
        let currentDayOfWeek = Calendar.current.component(.weekday, from: Date())
        guard let dayOnWhichMealIsAvailable = meal!.weekdayIndex else {
            fatalError("Error: The weekdayIndex of the selected Meal is nil.");
        }
        if (dayOnWhichMealIsAvailable < currentDayOfWeek || currentDayOfWeek == 1) {
            let alertController = UIAlertController(title: "Gericht verpasst.", message:
                "Gericht liegt in der Vergangenheit.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alertController, animated: true, completion: nil)
        } else if (dayOnWhichMealIsAvailable == currentDayOfWeek) {
            let alertController = UIAlertController(title: "Gericht jetzt verfügbar.", message:
                "Das Gericht ist zum aktuellen Zeitpunkt in der Mensa verfügbar.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alertController, animated: true, completion: nil)
        } else {
            // Get Notification Manager
            let notificationManager = NotificationManager.shared
            // Set the Notification
            var dateComponents = DateComponents()
            dateComponents.calendar = Calendar.current
            dateComponents.weekday = meal!.weekdayIndex
            dateComponents.hour = 11
            let notification = Notification(id: "\(meal!.id)", title: "Gericht heute verfügbar!", body: "\(meal!.name)", datetime: dateComponents)
            // Append to notifications array in Manager
            notificationManager.notifications = [notification]
            // Schedule Notification
            notificationManager.schedule(context: self)
        }
    }
    
    
    //MARK: Private Functions
    /// Starts Backend DELETE-Request to delete likes or dislikes from DB.
    private func deleteLikeDislikeInDB() {
        let queryParams = "?mealId=\(meal!.id)&sessionId=\(UserSession.getSessionToken())"
        NetworkingManager.shared.DELETERequestToBackend(route: "/meals\(likeRoute)", queryParams: queryParams, completionHandler: deleteLikeDislikeHandler)
    }
    
    /// Completion Handler for Backend DELETE-Request for deleting likes and dislikes.
    ///
    /// - Parameters:
    ///   - data: The data returned from the backend service as response.
    ///   - response: Metadata associated with the request, e.g. the status code of the response.
    ///   - error: Contains the Error if an error has occurred.
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
    
    /// Starts Backend POST-Request to update or insert like, dislike in DB.
    ///
    /// - Parameter type: The type of the like. Like: 1. Dislike: -1.
    private func insertOrUpdateLikeDislikeInDB(type: Int) {
        let like = [
            "userId": UserSession.getSessionToken(),
            "mealId": meal!.id,
            "type": type
        ]
        NetworkingManager.shared.POSTRequestToBackend(route: "/meals\(likeRoute)", body: like, completionHandler: insertOrUpdateLikeDislikeHandler)
    }
    
    /// Completion Handler for Backend POST-Request for updating or inserting Likes and Dislikes of a sepecified Meal.
    ///
    /// - Parameters:
    ///   - data: The data returned from the backend service as response.
    ///   - response: Metadata associated with the request, e.g. the status code of the response.
    ///   - error: Contains the Error if an error has occurred.
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
    
    /// Starts Backend GET-Request to check if user likes, dislikes or is neutral to the currently displayed Meal.
    private func getLikeDislikeState() {
        NetworkingManager.shared.GETRequestToBackend(route: "/meals\(likeRoute)", queryParams: "?mealid=\(meal!.id)&userid=\(UserSession.getSessionToken())", completionHandler: likeDislikeStateHandler)
    }
    
    /// Completion Handler for Backend GET-Request for Like-/Dislike State of User regarding the displayed Meal.
    ///
    /// - Parameters:
    ///   - data: The data returned from the backend service as response.
    ///   - response: Metadata associated with the request, e.g. the status code of the response.
    ///   - error: Contains the Error if an error has occurred.
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
    
    /// Change Button Colors specific to the Like-State of the user regarding this meal and set Number of Likes and Dislikes.
    ///
    /// - Parameter state: dictionary containing information about the likestate of a user. Keys: dislikes -> Number of dislikes of the meal.
    /// likes -> Number of likes of the meal. state -> tells if user likes, dislikes or is neutral regarding the displayed meal.
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
    
    /// Highlight the Buttons appropriately, if the User has liked/disliked the Meal or nothing of both.
    ///
    /// - Parameters:
    ///   - like: true, if user likes the displayed meal.
    ///   - dislike: true, if user dislikes the displayed meal.
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
    
    /// Update the Like State for a given Like type: 0: neutral, 1: like, -1: dislike.
    ///
    /// - Parameter type: The type of like.
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
    
    /// Informs the registered Delegate that changes have occurred to the Meal Object.
    private func informDelegate() {
        delegate?.changesInLikesDislikes(true)
    }

}
