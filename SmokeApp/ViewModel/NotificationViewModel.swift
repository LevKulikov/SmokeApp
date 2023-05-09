//
//  NotificationViewModel.swift
//  SmokeApp
//
//  Created by Лев Куликов on 30.04.2023.
//

import Foundation

protocol NotificationViewModelProtocol: AnyObject {
    
}

final class NotificationViewModel: NotificationViewModelProtocol {
    //MARK: Propeties
    private let notificationManager: UserNotificationManagerProtocol
    
    //MARK: Initializer
    init(notificationManager: UserNotificationManagerProtocol) {
        self.notificationManager = notificationManager
    }
    
    //MARK: Methods
}
