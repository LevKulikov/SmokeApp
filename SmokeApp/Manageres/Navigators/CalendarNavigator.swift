//
//  CalendarNavigator.swift
//  SmokeApp
//
//  Created by Лев Куликов on 19.05.2023.
//

import Foundation
import UIKit

/// Protocol for class object to navigate callendar View
protocol CalendarNavigatorProtocol: AnyObject {
    /// Pushes DayViewController
    /// - Parameters:
    ///   - smokeItem: SmokeItem those information wil be displayed in DayViewContoller
    ///   - dataStorage: DataStorage from root ViewController to manipulate with data
    ///   - targetOwner: TargetOwner object to set in ViewModel
    ///   - notificationManager: Object that manages user's notifications
    func toSelectedDay(
        smokeItem: SmokeItem,
        dataStorage: DataStorageProtocol,
        targetOwner: TargetOwnerProtocol,
        notificationManager: UserNotificationManagerProtocol
    )
}

final class CalendarNavigator: CalendarNavigatorProtocol {
    //MARK: Properties
    /// Navigation controller of the view to make pushes and pops
    private let navigationController: UINavigationController?
    
    //MARK: Initializer
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    //MARK: Methods
    func toSelectedDay(
        smokeItem: SmokeItem,
        dataStorage: DataStorageProtocol,
        targetOwner: TargetOwnerProtocol,
        notificationManager: UserNotificationManagerProtocol
    ) {
        let viewController = Assembler
            .shared
            .buildMVVMDayViewController(
                with: smokeItem,
                dataStorage: dataStorage,
                targetOwner: targetOwner,
                notificationManager: notificationManager
            )
        navigationController?.pushViewController(viewController, animated: true)
    }
}
