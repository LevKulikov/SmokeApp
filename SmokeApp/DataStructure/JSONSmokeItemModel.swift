//
//  JSONSmokeItemModel.swift
//  SmokeApp
//
//  Created by Лев Куликов on 07.02.2023.
//

import Foundation

/// Struct to change data about smokeItem as JSON file between app and __widget__
struct SmokeItemData: Codable {
    public let date: Date
    public let amount: Int16
}
