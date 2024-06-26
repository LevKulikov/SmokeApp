//
//  DataStorage.swift
//  SmokeApp
//
//  Created by Лев Куликов on 30.01.2023.
//

import Foundation
import UIKit

/// Protocol to provide object methods to manipulate with data
protocol DataManipulationProtocol {
    /// Creates and saves new SmokeItem
    /// - Parameters:
    ///   - date: date of the item
    ///   - count: count of the item
    func createItem(date: Date, count: Int16, targetLimit: Int16?) throws
    
    /// Provides all dataItems from storage
    /// - Returns: All DataItems
    func getDataItems() throws -> [SmokeItem]
    
    /// Updates existing data with new parameters
    /// - Parameters:
    ///   - item: item to update
    ///   - newDate: New data to update if it is needed
    ///   - newCount: New count of smokes to update if it is needed
    ///   - targetAmount:User's target to update if it is needed
    func updateDataItem(_ item: SmokeItem, newDate: Date?, newCount: Int16?, targetAmount: Int16?) throws
    
    /// Deletes provided item from storage
    /// - Parameter item: item to delete
    func deleteItem(_ item: SmokeItem) throws
    
    /// Deletes target for selected item
    /// - Parameter item: item where target should be deleted
    func deleteTargetForItem(_ item: SmokeItem) throws
    
    /// Deletes all saved items from storage
    func deleteAllItems() throws
}

/// Protocol to define DataStorage structure
protocol DataStorageProtocol: AnyObject, DataManipulationProtocol {
    /// Instanse to conviniently get data
    var savedData: [SmokeItem] { get set }
    /// Property for binding between Data Storage and Account TargetTableViewCell
    var updateTableCell: (([SmokeItem]?) -> Void)? { get set }
}

final class DataStorage: DataStorageProtocol {
    //MARK: Properties
    /// App context to manipulate with data
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var savedData: [SmokeItem] = []
    var updateTableCell: (([SmokeItem]?) -> Void)?
    
    //MARK: Initializer
    init() {
        let _ = try? getDataItems()
        fixDataStrorage()
    }
    
    //MARK: Methods
    func createItem(date: Date, count: Int16, targetLimit: Int16?) throws {
        let newItem = SmokeItem(context: context)
        newItem.date = date
        newItem.amount = count
        if let targetLimit {
            newItem.targetAmount = targetLimit as NSNumber
        }
        
        do {
            try context.save()
        } catch {
            throw error
        }
        pushInformationInUpdateClosure()
    }
    
    func getDataItems() throws -> [SmokeItem] {
        do {
            let data = try context.fetch(SmokeItem.fetchRequest())
            savedData = data
            return data
        } catch {
            throw error
        }
    }
    
    func updateDataItem(_ item: SmokeItem, newDate: Date?, newCount: Int16?, targetAmount: Int16?) throws {
        guard newDate != nil || newCount != nil || targetAmount != nil else {
            return
        }
        
        if let newDate {
            item.date = newDate
        }
        
        if let newCount {
            item.amount = newCount
        }
        
        if let targetAmount {
            item.targetAmount = targetAmount as NSNumber
        }
        
        do {
            try context.save()
        } catch {
            throw error
        }
        pushInformationInUpdateClosure()
    }
    
    func deleteTargetForItem(_ item: SmokeItem) throws {
        item.targetAmount = nil
        do {
            try context.save()
        } catch {
            throw error
        }
        pushInformationInUpdateClosure()
    }
    
    func deleteItem(_ item: SmokeItem) throws {
        context.delete(item)
        
        do {
            try context.save()
        } catch {
            throw error
        }
        pushInformationInUpdateClosure()
    }
    
    func deleteAllItems() throws {
        do {
            var lastSavedData = try getDataItems()
            try updateDataItem(lastSavedData.removeLast(), newDate: nil, newCount: 0, targetAmount: nil)
            lastSavedData.forEach { item in
                context.delete(item)
            }
            try context.save()
        } catch {
            throw error
        }
    }
    
    /// Method that removes duplicates from contex if there is any
    private func fixDataStrorage() {
        let data = try! context.fetch(SmokeItem.fetchRequest())
        let uniqueData = data.uniqued { item in
            let calendar = Calendar.current
            return calendar.dateComponents([.day, .month, .year], from: item.date!)
        }
        
        let dataSet = Set(data)
        let uniqSet = Set(uniqueData)
        let duplicatedSet = dataSet.symmetricDifference(uniqSet)
        
        for data in duplicatedSet {
            try? deleteItem(data)
        }
    }
    
    private func pushInformationInUpdateClosure() {
        do {
            updateTableCell?(try getDataItems())
        } catch {
            print(error)
            updateTableCell?(nil)
        }
    }
}

