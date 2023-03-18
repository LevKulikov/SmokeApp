//
//  Constants.swift
//  SmokeApp
//
//  Created by Лев Куликов on 30.01.2023.
//

import Foundation
import UIKit

/// Singleton class to store and share settings like backgroundColor and others
final class Constants {
    //MARK: Singleton instances
    /// Singleton instance
    public static let shared = Constants()
    /// Privatized initializer to force using singleton instance
    private init() {}
    
    //MARK: Properties
    public let viewControllerBackgroundColor = UIColor.systemBackground
    public let cellBackgroundColor = UIColor.systemGray5
    public let statisticsCellCornerRadius: CGFloat = 15
    public let averageDaysUserDefaultKey = "averageDaysUserDefaultKey"
    public let dynamicsDaysUserDefaultKey = "dynamicsDaysUserDefaultKey"
    public let targetUserDefaultKey = "targetUserDefaultKey"
}
