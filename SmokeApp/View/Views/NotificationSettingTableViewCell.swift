//
//  NotificationSettingTableViewCell.swift
//  SmokeApp
//
//  Created by Лев Куликов on 10.05.2023.
//

import UIKit

class NotificationSettingTableViewCell: UITableViewCell {
    //MARK: Properties
    /// Identifier for NotificationSettingTableViewCell type
    static let identifier = "NotificationSettingTableViewCell"

    //MARK: Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = Constants.shared.cellBackgroundColor
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        print("NotificationSettingTableViewCell init?(coder:) is not supported")
        return nil
    }
    
    //MARK: Lyfe Cycle methods
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

    }
    
    //MARK: Methods

}
