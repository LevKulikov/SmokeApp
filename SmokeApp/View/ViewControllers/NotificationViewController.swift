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
}

//MARK: UITableViewDataSource, UITableViewDelegate extension
extension NotificationViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        /// +1 is for allow or dismis notifications
        return UserNotificationManager.NotificationType.allCases.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NotificationSettingTableViewCell.identifier,
            for: indexPath
        ) as? NotificationSettingTableViewCell else {
            return UITableViewCell()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}
