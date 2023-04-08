//
//  SettingsTableViewCell.swift
//  SmokeApp
//
//  Created by Лев Куликов on 04.04.2023.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
    //MARK: Properties
    
    //MARK: Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = Constants.shared.cellBackgroundColor
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        print("AccountDetailsTableViewCell init?(coder:) is not supported")
        return nil
    }
    
    //MARK: Methods
}
