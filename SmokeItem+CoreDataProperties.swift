//
//  SmokeItem+CoreDataProperties.swift
//  
//
//  Created by Лев Куликов on 19.02.2023.
//
//

import Foundation
import CoreData


extension SmokeItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SmokeItem> {
        return NSFetchRequest<SmokeItem>(entityName: "SmokeItem")
    }

    @NSManaged public var amount: Int16
    @NSManaged public var date: Date?

}
