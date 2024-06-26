//
//  NotificationNavigationController.swift
//  SmokeApp
//
//  Created by Лев Куликов on 30.04.2023.
//

import Foundation
import UIKit
import SafariServices

/// Protocol for navigator for Account View
protocol AccountNavigatorProtocol {
    /// Shows Account settings view
    /// - Parameter presentationDelegate: Object that conforms to  UIViewControllerPresentationDelegate
    /// - Parameter accountDataStorage: AccountDataStorage object to inject in AccountSettings MVVM
    func toAccountSettings(presentationDelegate:  UIViewControllerPresentationDelegate?, accountDataStorage: AccountDataStorageProtocol)
    
    /// Shows Target View Controller
    /// - Parameters:
    ///   - targetOwner: Target owner to push in target view model
    ///   - dataStorage: Data storage to push in target view model
    func toTargetView(targetOwner: TargetOwnerProtocol, dataStorage: DataStorageProtocol)
    
    /// Presents Safari ViewController with provided URL String
    /// - Parameter urlString: string that can be converted into URL
    /// - Parameter failerHandler: Closer to handle failer request to open tab in Safari, clouser should accept String as a error message
    func toSafariLink(urlString: String, failerHandler: ((String) -> Void)?)
    
    /// Pushes Notications Settings View
    /// - Parameter notificationManager: Object that manages notification rules
    func toNotificationSettins(notificationManager: UserNotificationManagerProtocol)
    
    /// Pushes AppAppearance View
    func toAppAppearance()
    
    /// Pushes DataManage View
    func toDateManage(dataStorage: DataStorageProtocol)
}

final class AccountNavigator: AccountNavigatorProtocol {
    //MARK: Properties
    ///ViewController that is used to navigate
    unowned private let navigationController: UINavigationController?
    
    //MARK: Initializer
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    //MARK: Methods
    func toAccountSettings(presentationDelegate: UIViewControllerPresentationDelegate?, accountDataStorage: AccountDataStorageProtocol) {
        let accountSettingsVC = Assembler.shared
            .buildMVVMAccountSettingsViewController(
                accountDataStorage: accountDataStorage
            )
        accountSettingsVC.presentationDelegate = presentationDelegate
        accountSettingsVC.modalPresentationStyle = .overFullScreen
        navigationController?.viewControllers.first?.present(accountSettingsVC, animated: true)
    }
    
    func toTargetView(targetOwner: TargetOwnerProtocol, dataStorage: DataStorageProtocol) {
        let targetVC = Assembler.shared
            .buildMVVMTargetViewController(
                targetOwner: targetOwner,
                dataStorage: dataStorage
            )
        navigationController?.pushViewController(targetVC, animated: true)
    }
    
    func toSafariLink(urlString: String, failerHandler: ((String) -> Void)? = nil) {
        guard let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) else {
            failerHandler?("Incorrect URL")
            return
        }
        
        let safariVC = SFSafariViewController(url: url)
        safariVC.dismissButtonStyle = .close
        navigationController?.viewControllers.first?.present(safariVC, animated: true)
    }
    
    func toNotificationSettins(notificationManager: UserNotificationManagerProtocol) {
        let notificationVC = Assembler.shared
            .buildMVVMNotificationViewController(
                notificationManager: notificationManager
            )
        navigationController?.pushViewController(notificationVC, animated: true)
    }
    
    func toAppAppearance() {
        let appAppearanceVC = Assembler.shared.buildMVVMAppAppearanceViewController()
        navigationController?.pushViewController(appAppearanceVC, animated: true)
    }
    
    func toDateManage(dataStorage: DataStorageProtocol) {
        let dataManageVC = Assembler.shared.buildMVVMDataManageViewController(dataStorage: dataStorage)
        navigationController?.pushViewController(dataManageVC, animated: true)
    }
}
