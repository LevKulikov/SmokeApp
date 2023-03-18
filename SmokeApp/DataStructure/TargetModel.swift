//
//  TargetModel.swift
//  SmokeApp
//
//  Created by Лев Куликов on 17.02.2023.
//

import Foundation

/// Model to identify user's target
struct Target: Codable {
    /// Enumeration to identify target's type
    public enum TargetType: Codable {
        case dayLimit(from: Date, smokes: Int16)
        case quitTime(from: Date, days: Int16)
    }
    
    /// Property to set user's target
    public var userTarget: TargetType
}
