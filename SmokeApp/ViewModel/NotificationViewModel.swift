//
//  NotificationViewModel.swift
//  SmokeApp
//
//  Created by Лев Куликов on 30.04.2023.
//

import Foundation
import UserNotifications

protocol NotificationViewModelProtocol: AnyObject {
    /// Notifications are permited in phone settings
    var isSystemAllowsNotifications: Bool { get }
    
    /// If user wants to get notifications
    var isUserAllowsNotifications: Bool { get }
    
    /// Flag determines if user allows notifications about limit exceed
    var allowLimitExceededNotification: Bool { get set }
    
    /// Flag determines if user allows reminding notifications
    var allowReminderNotification: Bool { get set }
    
    /// Disables notifications
    func disableNotifications()
    
    /// Properly enables app notifications through asking system for permition and asking user to provide permition if system provides that this setting is not determined or denied
    /// - Parameter completionHandler: Handler that is executed after notifications are permitid, parameter of this closure determines if notifications are permited or not, and what is authorization status
    func enableNotifications(completionHandler: ((Bool, UNAuthorizationStatus) -> Void)?)
}

final class NotificationViewModel: NotificationViewModelProtocol {
    //MARK: Propeties
    var isSystemAllowsNotifications: Bool {
        return notificationManager.isSystemAllowsNotifications
    }
    
    var isUserAllowsNotifications: Bool {
        return notificationManager.isUserAllowsNotifications
    }
    
    var allowLimitExceededNotification: Bool {
        get {
            return notificationManager.allowLimitExceededNotification
        }
        set {
            notificationManager.allowLimitExceededNotification = newValue
        }
    }
    
    /// Flag determines if user allows reminding notifications
    var allowReminderNotification: Bool {
        get {
            return notificationManager.allowReminderNotification
        }
        set {
            notificationManager.allowReminderNotification = newValue
        }
    }
    
    /// Object that manages system notifications settings
    private let notificationManager: UserNotificationManagerProtocol
    
    //MARK: Initializer
    init(notificationManager: UserNotificationManagerProtocol) {
        self.notificationManager = notificationManager
    }
    
    //MARK: Methods
    func disableNotifications() {
        notificationManager.disableNotifications()
    }
    
    func enableNotifications(completionHandler: ((Bool, UNAuthorizationStatus) -> Void)?) {
        notificationManager.enableNotifications(completionHandler: completionHandler)
    }
}
