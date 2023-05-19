//
//  MockUserNotificationManager.swift
//  SmokeApp
//
//  Created by Лев Куликов on 19.05.2023.
//

import Foundation
import NotificationCenter

final class MockUserNotificationManager: UserNotificationManagerProtocol {
    var isSystemAllowsNotifications: Bool
    
    var isUserAllowsNotifications: Bool
    
    var allowLimitExceededNotification: Bool
    
    var allowReminderNotification: Bool
    
    init() {
        isSystemAllowsNotifications = true
        isUserAllowsNotifications = true
        allowLimitExceededNotification = true
        allowReminderNotification = true
    }
    
    func checkForSystemNotificationPermition() {
        print("MockUserNotificationManager")
    }
    
    func dispatchLimitExceedNotification(limit: Int16?) {
        print("MockUserNotificationManager")
    }
    
    func dispatchReminderNotification() {
        print("MockUserNotificationManager")
    }
    
    func disableNotifications() {
        print("MockUserNotificationManager")
    }
    
    func askForNotificationPermition() {
        print("MockUserNotificationManager")
    }
    
    func enableNotifications(completionHandler: ((Bool, UNAuthorizationStatus) -> Void)?) {
        print("MockUserNotificationManager")
    }
}
