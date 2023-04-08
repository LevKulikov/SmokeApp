//
//  StatisticsViewController.swift
//  SmokeApp
//
//  Created by Лев Куликов on 07.02.2023.
//

import UIKit
import ViewAnimator

/// ViewController to display statistics about smokes
final class StatisticsViewController: UIViewController {
    /// Enumeration to define type of collectoinView sections
    private enum SectionType: CaseIterable {
        /// Wide field to display some more important and general information to focus user's opinion
        case videInfoSectoin
        /// Section to display line chart (or bar chart)
        case chartSectoin
        /// Section with some narrow items to display set of informaion in each of them
        case narrowInfoSectoin
    }
    
    //MARK: Test prop and meth
    var accountViewController: UIViewController?
    @objc
    func pushAccountViewController() {
        guard let accountViewController else { return }
        navigationController?.pushViewController(accountViewController, animated: true)
    }
    func setAccountNavItem() {
        let barButton = UIBarButtonItem(
            image: UIImage(systemName: "person.crop.circle"),
            style: .plain,
            target: self,
            action: #selector(pushAccountViewController)
        )
        navigationItem.rightBarButtonItem = barButton
    }
    
    //MARK: Properties
    /// ViewModel to manipulate with data by it
    private let viewModel: StatisticsViewModelProtocol
    
    /// Compositional main collection view
    private lazy var collectionView: UICollectionView = {
        let compositionalLayout = createCompositionalLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: compositionalLayout)
        collectionView.refreshControl = refresher
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Rigistration of all types of cells
        collectionView.register(
            UICollectionViewCell.self,
            forCellWithReuseIdentifier: UICollectionViewCell.basicIdentifier
        )
        collectionView.register(
            WideCollectionViewCell.self,
            forCellWithReuseIdentifier: WideCollectionViewCell.identifier
        )
        collectionView.register(
            ChartCollectionViewCell.self,
            forCellWithReuseIdentifier: ChartCollectionViewCell.identifier
        )
        collectionView.register(
            NarrowCollectionViewCell.self,
            forCellWithReuseIdentifier: NarrowCollectionViewCell.identifier
        )
        
        return collectionView
    }()
    
    private lazy var refresher: UIRefreshControl = {
        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return refresher
    }()
    
    //MARK: Init
    
    init(viewModel: StatisticsViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: Lyfe cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.shared.viewControllerBackgroundColor
        title = "Statistics"
        view.addSubview(collectionView)
        setAccountNavItem()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setCollectionViewConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
//        animateCollectionView()
    }
    
    //MARK: Methods
    /// Sets constraints to collectionView
    private func setCollectionViewConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    /// Refreshes data in collection view and stops Refresher animation
    @objc private func refreshData() {
        collectionView.reloadData()
        refresher.endRefreshing()
    }
    
    /// Action method to change average period calculation for forth narrow cell
    @objc private func forthNarrowCellTapped() {
        let number = viewModel.daysToCountAverage
        let numberArray = viewModel.possibleDaysArray
        
        switch number {
        case numberArray[0]:
            viewModel.daysToCountAverage = numberArray[1]
        case numberArray[1]:
            viewModel.daysToCountAverage = numberArray[2]
        case numberArray[2]:
            viewModel.daysToCountAverage = numberArray[3]
        case numberArray[3]:
            viewModel.daysToCountAverage = numberArray[0]
        default:
            viewModel.daysToCountAverage = numberArray[0]

        }
        
        let indexPath = IndexPath(row: 3, section: 2)
        collectionView.reloadItems(at: [indexPath])
    }
    
    /// Action method to change period for dynamics calculation in wide cell
    @objc private func wideCellTapped() {
        let number = viewModel.daysToCountDynamics
        let numberArray = viewModel.possibleDaysArray
        
        switch number {
        case numberArray[0]:
            viewModel.daysToCountDynamics = numberArray[1]
        case numberArray[1]:
            viewModel.daysToCountDynamics = numberArray[2]
        case numberArray[2]:
            viewModel.daysToCountDynamics = numberArray[3]
        case numberArray[3]:
            viewModel.daysToCountDynamics = numberArray[0]
        default:
            viewModel.daysToCountDynamics = numberArray[0]
        }
        
        let indexPath = IndexPath(row: 0, section: 0)
        collectionView.reloadItems(at: [indexPath])
    }
    
    /// Gets total smokes amount through all time from View Model
    /// - Returns: Int total smokes amount
    private func getTotalSmokesAmount() -> Int {
        return viewModel.getTotalSmokeCount()
    }
    
    /// Gets smokes dinamics for input days
    /// - Parameter days: days that is needed to count dynamics
    /// - Returns: dynamics
    private func getSmokesDinamics(for days: Int) -> Float {
        return viewModel.countDinamics(according: days)
    }
    
    /// Animates collection view showing
    private func animateCollectionView() {
        let cells = collectionView.visibleCells
        let animation = AnimationType.from(direction: .top, offset: 200)
        UIView.animate(
            views: cells,
            animations: [animation],
            delay: 0,
            animationInterval: 0.01,
            duration: 0.5
        )
    }
    
    //MARK: Collection Layout methods
    /// Creates compositional layout for collection view with set sections
    /// - Returns: Created layout
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let compositionalLayout = UICollectionViewCompositionalLayout { [weak self] section, _ in
            switch section {
            case 0:
                return self?.createWideInfoSectoin()
            case 1:
                return self?.createChartSectoin()
            case 2:
                return self?.createNarrowInfoSectoin()
            default:
                return nil
            }
        }
        return compositionalLayout
    }
    
    /// Creates wide section to display general information
    /// - Returns: Created section
    private func createWideInfoSectoin() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        ))
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(128)
            ),
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 10,
            leading: 10,
            bottom: 5,
            trailing: 10
        )
        
        return section
    }
    
    /// Creates chart section to display timeline chart information
    /// - Returns: Created section
    private func createChartSectoin() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        ))
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(425)
            ),
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 5,
            leading: 10,
            bottom: 5,
            trailing: 10
        )
        
        return section
    }
    
    /// Creates narrow info section to display set of information
    /// - Returns: Created section
    private func createNarrowInfoSectoin() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .fractionalHeight(1)
        ))
        item.contentInsets = NSDirectionalEdgeInsets(
            top: 5,
            leading: 5,
            bottom: 5,
            trailing: 5
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(120)
            ),
            subitems: [item, item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 5,
            bottom: 5,
            trailing: 5
        )
        
        return section
    }
}

