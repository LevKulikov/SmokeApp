//
//  StatisticsViewModel.swift
//  SmokeApp
//
//  Created by Лев Куликов on 08.02.2023.
//

import Foundation

/// Protocol for StatisticsViewModel
protocol StatisticsViewModelProtocol: AnyObject {
    /// Amount of days to be count average statistics data accroding to
    var daysToCountAverage: Int { get set }
    
    /// Amount of days to be counted for dynamics calculation
    var daysToCountDynamics: Int { get set }
    
    /// Possible variation of days to be used in calculations
    var possibleDaysArray: [Int] { get }
    
    /// Required initializer to set DataStorage to private property
    /// - Parameter dataStorage: DataStorage to set
    init(dataStorage: DataStorageProtocol)
    
    func getSmokeItems() -> [SmokeItem]
    
    /// Counts all smokes amount and returns it as Integer
    /// - Returns: All smokes count
    func getTotalSmokeCount() -> Int
    
    /// Counts dinamic accoring to selected amount of days
    /// - Parameter days: amount of previous days count dinamic according to
    /// - Returns: Dinamics, which shows either smokes increased or increased
    func countDinamics(according days: Int) -> Float
    
    /// Finds item where smoke amount is minimal
    /// - Returns: Smokes Item with minimal smokes amount
    func getMinimumSmokeItem() -> SmokeItem?
    
    /// Finds item where smoke amount is maximal
    /// - Returns: Smokes Item with maximal smokes amount
    func getMaximumSmokeItem() -> SmokeItem?
    
    /// Counts average number of smokes for whole saved period
    /// - Returns: average number of smokes
    func countAverageSmokesNumber() -> Float
    
    /// Counts average number of smokes for certain number of last days
    /// - Parameter days: last days for which average number is needed to be counted
    /// - Returns: average number of smokes
    func countAverageSmokesNumber(for days: Int) -> Float
}

final class StatisticsViewModel: StatisticsViewModelProtocol {
    //MARK: Properties
    var daysToCountAverage: Int = 7 {
        didSet {
            UserDefaults.standard.set(
                daysToCountAverage,
                forKey: Constants.shared.averageDaysUserDefaultKey
            )
        }
    }
    
    var daysToCountDynamics: Int = 7 {
        didSet {
            UserDefaults.standard.set(
                daysToCountDynamics,
                forKey: Constants.shared.dynamicsDaysUserDefaultKey
            )
        }
    }
    
    let possibleDaysArray: [Int] = [1, 7, 14, 30]
    
    /// DataStorage to manipulate with data (mostly to get it)
    private var dataStorage: DataStorageProtocol
    
    //MARK: Initializer
    required init(dataStorage: DataStorageProtocol) {
        self.dataStorage = dataStorage
        let averageSavedNumber = UserDefaults.standard.integer(forKey: Constants.shared.averageDaysUserDefaultKey)
        let dynamicsSavedNumber = UserDefaults.standard.integer(forKey: Constants.shared.dynamicsDaysUserDefaultKey)
        daysToCountAverage = averageSavedNumber > 0 ? averageSavedNumber : 7
        daysToCountDynamics = dynamicsSavedNumber > 0 ? dynamicsSavedNumber : 7
    }
    
    //MARK: Methods
    func getSmokeItems() -> [SmokeItem] {
        do {
            let allData = try dataStorage.getDataItems()
            return allData
        } catch {
            print("class: StatisticsViewModel; method: getSmokeItems; first catch error: \(error)")
            return []
        }
    }
    
    func getTotalSmokeCount() -> Int {
        let allData = dataStorage.savedData.compactMap{ Int($0.amount) }
        let totalCounts = allData.reduce(0, +)
        return totalCounts
    }
    
    func countDinamics(according days: Int) -> Float {
        var allData = dataStorage.savedData.compactMap{ Float($0.amount) }
        guard allData.count >= days * 2 else {
            return 0.0
        }
        
        var currentDaysStat: [Float] = []
        for _ in 0..<days {
            currentDaysStat.append(allData.removeLast())
        }
        
        var pastDaysStat: [Float] = []
        for _ in 0..<days {
            pastDaysStat.append(allData.removeLast())
        }
        
        let currentSum = currentDaysStat.reduce(0, +)
        let pastSum = pastDaysStat.reduce(0, +)
        guard pastSum > 0 else {
            return currentSum > 0 ? 1 : 0
        }
        
        guard currentSum > 0 else {
            return -1
        }
        
        let dinamic = currentSum / pastSum - 1
        return dinamic
    }
    
    func getMinimumSmokeItem() -> SmokeItem? {
        let allData = dataStorage.savedData
        // Seachs minimal value except the last one, because last value does not set finally
        let intData = allData.dropLast(1).compactMap{ $0.amount }
        guard let minValue = intData.min() else {
            return nil
        }
        return allData.first { $0.amount == minValue }
    }
    
    func getMaximumSmokeItem() -> SmokeItem? {
        let allData = dataStorage.savedData
        let intData = allData.compactMap{ $0.amount }
        guard let maxValue = intData.max() else {
            return nil
        }
        return allData.first { $0.amount == maxValue }
    }
    
    func countAverageSmokesNumber() -> Float {
        let allData = dataStorage.savedData.compactMap { Float($0.amount) }
        let average = allData.reduce(0, +) / Float(allData.count)
        let rounded = Float(Int(average * 10))/10
        return rounded
    }
    
    func countAverageSmokesNumber(for days: Int) -> Float {
        let allData =  dataStorage.savedData.compactMap { Float($0.amount) }
        let lastDaysData = allData.dropFirst(allData.count > days ? allData.count - days : 0)
        let average = lastDaysData.reduce(0, +)/Float(lastDaysData.count)
        let rounded = Float(Int(average * 10))/10
        return rounded
    }
    
    //MARK: Test properties and methods
    
}
