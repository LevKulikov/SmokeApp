//
//  SmokeItemData.swift
//  SmokeApp
//
//  Created by Лев Куликов on 19.02.2023.
//

import Foundation

/// Codable structure to conver SmokeItem into JSON file
struct SmokeItemData: Codable {
    public var date: Date?
    public var amount: Int16?
}
