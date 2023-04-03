//
//  AccountViewModel.swift
//  SmokeApp
//
//  Created by Лев Куликов on 30.03.2023.
//

import Foundation

/// Protocol for Account View Model, that is available to manipulate account's name and image
protocol AccountViewModelProtocol: AnyObject, AccountImageManagerProtocol, AccountNameManagerProtocol {
    
}

final class AccountViewModel: AccountViewModelProtocol {
    //MARK: Properties
    var accountName: String {
        get {
            return accountDataStorage.accountName
        }
        set {
            accountDataStorage.accountName = newValue
        }
    }
    
    /// Property to store account data storage object
    private let accountDataStorage: AccountDataStorageProtocol
    
    /// Property to store object, that stores smokes data
    private let dataStorage: DataStorageProtocol
    
    /// Property to store target storage protocol
    private let targetStorage: TargetOwnerProtocol
    
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
    func setDefaultImageName() {
        accountDataStorage.setDefaultImageName()
    }
    
    func setAccountImageName(_ newImageName: String) {
        accountDataStorage.setAccountImageName(newImageName)
    }
}
