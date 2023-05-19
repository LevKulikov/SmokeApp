//
//  AppAppearanceManager.swift
//  SmokeApp
//
//  Created by Лев Куликов on 19.05.2023.
//

import Foundation
import UIKit

/// Class that manages how app should be look like (for example dark, light or system mode).
/// `WARNING`: this is singleton object and can be accessed anywhere, so be careful and try not to use it in plases that are not designed for it
final class AppAppearanceManager {
    //MARK: Singletop
    static var shared = AppAppearanceManager()
    private init() {}
    
    //MARK: Properties
    /// Window for all scenes to controll global app appearance. It is needed to set firstly before changing appearance
    weak var keyWindow: UIWindow? {
        didSet {
            let savedModeInt = UserDefaults.standard.integer(forKey: appModeKey)
            if let savedMode = UIUserInterfaceStyle(rawValue: savedModeInt) {
                keyWindow?.overrideUserInterfaceStyle = savedMode
            }
        }
    }
    
    /// Returns number that indicates saved by user app mode
    var savedAppModeInt: Int {
        return keyWindow?.overrideUserInterfaceStyle.rawValue ?? 0
    }
    
    /// Key for userDefaults to store set app mode (light, dark, unspecified)
    private let appModeKey = "appModeKey"
    
    //MARK: Methods
    /// Sets and saves app mode to provided UIUserInterfaceStyle
    /// - Parameter mode: app mode that should be set and saved
    func setAppMode(to mode: UIUserInterfaceStyle) {
        UserDefaults.standard.setValue(mode.rawValue, forKey: appModeKey)
        UIView.animate(withDuration: 0.5) {
            self.keyWindow?.overrideUserInterfaceStyle = mode
        }
    }
    
    /// Sets and saves app mode to provided raw Value of UIUserInterfaceStyle
    /// - Parameter rawValue: raw value of UIUserInterfaceStyle that should be set and changed (must be from 0 to 2, otherwise app mode won't be changed)
    func setAppMode(to rawValue: Int) {
        guard let newMode = UIUserInterfaceStyle(rawValue: rawValue) else { return }
        setAppMode(to: newMode)
    }
}
