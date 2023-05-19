//
//  AppAppearanceTableViewCell.swift
//  SmokeApp
//
//  Created by Лев Куликов on 19.05.2023.
//

import UIKit

class AppAppearanceTableViewCell: UITableViewCell {
    //MARK: Properties
    /// Identifier for AppAppearanceTableViewCell type
    static let identifier = "AppAppearanceTableViewCell"
    
    /// Determines if switcher should be picked
    var isPicked: Bool = false {
        didSet {
            if isPicked {
                accessoryView?.isUserInteractionEnabled = false
            } else {
                accessoryView?.isUserInteractionEnabled = true
            }
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.switcher.setOn(self.isPicked, animated: true)
            }
        }
    }
    
    /// Closure to fulfil updates on switcher pickes, provides data about what switcher index is picked
    var switcherTurnUpdate: ((Int) -> Void)?
    
    /// Identifies type of the app appearance Cell in rawValue of Appearance Style
    var appAppearanceIndex: Int = 0
    
    /// Switcher to pick app appearance preference
    private lazy var switcher: UISwitch = {
        let switcher = UISwitch()
        switcher.preferredStyle = .checkbox
        switcher.addAction(
            UIAction(handler: { [weak self] _ in
                guard let self else { return }
                if switcher.isOn {
                    self.switcherTurnUpdate?(self.appAppearanceIndex)
                    self.accessoryView?.isUserInteractionEnabled = false
                }
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
    
    //MARK: Methods
    /// Configures cell appearance depending on provided type
    /// - Parameter index: type of notitication settings of a cell
    func configure(index: Int) {
        appAppearanceIndex = index
        switch index {
        case 0:
            configureCellText("System mode")
        case 1:
            configureCellText("Light mode only")
        case 2:
            configureCellText("Dark mode only")
        default:
            configureCellText("Unknown value")
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
