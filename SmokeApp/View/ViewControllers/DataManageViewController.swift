//
//  DataManageViewController.swift
//  SmokeApp
//
//  Created by Лев Куликов on 23.11.2023.
//

import UIKit

class DataManageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    //MARK: Properties
    /// ViewModel to manage saved data
    private let viewModel: DataManageViewModelProtocol
    private let cellIdentifier = "DataManageTableViewCell"
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.dataSource = self
        table.delegate = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        table.backgroundColor = Constants.shared.viewControllerBackgroundColor
        return table
    }()
    
    //MARK: Initializer
    init(viewModel: DataManageViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        title = "Manage data"
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        print("DataManageViewController init?(coder:) is not supported")
        return nil
    }
    
    //MARK: Life Cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(tableView)
    }
    
    override func viewDidLayoutSubviews() {
        setTableViewConstraints()
    }
    
    //MARK: Methods
    private func setTableViewConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func presentDeleteConfirmationAlert() {
        let alert = UIAlertController(title: "Are you sure?", message: "All data will be completely deleted and cannot be recovered", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Delete data", style: .destructive) { [weak self] _ in
            self?.deleteAllData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    private func presentErrorAlert(withTitle title: String, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    private func deleteAllData() {
        viewModel.deleteAllItems { [weak self] error in
            self?.presentErrorAlert(withTitle: "Deletion error", message: "Please, restart App and try again\nError message: \(error.localizedDescription)")
        }
    }
    
    //MARK: UITableViewDelegate, UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        var cellConfiguration = cell.defaultContentConfiguration()
        cellConfiguration.image = UIImage(systemName: "trash")
        cellConfiguration.imageProperties.tintColor = .systemRed
        cellConfiguration.text = "Delete all smoke data"
        
        cell.backgroundColor = Constants.shared.cellBackgroundColor
        cell.contentConfiguration = cellConfiguration
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            presentDeleteConfirmationAlert()
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
