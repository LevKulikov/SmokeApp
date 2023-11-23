//
//  DateManageViewModel.swift
//  SmokeApp
//
//  Created by Лев Куликов on 23.11.2023.
//

import Foundation

/// Protocol for object that manages saved data
protocol DataManageViewModelProtocol: AnyObject {
    /// Deletes all saved items from storage
    func deleteAllItems(errorHandler: ((Error) -> Void)? )
}

final class DataManageViewModel: DataManageViewModelProtocol {
    //MARK: Properties
    private let dataStorage: DataStorageProtocol
    
    //MARK: Initializer
    init(dataStorage: DataStorageProtocol) {
        self.dataStorage = dataStorage
    }
    
    //MARK: Methods
    func deleteAllItems(errorHandler: ((Error) -> Void)? ) {
        do {
            try dataStorage.deleteAllItems()
        } catch {
            errorHandler?(error)
        }
    }
}
