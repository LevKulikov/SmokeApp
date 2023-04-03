//
//  UserNotificationManager.swift
//  SmokeApp
//
//  Created by Лев Куликов on 30.03.2023.
//

import Foundation
import UserNotifications

/// Protocol to manage user's notifications
protocol UserNotificationManagerProtocol: AnyObject {
    /// Checks status of notification permision
    func checkForNotificationPermition()
    
    /// Sends in the queue notification about limit exceeded
    /// - Parameter limit: set limit that was exceeded
    func dispatchLimitExceedNotification(limit: Int16?)
}

/// Class to manage user's notifications
final class UserNotificationManager: UserNotificationManagerProtocol {
    //MARK: Properties
    /// Current User Notification center
    private let notificationCenter: UNUserNotificationCenter
    
    /// Identifier for notification when limit is exceeded
    private let limitExceedNotificationIdentifier = "limitExceedNotificationIdentifier"
    
    //MARK: Initalizer
    init() {
        notificationCenter = UNUserNotificationCenter.current()
        checkForNotificationPermition()
    }
    //MARK: Methods
    func checkForNotificationPermition() {
        notificationCenter.getNotificationSettings { [weak self] notificationSettings in
            switch notificationSettings.authorizationStatus {
            case .authorized:
                self?.dispatchTestNotification()
            case .notDetermined:
                self?.notificationCenter.requestAuthorization(options: .alert) { didAllow, error in
                    if didAllow {
                        self?.dispatchTestNotification()
                    }
                }
            default:
                return
            }
        }
    }
    
    /// Dispatches test notification
    func dispatchTestNotification() {
        let title = "Test Notification"
        let body = "Test body notification"
        let identifier = "test-notification-id"
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let hour = 10
        let minute = 30
        let isDaily = true
        
        var dateComponents = DateComponents(calendar: Calendar.current, timeZone: TimeZone.current)
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let triger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: isDaily)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: triger)
        
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        notificationCenter.add(request)
    }
    
    func dispatchLimitExceedNotification(limit: Int16? = nil) {
        let title = "You exceeded your limit"
        var body: String
        if let limit {
            body = "Your daily limit \(limit) is exceeded, try to stop smoking for today"
        } else {
            body = "Your daily limit is exceeded, try to stop smoking for today"
        }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let date = Date.now
        let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: date)
        
        let triger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(
            identifier: limitExceedNotificationIdentifier,
            content: content,
            trigger: triger
        )
        
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [limitExceedNotificationIdentifier])
        notificationCenter.add(request)
    }
}
