//
//  Assembler.swift
//  SmokeApp
//
//  Created by Лев Куликов on 30.01.2023.
//

import Foundation
import UIKit

/// Singleton class that builds root view as TabBar controller with Navigation controller
final class Assembler {
    //MARK: Singleton instances
    /// Singleton instance
    static let shared = Assembler()
    
    /// Privatized initializer to force using singleton instance
    private init() {}
    
    //MARK: Methods
    /// Builds main TabBar with set ViewControllers with NavigationControllers and TubBarItem
    /// - Returns: built tabBar to set as root for window
    func buildMainTabBarController() -> UITabBarController {
        let dataStorage = DataStorage()
        let targetOwner = TargetOwner()
        let accountDataStorage = AccountDataStorage()
        let notificationManager = UserNotificationManager()
        
        let calendarViewController = buildMVVMCalendarViewController(
            dataStorage: dataStorage,
            targetOwner: targetOwner,
            notificationManager: notificationManager
        )
        let calendarNavCon = UINavigationController(rootViewController: calendarViewController)
        calendarNavCon.navigationBar.prefersLargeTitles = true
        calendarNavCon.navigationItem.largeTitleDisplayMode = .automatic
        calendarNavCon.tabBarItem = UITabBarItem(title: "Calendar", image: UIImage(systemName: "calendar"), tag: 0)
        
        let statisticsViewController = buildMVVMStatisticsViewController(dataStorage: dataStorage)
        let statisticsNavCon = UINavigationController(rootViewController: statisticsViewController)
        statisticsNavCon.navigationBar.prefersLargeTitles = true
        statisticsNavCon.navigationItem.largeTitleDisplayMode = .automatic
        statisticsNavCon.tabBarItem = UITabBarItem(title: "Statistics", image: UIImage(systemName: "chart.bar.xaxis"), tag: 1)
        
        let accountViewController = buildMVVMAccountViewController(
            accountDataStorage: accountDataStorage,
            targetOwner: targetOwner,
            dataStorage: dataStorage,
            notificationManager: notificationManager
        )
        let accountNavCon = UINavigationController(rootViewController: accountViewController)
        accountNavCon.navigationBar.prefersLargeTitles = true
        accountNavCon.navigationItem.largeTitleDisplayMode = .automatic
        accountNavCon.tabBarItem = UITabBarItem(title: "Account", image: UIImage(systemName: "person.circle.fill"), tag: 2)
        
        let tabBar = UITabBarController()
        tabBar.setViewControllers([calendarNavCon, statisticsNavCon, accountNavCon], animated: true)
        tabBar.delegate = calendarViewController as? CalendarViewController
        
        return tabBar
    }
    
    /// Returns Calendar View Controller with set MVVM elements like viewModel and model
    /// - Parameter dataStorage: DataStorage to set in viewModel
    /// - Parameter targetOwner: TargetOwner to set in ViewModel
    /// - Parameter notificationManager: Object that manages user's notifications
    /// - Returns: MVVM View Controller (CalendarViewController)
    func buildMVVMCalendarViewController(
        dataStorage: DataStorageProtocol,
        targetOwner: TargetOwnerProtocol,
        notificationManager: UserNotificationManagerProtocol
    ) -> UIViewController {
        let viewModel = CalendarViewModel(dataStorage: dataStorage, targetOwner: targetOwner, notificationManager: notificationManager)
        let viewController = CalendarViewController(viewModel: viewModel)
        return viewController
    }
    
    /// Returns Target ViewController with set MVVM elements like viewModel and model
    /// - Parameter targetOwner: TargetOwner to set in ViewModel
    /// - Parameter dataStorage: DataStorage to set in viewModel
    /// - Returns: MVVM View Controller (TargetViewController)
    func buildMVVMTargetViewController(
        targetOwner: TargetOwnerProtocol,
        dataStorage: DataStorageProtocol
    ) -> UIViewController {
        let viewModel = TargetViewModel(targetOwner: targetOwner, dataStorage: dataStorage)
        let viewController = TargetViewController(viewModel: viewModel)
        return viewController
    }
    
