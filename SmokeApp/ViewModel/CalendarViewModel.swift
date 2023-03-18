//
//  CalendarViewModel.swift
//  SmokeApp
//
//  Created by Лев Куликов on 30.01.2023.
//

import Foundation

/// Calendar ViewModel protocol for unit tests
protocol CalendarViewModelProtocol: AnyObject, DataManipulationProtocol {
    /// Closure to bind DataItem with View, additionally it calls .viewModelInitialized by state observer didSet
    var updateViewData: ((UpdateType) -> Void)? { get set }
    
    /// Convinient way to get data without calling method with context recalculation
    var savedData: [SmokeItem] { get }
    
    /// Public instance to securly get Data Storage from View Model
    var dataStorageToPush: DataStorageProtocol { get }
    
    /// Property to store target owner
    var targetOwner: TargetOwnerProtocol { get }
    
    /// Creates new DataItem for every new date
    func autoNewDateCreateItem()
}

/// Calendar VIewModel class
final class CalendarViewModel: CalendarViewModelProtocol {
    //MARK: Properties
    public var updateViewData: ((UpdateType) -> Void)? {
        didSet {
            updateViewData?(.viewModelInitialized)
        }
    }
    
    public var savedData: [SmokeItem] {
        get {
            return dataStorage.savedData
        }
    }
    
    public var dataStorageToPush: DataStorageProtocol {
        return dataStorage
    }
    
    public let targetOwner: TargetOwnerProtocol
    
    /// DataStorage abstract object to coordinate data in storage
    private let dataStorage: DataStorageProtocol
    
    //MARK: Initializer
    public init(dataStorage: DataStorageProtocol, targetOwner: TargetOwnerProtocol) {
        self.dataStorage = dataStorage
        self.targetOwner = targetOwner
        autoNewDateCreateItem()
    }
    
    //MARK: Methods
    /// Counts smoke limit for specific SmokeItem
    /// - Parameters:
    ///   - fromDate: Date when limit is set
    ///   - toDate: SmokeItem date
    ///   - days: Days wher user wants to quit smoking
    /// - Returns: Limit for specific SmokeItem, its optional and can return nil if fromDate is more than toDate and in other exceptions
    private func countNeededLimit(from fromDate: Date, to toDate: Date, days: Int16) -> Int16? {
        // Unwraps smokeItems data
        if let allItems = try? getDataItems() {
            // Search and unwraps SmokeItem where date is similar to fromDate
            let calendar = Calendar.current
            let fromStartDate = calendar.startOfDay(for: fromDate)
            let toStartDate = calendar.startOfDay(for: toDate)
            if let fromDateSmokeItem = allItems.first(where: { calendar.startOfDay(for: $0.date!) == fromStartDate }) {
                // Count quit portion to decrease everyday limit
                guard let fromDateAmount = fromDateSmokeItem.targetAmount as? Int16 else { return nil }
                let quitPortion = fromDateAmount/days
                let quitPersentage = Float(quitPortion)/Float(fromDateAmount)
                
                // Calculates days difference and check that it is not negative
                if let daysDifference = calendar.dateComponents(
                    [.day],
                    from: fromStartDate,
                    to: toStartDate
                ).day, daysDifference > 0 {
                    // Calculates how limit should be decreased for certain day
                    var decreesePersentage: Float = 0
                    for _ in 0..<daysDifference {
                        decreesePersentage += quitPersentage
                    }
                    
                    // Calculates certain day limit and check that it is not negative
                    let limit = fromDateAmount - Int16(Float(fromDateAmount) * decreesePersentage)
                    guard limit >= 0 else {
                        return 0
                    }
                    return limit
                }
            }
        }
        return nil
    }
    
    /// If quit smoking target for start SmokeItem was not set correctly, this method can fix this problem
    private func fixStartSmokeItemForQuitTarget() {
        if let target = targetOwner.userTarget {
            switch target.userTarget {
            case .quitTime(from: let fromDate, days: _):
                let caledar = Calendar.current
                if let startSmokeItem = try? dataStorage.getDataItems().first(where: {
                    caledar.startOfDay(for: $0.date!) == caledar.startOfDay(for: fromDate)
                }) {
                    if startSmokeItem.targetAmount == nil {
                        let statisticViewModel = StatisticsViewModel(dataStorage: dataStorage)
                        let averageSmokes = Int16(statisticViewModel.countAverageSmokesNumber())
                        try? dataStorage.updateDataItem(startSmokeItem, newDate: nil, newCount: nil, targetAmount: averageSmokes)
                    }
                }
            default:
                break
            }
        }
    }
    
    public func createItem(date: Date, count: Int16, targetLimit: Int16? = nil) throws {
        var limit: Int16? = nil
        if let userTarget = targetOwner.userTarget?.userTarget {
            switch userTarget {
            case .dayLimit(from: _, smokes: let maxNumber):
                limit = maxNumber
            case .quitTime(from: let fromDate, days: let daysToQuit):
                limit = countNeededLimit(from: fromDate, to: date, days: daysToQuit)
            }
        }
        
        do {
            try dataStorage.createItem(date: date, count: count, targetLimit: limit)
            let items = try dataStorage.getDataItems()
            updateViewData?(.created(items))
        } catch {
            throw error
        }
    }

    public func getDataItems() throws -> [SmokeItem] {
        do {
            return try dataStorage.getDataItems()
        } catch {
            throw error
        }
    }
    
    public func updateDataItem(_ item: SmokeItem, newDate: Date? = nil, newCount: Int16?, targetAmount: Int16? = nil) throws {
        do {
            try dataStorage.updateDataItem(item, newDate: newDate, newCount: newCount, targetAmount: targetAmount)
            let items = try dataStorage.getDataItems()
            updateViewData?(.updated(items))
        } catch {
            throw error
        }
    }
    
    public func deleteItem(_ item: SmokeItem) throws {
        do {
            try dataStorage.deleteItem(item)
            let items = try dataStorage.getDataItems()
            updateViewData?(.deleted(items))
        } catch {
            throw error
        }
    }
    
    public func autoNewDateCreateItem() {
        guard let lastDataItem = try? dataStorage.getDataItems().last, let lastDate = lastDataItem.date else {
            do {
                try createItem(date: Date.now, count: 0)
            } catch {
                print("class: CalendarViewModel; method: autoNewDateCreateItem(); 1st catch error: \(error)")
            }
            return
        }
        
        let calendar = Calendar.current
        let lastDay = calendar.startOfDay(for: lastDate)
        let currentDay = calendar.startOfDay(for: Date.now)
        guard let daysDifference = calendar.dateComponents([.day], from: lastDay, to: currentDay).day, daysDifference > 0 else {
            return
        }
        
        for day in (-daysDifference)...(-1) {
            let date = Date(timeIntervalSinceNow: TimeInterval((day + 1) * 24 * 60 * 60))
            do {
                try createItem(date: date, count: 0)
            } catch {
                print("class: CalendarViewModel; method: autoNewDateCreateItem(); 2nd catch error: \(error)")
            }
        }
    }
    
    public func deleteTargetForItem(_ item: SmokeItem) throws {
        print("CalendarViewModel does not fulfil this mehtod")
    }
}
