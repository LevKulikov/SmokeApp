//
//  Model.swift
//  SmokeApp
//
//  Created by Лев Куликов on 30.01.2023.
//

import Foundation

/// Enumeration of types for data manipulation
enum UpdateType {
    /// Identifies that new item was created and contains full new data
    case created([SmokeItem]?)
    /// Identifies that that item was updated and returns fully updated data
    case updated([SmokeItem]?)
    /// Identifies that that item was deleted and returns fully updated data
    case deleted([SmokeItem]?)
    /// Identifies that View Model was initialized
    case viewModelInitialized
    /// Identifies that error happened and provides ti
    case error(Error)
}

