//
//  NotificationManager.swift
//  Mensaplan
//
//  Created by Stefan Sator on 02.12.19.
//  Copyright © 2019 Stefan Sator. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit

class NotificationManager {
    static let shared = NotificationManager()
    // MARK: Properties
    var notifications = [Notification]()
    var context: UIViewController?
    
    // MARK: Constructors
    private init() {}
    
    // MARK: Public Functions
    /* Lists all the Notifications which are currently set */
    public func listNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests() {
            (notifications) in
            for notification in notifications {
                print(notification)
            }
        }
    }
    
    /* Set Notification Permission and Schedule Notification */
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
    /* Request permission from user to set the Notification */
    public func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { allowed, error in
            guard error == nil else {
                print("An Error happend while asking user for permission for notifications: \(error!.localizedDescription)")
                return
            }
            guard allowed == true else {
                print("User denied the permission for setting notifications.")
                if (self.context != nil) {
                    DispatchQueue.main.async {
                        let toast = Toast(controller: self.context!, title: "", message: "Ok! We will not send notifications.");
                        toast.showToast();
                    }
                }
                return
            }
            self.scheduleNotifications()
        }
    }
    
    /* Schedule Notifications for Notifications which are part of the notifications list of this class */
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
                        let toast = Toast(controller: self.context!, title: "", message: "Ok! We will not notify you.");
                        toast.showToast();
                    }
                }
            }
        }
    }
}
