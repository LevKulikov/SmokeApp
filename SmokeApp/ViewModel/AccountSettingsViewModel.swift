//
//  AccountViewModel.swift
//  SmokeApp
//
//  Created by Лев Куликов on 30.03.2023.
//

import Foundation

/// Protocol for Account View Model, that is available to manipulate account's name and image
protocol AccountSettingsViewModelProtocol: AnyObject, AccountImageManagerProtocol, AccountInfoManagerProtocol {
    
}

final class AccountSettingsViewModel: AccountSettingsViewModelProtocol {
    //MARK: Properties
    /// Property to store account data storage object
    private let accountDataStorage: AccountDataStorageProtocol
    
    var accountName: String {
        get {
            return accountDataStorage.accountName
        }
        set {
            accountDataStorage.accountName = newValue
        }
    }
    
    var accountGender: Gender {
        get {
            return accountDataStorage.accountGender
        }
        set {
            accountDataStorage.accountGender = newValue
        }
    }
    
    var accountBirthYear: Int {
        get {
            return accountDataStorage.accountBirthYear
        }
        set {
            accountDataStorage.accountBirthYear = newValue
        }
    }
    
    var accountImageNameToSet: String {
        return accountDataStorage.accountImageNameToSet
    }
    
    //MARK: Initializer
    init(accountDataStorage: AccountDataStorageProtocol) {
        self.accountDataStorage = accountDataStorage
    }
    
    //MARK: Methods
    func setDefaultImageName() {
        accountDataStorage.setDefaultImageName()
    }
    
    func setAccountImageName(_ newImageName: String) {
        accountDataStorage.setAccountImageName(newImageName)
    }
}
