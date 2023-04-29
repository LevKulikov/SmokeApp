//
//  TargetStorage.swift
//  SmokeApp
//
//  Created by Лев Куликов on 17.02.2023.
//

import Foundation

/// Protocol 
protocol TargetManipulationProtocol {
    /// Sets new user's target
    /// - Parameter target: new target to set
    func setNewTarget(_ target: Target)
    
    /// Permanetly deletes previously set user's target
    func deleteTarget()
}

/// Protocol for cass to store user's target
protocol TargetStorageProtocol {
    /// Safely provides user's target
    var userTarget: Target? { get }
}

/// Protocol to combine target protocols
protocol TargetOwnerProtocol: AnyObject, TargetStorageProtocol, TargetManipulationProtocol {
    /// Property to bind with DayViewModel that indicates target is update
    var targetUpdateDayView: ((Target?) -> Void)? { get set }
    
    /// Property to bind with TargetTableViewCell that indicates target is update
    var targetUpdateAccountCell: ((Target?) -> Void)? { get set }
}

/// Class to store set by user target and push it to other View Models
final class TargetOwner: TargetOwnerProtocol {
    //MARK: Properties
    var userTarget: Target? {
        return target
    }
    
    var targetUpdateDayView: ((Target?) -> Void)?
    
    var targetUpdateAccountCell: ((Target?) -> Void)?
    
    /// Private propety to manipulate with target inside the class
    private var target: Target? {
        didSet {
            let targetData = try? JSONEncoder().encode(target)
            UserDefaults.standard.set(targetData, forKey: Constants.shared.targetUserDefaultKey)
        }
    }
    
    //MARK: Initializer
    /// Initializer sets target object from UserDefaults
    init() {
        guard let targetData = UserDefaults.standard.data(forKey: Constants.shared.targetUserDefaultKey) else { return }
        target = try? JSONDecoder().decode(Target.self, from: targetData)
    }
    
    //MARK: Methods
    func setNewTarget(_ target: Target) {
        self.target = target
        targetUpdateDayView?(target)
        targetUpdateAccountCell?(target)
    }
    
    func deleteTarget() {
        self.target = nil
        targetUpdateDayView?(nil)
        targetUpdateAccountCell?(nil)
    }
}
