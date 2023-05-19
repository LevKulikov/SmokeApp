//
//  DayViewModel.swift
//  SmokeApp
//
//  Created by Лев Куликов on 01.02.2023.
//

import Foundation

protocol DayViewModelProtocol: AnyObject {
    /// Public instance to securly get smokeItem from View Model
    var selectedSmokeItem: SmokeItem { get }
    
    /// Binding with DayView to provide target updates
    var targetUpdate: ((Int16?) -> Void)? { get set }
    
    /// Value to identify if limit is exceeded. If target limit is not set, it returns false. **Use only at the opening of the ViewController**
    var isLimitExceeded: Bool { get }
    
    /// Updates stored SmokeItem with provided count
    /// - Parameter count: count to set in SmokeItem
    func updateSmokeItemCount(with count: Int16)
    
    /// Send notification if limit is exeeded
    func dispatchLimitExceedNotification()
}

/// View model for DayViewController
final class DayViewModel: DayViewModelProtocol {
    //MARK: Properties
    var selectedSmokeItem: SmokeItem {
        return smokeItem
    }
    
    var targetUpdate: ((Int16?) -> Void)?
    
    var isLimitExceeded: Bool {
        guard let limit = smokeItem.targetAmount as? Int16, limit >= 0 else { return false }
        return smokeItem.amount > limit
    }
    
    /// Flag that identifies that selected day is the latest one, default is false
    private var isLatestDay: Bool = false
    
    /// Public property to store TargetOwner, it is identified only in DayViewModel and not avalble through DayViewModelProtocol
    public let targetOwner: TargetOwnerProtocol
    
    /// Contains data about SmokeItem from selected cell
    private let smokeItem: SmokeItem
    
    /// DataStorage abstract object to coordinate data in storage
    private let dataStorage: DataStorageProtocol
    
    /// Object to manage notifications
    private let notificationManager: UserNotificationManagerProtocol
    
    //MARK: Initializer
    required init(smokeItem: SmokeItem, dataStorage: DataStorageProtocol, targetOwner: TargetOwnerProtocol, notificationManager: UserNotificationManagerProtocol) {
        self.smokeItem = smokeItem
        self.dataStorage = dataStorage
        self.targetOwner = targetOwner
        self.notificationManager = notificationManager
        checkIfTargetNeedToSet()
    }
    
    //MARK: Methods
    func updateSmokeItemCount(with count: Int16) {
        do{
            try dataStorage.updateDataItem(smokeItem, newDate: nil, newCount: count, targetAmount: nil)
        } catch {
            //TODO: Handle error
            print(error)
        }
    }
    
    func dispatchLimitExceedNotification() {
        guard isLatestDay, let target = smokeItem.targetAmount as? Int16 else { return }
        notificationManager.dispatchLimitExceedNotification(limit: target)
    }
    
    /// Set closer to TargetOwner to bind with
    private func bindWithTargetOwner() {
        let bindingClosure: (Target?) -> Void = { [weak self] newTarget in
            guard let self else { return }
            guard let newTarget else {
                try? self.dataStorage.deleteTargetForItem(self.smokeItem)
                self.targetUpdate?(nil)
                return
            }
            
            switch newTarget.userTarget {
            case .dayLimit(from: _, smokes: let limit):
                try? self.dataStorage.updateDataItem(self.smokeItem, newDate: nil, newCount: nil, targetAmount: limit)
                self.targetUpdate?(limit)
            case .quitTime(from: _, days: _, initialLimit: let limit):
                try? self.dataStorage.updateDataItem(self.smokeItem, newDate: nil, newCount: nil, targetAmount: limit)
                self.targetUpdate?(limit)
            }
        }
        
        targetOwner.targetUpdateDayView = bindingClosure
    }
    
    /// Checks if there is target set by user and it is not set in the **last** SmokeItem
    private func checkIfTargetNeedToSet() {
        let calendar = Calendar.current
        let currentDate = calendar.dateComponents([.year, .month, .day], from: Date.now)
        let smokeDate = calendar.dateComponents([.year, .month, .day], from: smokeItem.date!)
        guard currentDate == smokeDate else { return }
        bindWithTargetOwner()
        isLatestDay = true
        
        guard let userTarget = targetOwner.userTarget?.userTarget else {
            try? dataStorage.deleteTargetForItem(smokeItem)
            return
        }
        
        if selectedSmokeItem.targetAmount == nil || (selectedSmokeItem.targetAmount as? Int)! < 0 {
            switch userTarget {
            case .dayLimit(from: _, smokes: let limit):
                try? dataStorage.updateDataItem(smokeItem, newDate: nil, newCount: nil, targetAmount: limit)
            case .quitTime(from: _, days: _, initialLimit: let limit):
                try? dataStorage.updateDataItem(smokeItem, newDate: nil, newCount: nil, targetAmount: limit)
            }
        }
    }
}
