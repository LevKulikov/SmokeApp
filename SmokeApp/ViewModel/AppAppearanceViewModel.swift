//
//  AppAppearanceViewModel.swift
//  SmokeApp
//
//  Created by Лев Куликов on 19.05.2023.
//

import Foundation

/// ViewModel for AppAppearance ViewController
protocol AppAppearanceViewModelProtocol: AnyObject {
    /// Returns Int value describing app appearance mode that is set by user
    /// - Returns: app appearance mode rawValue
    func getCurrentAppearanceModeInt() -> Int
    
    /// Sets and saves app mode to provided raw Value of UIUserInterfaceStyle
    /// - Parameter rawValue: raw value of UIUserInterfaceStyle that should be set and changed (must be from 0 to 2, otherwise app mode won't be changed)
    func setAppMode(to rawValue: Int)
}

final class AppAppearanceViewModel: AppAppearanceViewModelProtocol {
    //MARK: Properties
    
    //MARK: Methods
    func getCurrentAppearanceModeInt() -> Int {
        return AppAppearanceManager.shared.savedAppModeInt
    }
    
    func setAppMode(to rawValue: Int) {
        AppAppearanceManager.shared.setAppMode(to: rawValue)
    }
}
