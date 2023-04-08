//
//  AccountDataStorage.swift
//  SmokeApp
//
//  Created by Лев Куликов on 03.04.2023.
//

import Foundation

/// Enumeration with types of available genders to set in account info
enum Gender: String, CaseIterable {
    case male = "Male"
    case female = "Female"
    case nonbinary = "Nonbinary"
    case unidentified = "Unidentified"
}

/// Protocol for object that is able to manage account image data
protocol AccountImageManagerProtocol {
    /// Property to get image name, if it was set incorrectly (or it is unable to get data from image name) it provides default image name
    var accountImageNameToSet: String { get }
    
    /// Deletes custom image name and replaces it to default name
    func setDefaultImageName()
    
    /// Changes account image name to provided new one
    /// - Parameter newImageName: new account image name to set
    func setAccountImageName(_ newImageName: String)
}

/// Protocol for object that is able to manage account name data
protocol AccountInfoManagerProtocol: AnyObject {
    /// Property to store account's name
    var accountName: String { get set }
    
    /// Gender set by user
    var accountGender: Gender { get set }
    
    /// User's birth year (not date yet)
    var accountBirthYear: Int { get set }
}

/// Protocol for AccountDataStorage object
protocol AccountDataStorageProtocol: AnyObject, AccountImageManagerProtocol, AccountInfoManagerProtocol {
    
}

/// Object to store account's data, like name, image name and etc
final class AccountDataStorage: AccountDataStorageProtocol {
    //MARK: Properties
    /// Key for userDefaults to store accountImageName
    private let accountImageNameKey = "accountImageNameKey"
    
    /// Key for userDefaults to store accountName
    private let accountNameKey = "accountNameKey"
    
    /// Key for userDefaults to store account Gender
    private let genderKey = "genderKey"
    
    /// Key for userDefaults to store birthYear
    private let birthYearKey = "birthDateKey"
    
    /// Default  image `system` name for account photo, call with UIImage(systemName:)
    static let defaultImageName = "person.crop.circle"
    
    /// Default name for account
    static let defaultName = "SmokeApp User"
    
    /// Default gender for account
    static let defaultGender: Gender = .unidentified
    
    /// Default birth year, it is 0, which identifies that birth year is not set (unidentified)
    static let defaultBirthYear = 0
    
    /// Private property to store account's image name. It is recommended to not set any other string if you would like to delete image name, use setDefaultImageName() to do this properly
    private var accountImageName: String {
        didSet {
            UserDefaults.standard.setValue(accountImageName, forKey: accountImageNameKey)
        }
    }
    
    var accountName: String {
        didSet {
            UserDefaults.standard.setValue(accountName, forKey: accountNameKey)
        }
    }
    
    var accountGender: Gender {
        didSet {
            UserDefaults.standard.setValue(accountGender.rawValue, forKey: genderKey)
        }
    }
    
    var accountBirthYear: Int {
        didSet {
            UserDefaults.standard.setValue(accountBirthYear, forKey: birthYearKey)
        }
    }
    
    var accountImageNameToSet: String {
        guard accountImageName != AccountDataStorage.defaultImageName,
              let _ = Data(base64Encoded: accountImageName, options: .ignoreUnknownCharacters)
        else {
            return AccountDataStorage.defaultImageName
        }
        return accountImageName
    }
    
    //MARK: Initializer
    init() {
        if let accNameStored = UserDefaults.standard.string(forKey: accountNameKey) {
            accountName = accNameStored
        } else {
            accountName = AccountDataStorage.defaultName
        }
        
        if let accImageNameStored = UserDefaults.standard.string(forKey: accountImageNameKey) {
            accountImageName = accImageNameStored
        } else {
            accountImageName = AccountDataStorage.defaultImageName
        }
        
        if let accGenderString = UserDefaults.standard.string(forKey: genderKey), let accGender = Gender(rawValue: accGenderString) {
            accountGender = accGender
        } else {
            accountGender = AccountDataStorage.defaultGender
        }
        
        accountBirthYear = UserDefaults.standard.integer(forKey: genderKey)
    }
    
    //MARK: Methods
    func setDefaultImageName() {
        accountImageName = AccountDataStorage.defaultImageName
    }
    
    func setAccountImageName(_ newImageName: String) {
        accountImageName = newImageName
    }
}
