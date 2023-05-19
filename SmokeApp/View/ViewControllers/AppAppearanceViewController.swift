//
//  AppAppearanceViewController.swift
//  SmokeApp
//
//  Created by Лев Куликов on 19.05.2023.
//

import UIKit

/// ViewController to provide UI for App appearance settins
final class AppAppearanceViewController: UIViewController {
    //MARK: Properties
    /// Property to store the ViewModel
    private let viewModel: AppAppearanceViewModelProtocol
    
    /// Array of set in tableView cells
    private var cellsArray: [AppAppearanceTableViewCell] = [] {
        didSet {
            if cellsArray.count >= 3 {
                selectCorrentCellSwitcher()
            }
        }
    }
    
    /// TableView to provided available app appearance mode settins
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(
            AppAppearanceTableViewCell.self,
            forCellReuseIdentifier: AppAppearanceTableViewCell.identifier
        )
        tableView.backgroundColor = .clear
        return tableView
    }()
    
    //MARK: Initializer
    init(viewModel: AppAppearanceViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        title = "App appearance"
        navigationItem.largeTitleDisplayMode = .never
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        print("AppAppearanceViewController init?(coder:) is not supported")
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
    
    /// Selects needed cell switcher depending on saved by user app appearance preferance
    private func selectCorrentCellSwitcher() {
        let exceptionCellIndex = viewModel.getCurrentAppearanceModeInt()
        let correctCell = cellsArray.first { $0.appAppearanceIndex == exceptionCellIndex }
        correctCell?.isPicked = true
    }
    
    /// Binds with closure of cell to reply for cell switcher updates depending on cell number
    /// - Parameter selectedCellNumber: number of the cell which switcher was selected, nil is equal to 0 or system appearance mode
    private func bindCellSwitcherUpdate(selectedCellNumber: Int?) {
        viewModel.setAppMode(to: selectedCellNumber ?? 0)
        var copyArray = cellsArray
        copyArray.removeAll { $0.appAppearanceIndex == selectedCellNumber }
        for cell in copyArray {
            cell.isPicked = false
        }
    }
}

//MARK: UITableViewDataSource, UITableViewDelegate extension
extension AppAppearanceViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Number of UIUserInterfaceStyle cases
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: AppAppearanceTableViewCell.identifier,
            for: indexPath
        ) as? AppAppearanceTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(index: indexPath.row)
        cell.switcherTurnUpdate = {[weak self] selectedCellNumber in
            self?.bindCellSwitcherUpdate(selectedCellNumber: selectedCellNumber)
        }
        cellsArray.append(cell)
        return cell
    }
}
