//
//  SettingsAndLinks.swift
//  SmokeApp
//
//  Created by Лев Куликов on 30.04.2023.
//

import Foundation
import UIKit

/// Enumeration of links and contacts
enum ContactsAndLinks: String, CaseIterable {
    case appManual = "https://bloom-singer-26e.notion.site/Smoke-App-414c6f44231b4133b96e82a96cb54afa"
    case telegramChanel = "https://t.me/smokeup_test"
    
    static let appManualImage = UIImage(systemName: "doc.text.fill")
    static let telegramChanelImage = UIImage(systemName: "paperplane.fill")
}

/// Enumeration of available settings 
enum SettingsType: String, CaseIterable {
    case notifications = "Notifications"
    case appearance = "App appearance"
    
    static let notificationsImage = UIImage(systemName: "bell.badge.fill")
    static let appearanceImage = UIImage(systemName: "paintbrush.pointed.fill")
}