//MARK: UIColletionView Data Source and Delegate extension, ChartCollectionViewCellDelegate
extension StatisticsViewController: UICollectionViewDataSource, UICollectionViewDelegate, ChartCollectionViewCellDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return SectionType.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 4
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UICollectionViewCell.basicIdentifier, for: indexPath)
        switch indexPath.section {
        case 0:
            guard let cellWide = collectionView.dequeueReusableCell(
                withReuseIdentifier: WideCollectionViewCell.identifier,
                for: indexPath
            ) as? WideCollectionViewCell else {
                return cell
            }
            
            let days = viewModel.daysToCountDynamics
            cellWide.configureCell(
                totalSmokes: self.getTotalSmokesAmount(),
                dynamics: self.getSmokesDinamics(for: days),
                dynamicsDays: days
            )
            
            return cellWide
            
        case 1:
            guard let cellChart = collectionView.dequeueReusableCell(
                withReuseIdentifier: ChartCollectionViewCell.identifier,
                for: indexPath
            ) as? ChartCollectionViewCell else {
                return cell
            }
            cellChart.configureCell(chartsData: viewModel.getSmokeItems())
            cellChart.delegate = self
            return cellChart
            
        case 2:
            guard let cellNarrow = collectionView.dequeueReusableCell(
                withReuseIdentifier: NarrowCollectionViewCell.identifier,
                for: indexPath
            ) as? NarrowCollectionViewCell else {
                return cell
            }
            
            switch indexPath.row {
            case 0:
                let item = viewModel.getMaximumSmokeItem()
                cellNarrow.configureCell(
                    value: item?.amount,
                    title: "Max. smokes day",
                    date: item?.date
                )
            case 1:
                let item = viewModel.getMinimumSmokeItem()
                cellNarrow.configureCell(
                    value: item?.amount,
                    title: "Min. smokes day",
                    date: item?.date
                )
            case 2:
                let item = viewModel.countAverageSmokesNumber()
                cellNarrow.configureCell(
                    value: item,
                    title: "Avg. smokes (all time)",
                    date: nil
                )
            case 3:
                let averageDays = viewModel.daysToCountAverage
                let item = viewModel.countAverageSmokesNumber(for: averageDays)
                cellNarrow.configureCell(
                    value: item,
                    title: "Avg. smokes (\(averageDays) days)",
                    date: nil
                )
            default:
                break
            }
            
            return cellNarrow
            
        default:
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            wideCellTapped()
        case 1:
            break
        case 2:
            switch indexPath.row {
            case 3:
                forthNarrowCellTapped()
            default:
                break
            }
        default:
            break
        }
    }
    
    //MARK: ChartCollectionViewCellDelegate
    func resizeChartButtonDidPress(withAction action: ChartButtonActionType) {
        
    }
}
