//
//  AccountViewController.swift
//  SmokeApp
//
//  Created by Лев Куликов on 30.03.2023.
//

import UIKit

protocol AccountViewControllerProtocol {
    
}

/// ViewController for account page
final class AccountViewController: UIViewController, AccountViewControllerProtocol {
    //MARK: Properties
    /// ViewModel for Account ViewController
    private let viewModel: AccountViewModelProtocol
    
    /// Table VIew to show account data and settings
    private let tableView: UITableView
    
    private var tableAdapter: TableViewAdapterProtocol?
    
    //MARK: Initializer
    init(viewModel: AccountViewModelProtocol) {
        self.viewModel = viewModel
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        print("AccountViewController init?(coder:) is not supported")
        return nil
    }
    
    //MARK: Lyfe Cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.shared.viewControllerBackgroundColor
        navigationItem.largeTitleDisplayMode = .never
        title = "Account settings"
        
        // To use self, this property is identified in viewDidLoad()
        tableAdapter = TableViewAdapter(
            tableView: tableView,
            ownerViewController: self,
            accountViewModel: viewModel
        )
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.addSubview(tableView)
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
    
    /// Return configured content size for scrollView, depending on screen (view) size (only height honestly)
    /// - Returns: configured content size for scrollView
    private func configureNeededScrollContentSize() -> CGSize {
        view.layoutIfNeeded()
        let minimalHeight: CGFloat = 570
        if view.bounds.height >= minimalHeight {
            return CGSize(width: view.bounds.width, height: view.bounds.height)
        } else {
            return CGSize(width: view.bounds.width, height: minimalHeight)
        }
    }
}

//MARK: TableViewAdapter

protocol TableViewAdapterProtocol {
    /// Reloads data in TableView
    func reload()
}

final class TableViewModelAdapter {
    private weak var accountViewModel: AccountViewModelProtocol?
    
    init(accountViewModel: AccountViewModelProtocol) {
        self.accountViewModel = accountViewModel
    }
}

final class TableViewAdapter: NSObject, TableViewAdapterProtocol {
    /// Enumeration that identifies cell types with their identifiers
    enum TableViewCellTypes: String, CaseIterable {
        case accountDetails = "accountDetailsCell"
        case settings = "settingsCell"
        case links = "linksCell"
    }
    //MARK: Properties
    private weak var tableView: UITableView?
    private weak var ownerViewController: UIViewController?
    private weak var accountViewModel: AccountViewModelProtocol?
    
    //MARK: Initializer
    init(tableView: UITableView, ownerViewController: UIViewController, accountViewModel: AccountViewModelProtocol) {
        super.init()
        self.tableView = tableView
        self.ownerViewController = ownerViewController
        self.accountViewModel = accountViewModel
        configureTableView()
    }
    
    //MARK: Methods
    func reload() {
        tableView?.reloadData()
    }
    
    /// Configures TableView correctly
    private func configureTableView() {
        tableView?.translatesAutoresizingMaskIntoConstraints = false
        tableView?.register(AccountDetailsTableViewCell.self, forCellReuseIdentifier: TableViewCellTypes.accountDetails.rawValue)
        tableView?.register(SettingsTableViewCell.self, forCellReuseIdentifier: TableViewCellTypes.settings.rawValue)
        tableView?.register(LinksTableViewCell.self, forCellReuseIdentifier: TableViewCellTypes.links.rawValue)
        tableView?.dataSource = self
        tableView?.delegate = self
    }
}

//MARK: TableView DataSource and Delegate, UIViewControllerPresentationDelegate
extension TableViewAdapter: UITableViewDataSource, UITableViewDelegate, UIViewControllerPresentationDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return TableViewCellTypes.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 3
        case 2:
            return ContactsAndLinks.allCases.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: TableViewCellTypes.accountDetails.rawValue,
                for: indexPath
            ) as! AccountDetailsTableViewCell
            cell.configure(
                imageData: accountViewModel?.accountImageData,
                name: accountViewModel?.accountName ?? "",
                gender: accountViewModel?.accountGender,
                birthYear: accountViewModel?.accountBirthYear
            )
            cell.accessoryType = .disclosureIndicator
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: TableViewCellTypes.settings.rawValue,
                for: indexPath
            ) as! SettingsTableViewCell
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: TableViewCellTypes.links.rawValue,
                for: indexPath
            ) as! LinksTableViewCell
            cell.accessoryType = .disclosureIndicator
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 100
        case 1, 2:
            return 40
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            return "Settings"
        case 2:
            return "Useful links"
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 0:
            guard let accountViewModel else { return }
            let accountSettingsVC = Assembler.shared
                .buildMVVMAccountSettingsViewController(
                    accountDataStorage: accountViewModel.accountDataStorageToSet
                )
            accountSettingsVC.presentationDelegate = self
            accountSettingsVC.modalPresentationStyle = .overFullScreen
            ownerViewController?.present(accountSettingsVC, animated: true)
        default:
            break
        }
    }
    
    //MARK: UIViewControllerPresentationDelegate
    func presentationWillEnd(for viewController: UIViewController) {
        tableView?.reloadData()
    }
}
