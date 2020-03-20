//
//  NotificationManager.swift
//  Mensaplan
//

import Foundation
import UserNotifications
import UIKit

/// Class which is responsible for managing Notifications within the app.
class NotificationManager {
    /// Singleton Instance of the NotificationManager.
    static let shared = NotificationManager()
    // MARK: Properties
    /// List of Notifications to manage.
    var notifications = [Notification]()
    /// Current application context.
    var context: UIViewController?
    
    // MARK: Constructors
    /// Private Constructor, so that it is not possible to create multiple instances of the NetworkingManager Class.
    private init() {}
    
    // MARK: Public Functions
    /**
     Prints all the Notifications which are currently set.
     */
    public func listNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests() {
            (notifications) in
            for notification in notifications {
                print(notification)
            }
        }
    }
    
    /**
     Set Notification Permission and schedule Notification.
     - Parameter context: Current application context.
     */
    public func schedule(context: UIViewController) {
        self.context = context
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
                case .notDetermined:
                    self.requestAuthorization()
                case .authorized, .provisional:
                    self.scheduleNotifications()
                default:
                    break; // do nothing
            }
        }
    }
    
    // MARK: Private Functions
    /**
     Request permission from user to set the Notification. If permission given, call function scheduleNotifications().
     */
    private func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { allowed, error in
            guard error == nil else {
                print("An Error happend while asking user for permission for notifications: \(error!.localizedDescription)")
                return
            }
            guard allowed == true else {
                print("User denied the permission for setting notifications.")
                if (self.context != nil) {
                    DispatchQueue.main.async {
                        let toast = Toast(controller: self.context!, title: "", message: "Verstanden! Wir werden Ihnen keine Benachrichtigung senden.");
                        toast.showToast();
                    }
                }
                return
            }
            self.scheduleNotifications()
        }
    }
    
    /**
     Schedule Notifications for Notifications of the notifications list.
     */
    private func scheduleNotifications() {
        for notification in notifications {
            let content = UNMutableNotificationContent()
            content.title = notification.title
            content.body = notification.body
            content.sound = UNNotificationSound.default
            let trigger = UNCalendarNotificationTrigger(dateMatching: notification.datetime, repeats: false)
            let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { error in
                guard error == nil else {
                    print("Error while trying to schedule notifications: \(error!.localizedDescription)")
                    return
                }
                print("Notification with id: \(notification.id) successfully scheduled.")
                if (self.context != nil) {
                    DispatchQueue.main.async {
                        let toast = Toast(controller: self.context!, title: "", message: "Ok! Sie werden bei Verfügbarkeit benachrichtigt.");
                        toast.showToast();
                    }
                }
            }
        }
    }
}
