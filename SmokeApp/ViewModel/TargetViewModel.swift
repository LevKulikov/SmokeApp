//
//  TargetViewModel.swift
//  SmokeApp
//
//  Created by Лев Куликов on 17.02.2023.
//

import Foundation

/// Protocol for TargetViewModel
protocol TargetViewModelProtocol: AnyObject, TargetManipulationProtocol {
    /// Return user's target if it is set
    var target: Target? { get }
    /// Required initializer to set Target Storage in the class
    /// - Parameter targetStorage: TargetStorage to set, that can be an item that conforms to TargetStorageProtocol
    init(targetOwner: TargetOwnerProtocol, dataStorage: DataStorageProtocol)
    
    /// Returns all time minimal count of smokes except 0, if there is any
    /// - Returns: All time minimal count of smokes (not 0), or nil if there is not enough data
    func getAllTimeMinimalSmokes() -> Int16?
    
    /// Counts days those are left to quit smoking
    /// - Returns: Left days
    func countLeftDaysToQuitSmoking() -> Int16?
    
    /// Calculates performance/fulfilment by user of current target
    /// - Returns: Proportion of target fulfilment
    func currentTargetPerformance() -> Float?
}

/// View Model for TargetViewController to filful required method
final class TargetViewModel: TargetViewModelProtocol {
    //MARK: Properties
    public var target: Target? {
        targetOwner.userTarget
    }
    
    ///Propery to store TargetStorage object
    private let targetOwner: TargetOwnerProtocol
    
    ///Propery to store DataStorage object
    private let dataStorage: DataStorageProtocol
    
    //MARK: Initializers
    required init(targetOwner: TargetOwnerProtocol, dataStorage: DataStorageProtocol) {
        self.targetOwner = targetOwner
        self.dataStorage = dataStorage
    }
    
    //MARK: Methdos
    public func setNewTarget(_ target: Target) {
        targetOwner.setNewTarget(target)
    }
    
    public func deleteTarget() {
        targetOwner.deleteTarget()
    }
    
    public func getAllTimeMinimalSmokes() -> Int16? {
        let allData = dataStorage.savedData
        // Seachs minimal value except zero values and the last one, because last value does not set finally
        let intData = allData.dropLast(1).compactMap { $0.amount }.filter { $0 != 0 }
        guard let minValue = intData.min() else {
            return nil
        }
        return minValue
    }
    
    public func countLeftDaysToQuitSmoking() -> Int16? {
        guard let target else {
            return nil
        }
        switch target.userTarget {
        case .quitTime(from: let startDate, days: let days, initialLimit: _):
            let calendar = Calendar.current
            let currentDate = calendar.startOfDay(for: Date.now)
            let fromStartDate = calendar.startOfDay(for: startDate)
            guard let daysPassed = calendar.dateComponents([.day], from: fromStartDate, to: currentDate).day, daysPassed >= 0 else {
                return nil
            }
            let daysLeft = days - Int16(daysPassed)
            return daysLeft
            
        default:
            break
        }
        return nil
    }
    
    public func currentTargetPerformance() -> Float? {
        guard let target else {
            return nil
        }
        
        var startDate: Date
        switch target.userTarget {
        case .quitTime(from: let date, days: _, initialLimit: _):
            startDate = date
        case .dayLimit(from: let date, smokes: _):
            startDate = date
        }
        
        let calendar = Calendar.current
        let startDateStart = calendar.startOfDay(for: startDate)
        guard let smokeItemsWithCurrentTarget = try? dataStorage.getDataItems().filter ({
            guard let days = calendar
                .dateComponents(
                    [.day],
                    from: startDateStart,
                    to: calendar.startOfDay(for: $0.date!)
                ).day else { return false }
            return days >= 0
        }) else {
            return nil
        }
        
        let targetLimitSum = smokeItemsWithCurrentTarget
            .compactMap({ $0.targetAmount as? Float })
            .reduce(0, +)
        
        let smokesSum = smokeItemsWithCurrentTarget
            .map({ Float($0.amount) })
            .reduce(0, +)
        
        guard targetLimitSum > 0, smokesSum > 0 else {
            let result: Float = smokesSum > 0 ? -1 : +1
            return result
        }
        
        let result = (targetLimitSum/smokesSum)
        let rounded = Float(Int(result * 100))/100
    
        return rounded
    }
}
