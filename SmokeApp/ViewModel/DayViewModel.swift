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
}

/// View model for DayViewController
final class DayViewModel: DayViewModelProtocol {
    //MARK: Properties
    public var selectedSmokeItem: SmokeItem {
        return smokeItem
    }
    
    public var targetUpdate: ((Int16?) -> Void)?
    
    var isLimitExceeded: Bool {
        guard let limit = smokeItem.targetAmount as? Int16 else { return false }
        return smokeItem.amount > limit
    }
    
    /// Public property to store TargetOwner, it is identified only in DayViewModel and not avalble through DayViewModelProtocol
    public let targetOwner: TargetOwnerProtocol
    
    /// Contains data about SmokeItem from selected cell
    private let smokeItem: SmokeItem
    
    /// DataStorage abstract object to coordinate data in storage
    private let dataStorage: DataStorageProtocol
    
    //MARK: Initializer
    required init(smokeItem: SmokeItem, dataStorage: DataStorageProtocol, targetOwner: TargetOwnerProtocol) {
        self.smokeItem = smokeItem
        self.dataStorage = dataStorage
        self.targetOwner = targetOwner
        checkIfTargetNeedToSet()
    }
    
    //MARK: Methods
    public func updateSmokeItemCount(with count: Int16) {
        do{
            try dataStorage.updateDataItem(smokeItem, newDate: nil, newCount: count, targetAmount: nil)
        } catch {
            //TODO: Handle error
            print(error)
        }
    }
    
    /// Set closer to TargetOwner to bind with
    private func bindWithTargetOwner() {
        let bindingClosure: (Target?) -> Void = { [weak self] newTarget in
            guard let self else { return }
            guard let newTarget else {
                self.targetUpdate?(nil)
                return
            }
            
            switch newTarget.userTarget {
            case .dayLimit(from: _, smokes: let limit):
                try? self.dataStorage.updateDataItem(self.smokeItem, newDate: nil, newCount: nil, targetAmount: limit)
                self.targetUpdate?(limit)
            case .quitTime:
                let statisticsViewModel = StatisticsViewModel(dataStorage: self.dataStorage)
                let averageSmokes = Int16(statisticsViewModel.countAverageSmokesNumber())
                try? self.dataStorage.updateDataItem(self.smokeItem, newDate: nil, newCount: nil, targetAmount: averageSmokes)
                self.targetUpdate?(averageSmokes)
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
        
        guard let userTarget = targetOwner.userTarget?.userTarget else {
            try? dataStorage.deleteTargetForItem(smokeItem)
            return
        }
        
        if selectedSmokeItem.targetAmount == nil || (selectedSmokeItem.targetAmount as? Int)! < 0 {
            switch userTarget {
            case .dayLimit(from: _, smokes: let limit):
                try? dataStorage.updateDataItem(smokeItem, newDate: nil, newCount: nil, targetAmount: limit)
            case .quitTime:
                let statisticsViewModel = StatisticsViewModel(dataStorage: dataStorage)
                let averageSmokes = statisticsViewModel.countAverageSmokesNumber()
                try? dataStorage.updateDataItem(smokeItem, newDate: nil, newCount: nil, targetAmount: Int16(averageSmokes))
            }
        }
        bindWithTargetOwner()
    }
}