    /// Creates View Controller with information about one day smokes with ability to modify the data
    /// - Parameters:
    ///   - smokeItem: SmokeItem those information wil be displayed in DayViewContoller
    ///   - dataStorage: DataStorage from root ViewController to manipulate with data (update it)
    ///   - targetOwner: TargetOwner object to set in ViewModel
    ///   - notificationManager: Object that manages user's notifications
    /// - Returns: MVVM Day View Controller with set View Model and DataStorage
    func buildMVVMDayViewController(
        with smokeItem: SmokeItem,
        dataStorage: DataStorageProtocol,
        targetOwner: TargetOwnerProtocol,
        notificationManager: UserNotificationManagerProtocol
    ) -> UIViewController {
        let viewModel = DayViewModel(
            smokeItem: smokeItem,
            dataStorage: dataStorage,
            targetOwner: targetOwner,
            notificationManager: notificationManager
        )
        let viewController = DayViewController(viewModel: viewModel)
        return viewController
    }
    
    /// Creates Statistics View Controller with set MVVM elements like viewModel and model
    /// - Parameter dataStorage: DataStorage to set in viewModel
    /// - Returns: MVVM Statistics View Controller with set View Model and DataStorage
    func buildMVVMStatisticsViewController(dataStorage: DataStorageProtocol) -> UIViewController {
        let viewModel = StatisticsViewModel(dataStorage: dataStorage)
        let viewController = StatisticsViewController(viewModel: viewModel)
        return viewController
    }
    
    /// Creates Account View Controller with set MVVM elements like viewModel and model
    /// - Parameters:
    ///   - accountDataStorage: Object that srores account's data
    ///   - targetOwner: TargetOwner to set in ViewModel
    ///   - dataStorage: DataStorage to set in viewModel
    ///   - notificationManager: Object that manages user's notifications
    /// - Returns: MVVM Account View Controller with configurated View Model
    func buildMVVMAccountViewController(
        accountDataStorage: AccountDataStorageProtocol,
        targetOwner: TargetOwnerProtocol,
        dataStorage: DataStorageProtocol,
        notificationManager: UserNotificationManagerProtocol
    ) -> UIViewController {
        let viewModel = AccountViewModel(
            accountDataStorage: accountDataStorage,
            dataStorage: dataStorage,
            targetStorage: targetOwner,
            notificationManager: notificationManager
        )
        let viewController = AccountViewController(viewModel: viewModel)
        return viewController
    }
    
    /// Creates Account Settings View Controller with set MVVM elements like viewModel and model
    /// - Parameter accountDataStorage: Object that srores account's data
    /// - Returns: MVVM Account Settings View Controller with configurated View Model
    func buildMVVMAccountSettingsViewController(accountDataStorage: AccountDataStorageProtocol) -> UIViewController {
        let viewModel = AccountSettingsViewModel(accountDataStorage: accountDataStorage)
        let viewController = AccountSettingsViewController(viewModel: viewModel)
        return viewController
    }
    
    /// Creates Notification settings View Controller with set MVVM elements like viewModel and model
    /// - Parameter notificationManager: Object that manages user's notifications
    /// - Returns: MVVM Notification settings View Controller with configurated View Model
    func buildMVVMNotificationViewController(notificationManager: UserNotificationManagerProtocol) -> UIViewController {
        let viewModel = NotificationViewModel(notificationManager: notificationManager)
        let viewController = NotificationViewController(viewModel: viewModel)
        return viewController
    }
    
    /// Creates AppAppearance  View Controller with set MVVM elements like viewModel and model
    /// - Returns: MVVM AppAppearance  View Controller with configurated View Model
    func buildMVVMAppAppearanceViewController() -> UIViewController {
        let viewModel = AppAppearanceViewModel()
        let viewController = AppAppearanceViewController(viewModel: viewModel)
        return viewController
    }
}
