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
    /// Notifications are permited in phone settings
    var isSystemAllowsNotifications: Bool { get }
    
    /// If user wants to get notifications
    var isUserAllowsNotifications: Bool { get }
    
    /// Flag determines if user allows notifications about limit exceed
    var allowLimitExceededNotification: Bool { get set }
    
    /// Flag determines if user allows reminding notifications
    var allowReminderNotification: Bool { get set }
    
    /// Checks status of notification permision by a system
    func checkForSystemNotificationPermition()
    
    /// Sends in the queue notification about limit exceeded
    /// - Parameter limit: set limit that was exceeded
    func dispatchLimitExceedNotification(limit: Int16?)
    
    /// Sends in the queue repeatable notification with reminder
    func dispatchReminderNotification()
    
    /// Disables notifications
    func disableNotifications()
    
    /// Undispatches (but not disables) limit exeeded notifications. Use in case if you need to disable future notification about exeeding limit when target has been deleted after limit exeed
    func undispatchLimitExeedNotifications()
    
    /// Properly enables app notifications through asking system for permition and asking user to provide permition if system provides that this setting is not determined or denied
    /// - Parameter completionHandler: Handler that is executed after notifications are permitid, parameter of this closure determines if notifications are permited or not, and what is authorization status
    func enableNotifications(completionHandler: ((Bool, UNAuthorizationStatus) -> Void)?)
}

/// Class to manage user's notifications
final class UserNotificationManager: UserNotificationManagerProtocol {
    /// Types of notifications that is available to set
    enum NotificationSettingsType: CaseIterable {
        case allowDismisSetting
        case limitExceededNotification
        case reminderNotification
    }
    
    //MARK: Properties
    var isSystemAllowsNotifications: Bool {
        guard let systemNotifPermition else { return false }
        return systemNotifPermition
    }
    
    var isUserAllowsNotifications: Bool {
        return userNotifPermition
    }
    
    var allowLimitExceededNotification: Bool {
        didSet {
            UserDefaults.standard.setValue(allowLimitExceededNotification, forKey: allowLimitExceededKey)
            switch allowLimitExceededNotification {
            case true:
                break
            case false:
                notificationCenter.removePendingNotificationRequests(withIdentifiers: [limitExceedNotificationIdentifier])
            }
        }
    }
    
    var allowReminderNotification: Bool {
        didSet {
            UserDefaults.standard.setValue(allowReminderNotification, forKey: allowReminderKey)
            switch allowReminderNotification {
            case true:
                dispatchReminderNotification()
            case false:
                notificationCenter.removePendingNotificationRequests(withIdentifiers: [reminderNotificationIdentifier])
            }
        }
    }
    
    /// Internal property to keep info if systems allows app notifications
    private var systemNotifPermition: Bool?
    
    /// Internal property to keep info if user allows app notifications
    private var userNotifPermition: Bool {
        didSet {
            UserDefaults.standard.setValue(userNotifPermition, forKey: userNotifPermitionKey)
            switch userNotifPermition {
            case true:
                if allowReminderNotification {
                    dispatchReminderNotification()
                }
            case false:
                notificationCenter.removeAllPendingNotificationRequests()
            }
        }
    }
    
    /// Key for userDefault to store user permition
    private let userNotifPermitionKey = "userNotigPermitionKey"
    
    /// Key for userDefault to store limit exceeded permition
    private let allowLimitExceededKey = "allowLimitExceededKey"
    
    /// Key for userDefault to store reminder notif permition
    private let allowReminderKey = "allowReminderKey"
    
    /// Current User Notification center
    private let notificationCenter: UNUserNotificationCenter
    
    /// Identifier for notification when limit is exceeded
    private let limitExceedNotificationIdentifier = "limitExceedNotificationIdentifier"
    
    /// Identifier for notification reminder
    private let reminderNotificationIdentifier = "reminderNotificationIdentifier"
    
    //MARK: Initalizer
    init() {
        notificationCenter = UNUserNotificationCenter.current()
        userNotifPermition = UserDefaults.standard.value(forKey: userNotifPermitionKey) as? Bool ?? true
        allowLimitExceededNotification = UserDefaults.standard.value(forKey: allowLimitExceededKey) as? Bool ?? true
        allowReminderNotification = UserDefaults.standard.value(forKey: allowReminderKey) as? Bool ?? true
        checkForSystemNotificationPermition()
    }
    
    //MARK: Methods
    func checkForSystemNotificationPermition() {
        notificationCenter.getNotificationSettings { [weak self] notificationSettings in
            switch notificationSettings.authorizationStatus {
            case .authorized, .provisional:
                self?.systemNotifPermition = true
            case .notDetermined:
                self?.notificationCenter.requestAuthorization(options: .alert) { didAllow, _ in
                    self?.systemNotifPermition = didAllow
                }
            default:
                self?.systemNotifPermition = false
            }
        }
    }
    
    func disableNotifications() {
        userNotifPermition = false
    }
    
    func undispatchLimitExeedNotifications() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [limitExceedNotificationIdentifier])
    }
    
    func enableNotifications(completionHandler: ((Bool, UNAuthorizationStatus) -> Void)?) {
        notificationCenter.getNotificationSettings { [weak self] notificationSettings in
            switch notificationSettings.authorizationStatus {
            case .authorized, .provisional:
                self?.systemNotifPermition = true
                self?.userNotifPermition = true
                completionHandler?(true, .authorized)
            case .denied:
                self?.systemNotifPermition = false
                self?.userNotifPermition = false
                completionHandler?(false, .denied)
            default:
                self?.notificationCenter.requestAuthorization(options: .alert) { didAllow, error in
                    self?.systemNotifPermition = didAllow
                    self?.userNotifPermition = didAllow
                    completionHandler?(didAllow, .notDetermined)
                }
            }
        }
    }
    
    func dispatchLimitExceedNotification(limit: Int16? = nil) {
        guard let systemNotifPermition, systemNotifPermition, userNotifPermition, allowLimitExceededNotification else { return }
        
        let title = "🛑 You exceeded your limit"
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
        var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: date)
        dateComponents.minute! += 10
        
        let triger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(
            identifier: limitExceedNotificationIdentifier,
            content: content,
            trigger: triger
        )
        
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [limitExceedNotificationIdentifier])
        notificationCenter.add(request)
    }
    
    func dispatchReminderNotification() {
        guard let systemNotifPermition, systemNotifPermition, userNotifPermition, allowReminderNotification else { return }
        
        let title = "🔆 You can do it!"
        let body = "New day! Try to smoke less!"
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let dateComponents = DateComponents(hour: 10, minute: 0)
        let triger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: reminderNotificationIdentifier,
            content: content,
            trigger: triger
        )
        
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [reminderNotificationIdentifier])
        notificationCenter.add(request)
    }
}
