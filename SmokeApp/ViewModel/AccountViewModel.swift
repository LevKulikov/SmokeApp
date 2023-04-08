//
//  AccountViewModel.swift
//  SmokeApp
//
//  Created by Лев Куликов on 06.04.2023.
//

import Foundation

protocol AccountViewModelProtocol: AnyObject {
    //TODO: Set target update to bind
    
    /// Property to savety provide account data storage to push it in another View Model
    var accountDataStorageToSet: AccountDataStorageProtocol { get }
    
    /// Property to provide account's name
    var accountName: String { get }
    
    /// Provides gender set by user
    var accountGender: Gender { get }
    
    /// Provide user's birth year (not date yet)
    var accountBirthYear: Int { get }
    
    /// Property to get image name, if it was set incorrectly (or it is unable to get data from image name) it provides default image name
    var accountImageNameToSet: String { get }
}

final class AccountViewModel: AccountViewModelProtocol {
    //MARK: Properties
    var accountName: String {
            return accountDataStorage.accountName
    }
    
    var accountGender: Gender {
            return accountDataStorage.accountGender
    }
    
    var accountBirthYear: Int {
            return accountDataStorage.accountBirthYear
    }
    
    var accountImageNameToSet: String {
        return accountDataStorage.accountImageNameToSet
    }
    
    var accountDataStorageToSet: AccountDataStorageProtocol {
        return accountDataStorage
    }
    
    /// Property to store account data storage object
    private let accountDataStorage: AccountDataStorageProtocol
    
    /// Property to store object, that stores smokes data
    private let dataStorage: DataStorageProtocol
    
    /// Property to store target storage protocol
    private let targetStorage: TargetOwnerProtocol
    
    /// Object to manage notifications
    private let notificationManager: UserNotificationManagerProtocol
    
    //MARK: Initializer
    init(
        accountDataStorage: AccountDataStorageProtocol,
        dataStorage: DataStorageProtocol,
        targetStorage: TargetOwnerProtocol,
        notificationManager: UserNotificationManagerProtocol
    ) {
        self.accountDataStorage = accountDataStorage
        self.dataStorage = dataStorage
        self.targetStorage = targetStorage
        self.notificationManager = notificationManager
    }
    
    //MARK: Methods
 
}
