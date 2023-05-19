//
//  NotificationViewController.swift
//  SmokeApp
//
//  Created by Лев Куликов on 30.04.2023.
//

import UIKit

protocol NotificationViewControllerProtocol: AnyObject {
    
}

/// ViewController for notification settings
final class NotificationViewController: UIViewController, NotificationViewControllerProtocol {
    //MARK: Propeties
    /// Property to store ViewModel
    private let viewModel: NotificationViewModelProtocol
    
    /// Array of notifications settings cells
    private var settingsCell: [NotificationSettingTableViewCell] = [] {
        didSet {
            if settingsCell.count == UserNotificationManager.NotificationSettingsType.allCases.count {
                setNotificationSettinsInfo()
            }
        }
    }
    
    /// TableView to display options to set notifications
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(
            NotificationSettingTableViewCell.self,
            forCellReuseIdentifier: NotificationSettingTableViewCell.identifier
        )
        tableView.backgroundColor = .clear
        return tableView
    }()
    
    //MARK: Initializer
    init(viewModel: NotificationViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
        navigationItem.largeTitleDisplayMode = .never
        title = "Notification settings"
    }
    
    required init?(coder: NSCoder) {
        print("NotificationViewController init?(coder:) is not supported")
        return nil
    }
    
    //MARK: Lyfe Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.shared.viewControllerBackgroundColor
        view.addSubview(tableView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setTableViewConstraints()
    }
    
    //MARK: Methods
    /// Sets constraints to tableView
    private func setTableViewConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    /// Presents error alert with title "Error" and provided message. Also call error haptic vibration
    /// - Parameter message: message describes error
    private func presentErrorAlert(message: String?) {
        let alertViewController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Done", style: .default)
        alertViewController.addAction(alertAction)
        HapticManagere.shared.notificationVibrate(type: .error)
        present(alertViewController, animated: true)
    }
    
    /// Binds with closure of cell to reply for cell switcher updates depending on cell type
    /// - Parameters:
    ///   - cellType: what type of a cell is providing update
    ///   - isOn: update of a cell switcher
    private func bindCellSwitcherUpdate(cellType: UserNotificationManager.NotificationSettingsType?, isOn: Bool) {
        guard let cellType else { return }
        switch cellType {
        case .allowDismisSetting:
            allowDismisSettingUpdate(isOn: isOn)
        case .limitExceededNotification:
            limitExceededNotificationUpdate(isOn: isOn)
        case .reminderNotification:
            reminderNotification(isOn: isOn)
        }
    }
    
    /// Handle settings update for allow or dismis notifications
    /// - Parameter isOn: provide agrument about if this setting is turn on or off
    private func allowDismisSettingUpdate(isOn: Bool) {
        
        func appearOtherCells(_ appear: Bool) {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                for i in 1...self.settingsCell.count - 1 {
                    self.settingsCell[i].isUserInteractionEnabled = appear
                }
            }
        }
        
        switch isOn {
        case true:
            viewModel.enableNotifications { [weak self] didAllow, _ in
                switch didAllow {
                case true:
                    appearOtherCells(true)
                case false:
                    appearOtherCells(false)
                    self?.settingsCell.first?.isAllowed = false
                    DispatchQueue.main.async {
                        self?.presentErrorAlert(message: "SmokeApp is not permited to send notifications. Please, allow SmokeApp notifications in Settings")
                    }
                }
            }
        case false:
            viewModel.disableNotifications()
            appearOtherCells(false)
        }
    }
    
    /// Handle settings update for limitExceeded Notification
    /// - Parameter isOn: provide agrument about if this setting is turn on or off
    private func limitExceededNotificationUpdate(isOn: Bool) {
        viewModel.allowLimitExceededNotification = isOn
    }
    
    /// Handle settings update for reminder Notification
    /// - Parameter isOn: provide agrument about if this setting is turn on or off
    private func reminderNotification(isOn: Bool) {
        viewModel.allowReminderNotification = isOn
    }
    
    /// Sets info about provided earlier notifications settings
    private func setNotificationSettinsInfo() {
        allowDismisSettingUpdate(
            isOn: viewModel.isSystemAllowsNotifications && viewModel.isUserAllowsNotifications
        )

        settingsCell.first { $0.notificationSettingsType == .allowDismisSetting }?.isAllowed = viewModel.isUserAllowsNotifications
        settingsCell.first { $0.notificationSettingsType == .limitExceededNotification }?.isAllowed = viewModel.allowLimitExceededNotification
        settingsCell.first { $0.notificationSettingsType == .reminderNotification }?.isAllowed = viewModel.allowReminderNotification
    }
}

//MARK: UITableViewDataSource, UITableViewDelegate extension
extension NotificationViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        /// +1 is for allow or dismis notifications
        return UserNotificationManager.NotificationSettingsType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NotificationSettingTableViewCell.identifier,
            for: indexPath
        ) as? NotificationSettingTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(type: UserNotificationManager.NotificationSettingsType.allCases[indexPath.row])
        cell.switcherTurnUpdate = {[weak self] cellType, isOn in
            self?.bindCellSwitcherUpdate(cellType: cellType, isOn: isOn)
        }
        settingsCell.append(cell)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
