//
//  AccountDataStorage.swift
//  SmokeApp
//
//  Created by Лев Куликов on 03.04.2023.
//

import Foundation

/// Protocol for object that is able to manage account image data
protocol AccountImageManagerProtocol {
    /// Deletes custom image name and replaces it to default name
    func setDefaultImageName()
    
    /// Changes account image name to provided new one
    /// - Parameter newImageName: new account image name to set
    func setAccountImageName(_ newImageName: String)
}

/// Protocol for object that is able to manage account name data
protocol AccountNameManagerProtocol: AnyObject {
    /// Property to store account's name
    var accountName: String { get set }
}

/// Protocol for AccountDataStorage object
protocol AccountDataStorageProtocol: AnyObject, AccountImageManagerProtocol, AccountNameManagerProtocol {
    
}

/// Object to store account's data, like name, image name and etc
final class AccountDataStorage: AccountDataStorageProtocol {
    //MARK: Properties
    /// Key for userDefaults to store accountImageName
    private let accountImageNameKey = "accountImageNameKey"
    /// Key for userDefaults to store accountName
    private let accountNameKey = "accountNameKey"
    /// Default image name for account photo
    let defaultImageName = "person.crop.circle"
    /// Default name for account
    let defaultName = "SmokeApp User"
    /// Private property to store account's image name. It is recommended to not set any other string if you would like to delete image name, use setDefaultImageName() to do this properly
    private var accountImageName: String {
        didSet {
            guard accountImageName != defaultImageName else {
                return
            }
            UserDefaults.standard.setValue(accountImageName, forKey: accountImageNameKey)
        }
    }
    var accountName: String {
        didSet {
            guard accountName != defaultName else {
                return
            }
            UserDefaults.standard.setValue(accountName, forKey: accountNameKey)
        }
    }
    /// Property to get image name, if it was set incorrectly (or it is unable to get data from image name) it provides default image name
    var accountImageNameToSet: String {
        guard accountImageName != defaultImageName,
              let _ = Data(base64Encoded: accountImageName, options: .ignoreUnknownCharacters)
        else {
            return defaultImageName
        }
        return accountImageName
    }
    
    //MARK: Initializer
    init() {
        if let accNameStored = UserDefaults.standard.string(forKey: accountNameKey) {
            accountName = accNameStored
        } else {
            accountName = defaultName
        }
        
        if let accImageNameStored = UserDefaults.standard.string(forKey: accountImageNameKey) {
            accountImageName = accImageNameStored
        } else {
            accountImageName = defaultImageName
        }
    }
    
    //MARK: Methods
    func setDefaultImageName() {
        accountImageName = defaultImageName
    }
    
    func setAccountImageName(_ newImageName: String) {
        accountImageName = newImageName
    }
}
