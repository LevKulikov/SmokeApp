//
//  AccountViewModel.swift
//  SmokeApp
//
//  Created by Лев Куликов on 06.04.2023.
//

import Foundation

protocol AccountViewModelProtocol: AnyObject {
    /// Property to savety provide target storage to push it in another View Model
    var targetStorageToSet: TargetOwnerProtocol { get }
    
    /// Property to savety provide smoke data storage to push it in another View Model
    var dataStorageToSet: DataStorageProtocol { get }
    
    /// Property to provide account's name
    var accountName: String { get }
    
    /// Provides gender set by user
    var accountGender: Gender { get }
    
    /// Provide user's birth year (not date yet)
    var accountBirthYear: Int { get }
    
    /// Property to get image name, if it was set incorrectly (or it is unable to get data from image name) it provides default image name
    var accountImageData: Data? { get }
    
    /// Sets navigator to ViewModel. Should be used after setting UINavigatoinController to ViewController
    /// - Parameter navigator: Navigator object
    func setNavigator(_ navigator: AccountNavigator)
    
    /// Presents Account settings view
    /// - Parameter presentationDelegate: Object to conform UIViewControllerPresentationDelegate
    func toAccountSettings(presentationDelegate: UIViewControllerPresentationDelegate?)
    
    /// Pushes Target View Controller
    func toTargetView()
    
    /// Presents Safari ViewController with provided URL String
    /// - Parameter urlString: string that can be converted into URL
    /// - Parameter failerHandler: Closer to handle failer request to open tab in Safari, clouser should accept String as a error message
    func toSafariLink(urlString: String, failerHandler: ((String) -> Void)?)
    
    /// Pushes Notications Settings View
    func toNotificationSettins()
    
    /// Pushes AppAppearance View
    func toAppAppearance()
    
    /// Pushes DataManage View
    func toDateManage()
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
    
    var accountImageData: Data? {
        return accountDataStorage.accountImageData
    }
    
    var targetStorageToSet: TargetOwnerProtocol {
        return targetStorage
    }
    
    var dataStorageToSet: DataStorageProtocol {
        return dataStorage
    }
    
    /// Property to store account data storage object
    private let accountDataStorage: AccountDataStorageProtocol
    
    /// Property to store object, that stores smokes data
    private let dataStorage: DataStorageProtocol
    
    /// Property to store target storage protocol
    private let targetStorage: TargetOwnerProtocol
    
    /// Object to manage notifications
    private let notificationManager: UserNotificationManagerProtocol
    
    /// Object that navigates through views
    private var navigator: AccountNavigatorProtocol?
    
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
    func setNavigator(_ navigator: AccountNavigator) {
        self.navigator = navigator
    }
    
    func toAccountSettings(presentationDelegate: UIViewControllerPresentationDelegate?) {
        navigator?.toAccountSettings(presentationDelegate: presentationDelegate, accountDataStorage: accountDataStorage)
    }
    
    func toTargetView() {
        navigator?.toTargetView(targetOwner: targetStorage, dataStorage: dataStorage)
    }
    
    func toSafariLink(urlString: String, failerHandler: ((String) -> Void)?) {
        navigator?.toSafariLink(urlString: urlString, failerHandler: failerHandler)
    }
    
    func toNotificationSettins() {
        navigator?.toNotificationSettins(notificationManager: notificationManager)
    }
    
    func toAppAppearance() {
        navigator?.toAppAppearance()
    }
    
    func toDateManage() {
        navigator?.toDateManage(dataStorage: dataStorage)
    }
}
