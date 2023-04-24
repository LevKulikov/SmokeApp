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
protocol AccountImageManagerProtocol: AnyObject {
    /// Property to store account's image data
    var accountImageData: Data? { get set }
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
    private let accountImageDataKey = "accountImageDataKey"
    
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
    
    static var maximumYear: Int {
        let calendar = Calendar.current
        guard let year = calendar.dateComponents([.year], from: Date.now).year else { return 0 }
        return year
    }
    
    static var minimumYear: Int {
        let minYear = maximumYear - 120
        guard minYear > 0 else { return 0 }
        return minYear
    }
    
    var accountImageData: Data? {
        didSet {
            UserDefaults.standard.setValue(accountImageData, forKey: accountImageDataKey)
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
    
    //MARK: Initializer
    init() {
        if let accNameStored = UserDefaults.standard.string(forKey: accountNameKey) {
            accountName = accNameStored
        } else {
            accountName = AccountDataStorage.defaultName
        }
        
        accountImageData = UserDefaults.standard.data(forKey: accountImageDataKey)
        
        if let accGenderString = UserDefaults.standard.string(forKey: genderKey), let accGender = Gender(rawValue: accGenderString) {
            accountGender = accGender
        } else {
            accountGender = AccountDataStorage.defaultGender
        }
        
        accountBirthYear = UserDefaults.standard.integer(forKey: birthYearKey)
    }
    
    //MARK: Methods
    
}
