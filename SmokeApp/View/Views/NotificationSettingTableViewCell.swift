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
    
    /// Identifies type of the Notification Cell
    var notificationSettingsType: UserNotificationManager.NotificationSettingsType?
    
    /// Determines if switcher should be turned on or off, nil is equal to false
    var isAllowed: Bool? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.switcher.setOn(self.isAllowed != nil ? self.isAllowed! : false, animated: true)
            }
        }
    }
    
    /// Closure to fulfil updates on switcher turns, provides data about cell type and switcher.isOn
    var switcherTurnUpdate: ((UserNotificationManager.NotificationSettingsType?, Bool) -> Void)?
    
    /// Switcher to turn on or off notification preference
    private lazy var switcher: UISwitch = {
        let switcher = UISwitch()
        switcher.addAction(
            UIAction(handler: { [weak self] _ in
                self?.switcherTurnUpdate?(self?.notificationSettingsType, switcher.isOn)
            }),
            for: .valueChanged
        )
        return switcher
    }()

    //MARK: Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = Constants.shared.cellBackgroundColor
        selectionStyle = .none
        clipsToBounds = true
        accessoryView = switcher
    }
    
    required init?(coder: NSCoder) {
        print("NotificationSettingTableViewCell init?(coder:) is not supported")
        return nil
    }
    
    //MARK: Lyfe Cycle methods and overrides
    override var isUserInteractionEnabled: Bool {
        didSet {
            super.isUserInteractionEnabled = isUserInteractionEnabled
            switcher.isEnabled = isUserInteractionEnabled
        }
    }
    
    //MARK: Methods
    /// Configures cell appearance depending on provided type
    /// - Parameter type: type of notitication settings of a cell
    func configure(type: UserNotificationManager.NotificationSettingsType) {
        notificationSettingsType = type
        switch type {
        case .allowDismisSetting:
            configureCellText("Allow app notifications")
        case .limitExceededNotification:
            configureCellText("Notify when limit is exceeded")
        case .reminderNotification:
            configureCellText("Reminding notifications")
        }
    }
    
    /// Configures cell with provided text to display in it
    /// - Parameter text: text to set in a cell
    private func configureCellText(_ text: String) {
        var conf = defaultContentConfiguration()
        conf.text = text
        contentConfiguration = conf
    }
}
