//
//  SettingsTableViewCell.swift
//  SmokeApp
//
//  Created by Лев Куликов on 04.04.2023.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
    //MARK: Properties
    /// External settings type of a cell
    var getSettingsType: SettingsType? {
        return settingsType
    }
    
    /// Internal settings type
    private var settingsType: SettingsType?
    
    //MARK: Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = Constants.shared.cellBackgroundColor
        accessoryType = .disclosureIndicator
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        print("AccountDetailsTableViewCell init?(coder:) is not supported")
        return nil
    }
    
    //MARK: Methods
    /// Configures cell according to provided settings type
    /// - Parameter type: Settings type that cell should display
    func configure(type: SettingsType) {
        settingsType = type
        var configuration = defaultContentConfiguration()
        
        switch type {
        case .notifications:
            configuration.image = SettingsType.notificationsImage
            configuration.imageProperties.tintColor = .systemRed
            configuration.text = SettingsType.notifications.rawValue
        case .appearance:
            configuration.image = SettingsType.appearanceImage
            configuration.imageProperties.tintColor = .systemBlue
            configuration.text = SettingsType.appearance.rawValue
        }
        
        contentConfiguration = configuration
    }
}
