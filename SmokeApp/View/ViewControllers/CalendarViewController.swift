//
//  ViewController.swift
//  SmokeApp
//
//  Created by Лев Куликов on 30.01.2023.
//

import UIKit
import SwiftUI
import ViewAnimator
import RxSwift
import RxCocoa
import WidgetKit

protocol CalendarViewControllerProtocol: AnyObject {
    /// Show Action sheet to display availble actions with selected cell
    /// - Parameter data: Data item from selected cell
    func showActionSheetWithCell(with data: SmokeItem?)
}

/// Main (root) View for calendar bar item, shows calendar with day cells
final class CalendarViewController: UIViewController, CalendarViewControllerProtocol {
    //MARK: Properties
    private let viewModel: CalendarViewModelProtocol
    
    /// **Widget property to store data**
    @AppStorage("SmokeWidget", store: UserDefaults(suiteName: "group.someballs.SmokeApp"))
    var lastSmokeItemData = Data()
    
    /// Flag that identifies if scrollButton should be hidden
    private var buttonHide: Bool = true
    
    /// Variable that indicates if view appeared
    private var didAppear: Bool = false
    
    /// Bag to dispose RxSwift items
    private let disposeBag = DisposeBag()
    
    /// Timer that schedules collection view reloading
    private lazy var reloadTimer: Timer = {
        let timer = Timer.scheduledTimer(withTimeInterval: 2 * 60, repeats: true) { [weak self] _ in
            self?.viewModel.autoNewDateCreateItem()
            self?.collectionView.reloadData()
        }
        return timer
    }()
    
    /// Lazy View Size to get it fixed size without recalculation
    private lazy var viewSize: CGSize = { view.bounds.size }()
    
    /// Fixed padding between cells and between cell and view bounds
    private var cellInsetsPadding: CGFloat = 10
    
    /// Collection view to display calendar with custom cells
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(refreshCollectionViewToRelevantDays), for: .valueChanged)
        collectionView.refreshControl = refresher
        return collectionView
    }()
    
    //TODO: Перенести коллектион ву сюда
    private lazy var adapter: CalendarCollectionViewAdapter = {
        let adapter = CalendarCollectionViewAdapter(collectionView: collectionView)
        return adapter
    }()
    
    /// Button that appeares when user scrolls up, when it is pressed it scroll collectoinView down
    private lazy var scrollDownButton: UIButton = {
        var buttonCongig = UIButton.Configuration.borderedProminent()
        buttonCongig.cornerStyle = .large
        buttonCongig.baseBackgroundColor = .systemBlue
        buttonCongig.image = UIImage(systemName: "arrow.down")
        buttonCongig.imagePadding = 10
        buttonCongig.imagePlacement = .trailing
        buttonCongig.title = "Scroll down"
        buttonCongig.titleAlignment = .center
        
        let button = UIButton(
            configuration: buttonCongig,
            primaryAction: UIAction(
                handler: { [weak self] _ in
                guard let lastIndexPath = self?.getAllIndexPathsInCollectioView().last else { return }
                self?.collectionView.scrollToItem(at: lastIndexPath, at: .bottom, animated: true)
                }
            )
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        button.alpha = 0
        
        return button
    }()
    
    //MARK: Initializer
    init(viewModel: CalendarViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("No required init")
    }

    //MARK: Lyfe cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Calendar"
        let _ = adapter
        let _ = reloadTimer
        view.backgroundColor = Constants.shared.viewControllerBackgroundColor
        view.addSubview(collectionView)
        view.addSubview(scrollDownButton)
        view.bringSubviewToFront(scrollDownButton)
        setBindingToViewModel()
        setNavigationItems()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setCollectionViewConstraints()
        setScrollDownButtonConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        didAppear = true
//        collectionView.isHidden = false
//        animateShowingCollectionView()
//        WidgetCenter.shared.reloadAllTimelines()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        didAppear = false
    }
    
    //MARK: Methods
    /// Sets constraints to the calendar collection view
    private func setCollectionViewConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    /// Sets constraints to the scrollDownButton
    private func setScrollDownButtonConstraints() {
        NSLayoutConstraint.activate([
            scrollDownButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 25),
            scrollDownButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -25),
            scrollDownButton.heightAnchor.constraint(equalToConstant: 50),
            scrollDownButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15),
        ])
    }
    
    /// Sets needed navigation items to the navigation bar
    private func setNavigationItems() {
        let rightBarItem = UIBarButtonItem(
            title: "Last day",
            image: nil,
            primaryAction: UIAction(handler: { [weak self] _ in
                self?.pushLastDay()
                self?.collectionView.reloadData()
            })
        )
        
        let leftBarItem = UIBarButtonItem(
            title: nil,
            image: UIImage(systemName: "arrow.clockwise"),
            primaryAction: UIAction(handler: { [weak self] _ in
                self?.viewModel.autoNewDateCreateItem()
                self?.collectionView.reloadData()
            })
        )
        
        navigationItem.leftBarButtonItem = leftBarItem
        navigationItem.rightBarButtonItem = rightBarItem
    }
    
    /// Returns an array with all possible indexPaths of the collectionView
    /// - Returns: all indexPaths array
    private func getAllIndexPathsInCollectioView() -> [IndexPath] {
        var indexPaths: [IndexPath] = []
        for section in 0..<collectionView.numberOfSections {
            for item in 0..<collectionView.numberOfItems(inSection: section) {
                indexPaths.append(IndexPath(row: item, section: section))
            }
        }
        return indexPaths
    }
    
    /// Pushes the last day cell view controller
    private func pushLastDay() {
        guard let lastIndexPath = getAllIndexPathsInCollectioView().last else { return }
        collectionView(collectionView, didSelectItemAt: lastIndexPath)
    }
    
    /// Refreshes collectionView with relevant amount of cells
    @objc
    private func refreshCollectionViewToRelevantDays() {
        viewModel.autoNewDateCreateItem()
        collectionView.reloadData()
        collectionView.refreshControl?.endRefreshing()
    }
    
    /// Determines appropriate cell size depended on view size
    /// - Returns: Cell size
    private func getAppropriateCellSize() -> CGSize {
        let variableWidth = viewSize.width / 3 - (cellInsetsPadding * 4/3)
        let maxWidth: CGFloat = 150
        
        let variableHeight = viewSize.width / 2 - cellInsetsPadding
        let maxHeight: CGFloat = 200
        
        let finalWidth = variableWidth < maxWidth ? variableWidth : maxWidth
        let finalHeight = variableHeight < maxHeight ? variableHeight : maxHeight
        
        return CGSize(width: finalWidth, height: finalHeight)
    }
    
    /// Animates collection view popping up or down. This method also includes scroll down button animation
    /// - Parameter showing: Booling value, determines if collection view shound show or disappeare
    private func animateShowingCollectionView(showing: Bool = true, completion: (() -> Void)? = nil) {
        let cells = collectionView.visibleCells
        if showing {
            let animation = AnimationType.from(direction: .top, offset: 200)
            UIView.animate(
                views: cells,
                animations: [animation],
                delay: 0,
                animationInterval: 0.01,
                duration: 0.5
            )
            
            if !buttonHide {
                let animation = AnimationType.from(direction: .bottom, offset: 200)
                scrollDownButton.animate(
                    animations: [animation],
                    finalAlpha: 0.6,
                    duration: 0.5
                )
            }
        } else {
            let animation = AnimationType.from(direction: .top, offset: 0)
            UIView.animate(
                views: cells,
                animations: [animation],
                reversed: true,
                initialAlpha: 1,
                finalAlpha: 0,
                animationInterval: 0.01,
                duration: 0.3,
                completion: completion
            )
            
            if !buttonHide {
                let animation = AnimationType.identity
                scrollDownButton.animate(
                    animations: [animation],
                    reversed: true,
                    initialAlpha: 0.6,
                    finalAlpha: 0,
                    duration: 0.2
                )
            }
        }
    }
    
    /// Sets binding closure to the view model
    private func setBindingToViewModel() {
        viewModel.updateViewData = { [weak self] callback in
            guard let self else { return }
            switch callback {
            case .created(let smokeItems):
                let observer = BehaviorRelay(value: smokeItems)
                observer
                    .debug()
                    .throttle(.seconds(1), latest: true, scheduler: MainScheduler.instance)
                    .subscribe { event in
                    switch event {
                    case .next, .completed:
                        self.collectionView.reloadData()
                        print("class: CalendarViewController; method: setBindingToViewModel(); case .next, .completed")
                    case .error(let error):
                        print("class: CalendarViewController; method: setBindingToViewModel(); case .error; error: \(error)")
                    }
                }.disposed(by: self.disposeBag)
                
            case .deleted:
                self.collectionView.reloadData()
            case .updated:
                self.collectionView.reloadData()
            case .viewModelInitialized:
                // scroll collectionView to the last cell
                DispatchQueue.main.async {
                    guard let lastIndexPath = self.getAllIndexPathsInCollectioView().last else { return }
                    self.collectionView.scrollToItem(at: lastIndexPath, at: .bottom, animated: false)
                }
                // Shows the last cell detail view for first app opening
                self.selectLastCell()
            case .error(let error):
                print(error)
            }
        }
    }
    
    public func showActionSheetWithCell(with data: SmokeItem?) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive)
        let cancleAction = UIAlertAction(title: "Cancle", style: .cancel)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancleAction)
        
        present(alertController, animated: true)
    }
    
    /// Selects last cell to display its information as DayViewController
    public func selectLastCell() {
        let lastCellIndex = viewModel.savedData.count
        collectionView(collectionView, didSelectItemAt: IndexPath(item: lastCellIndex - 1, section: 0))
    }
    
    /// **For widget method** wraps SmokeItem into JSON file
    private func saveLastSmokeItem() {
        guard let lastSmokeItem = try? viewModel.getDataItems().last else { return }
        let smokeItemCodable = SmokeItemData(date: lastSmokeItem.date!, amount: lastSmokeItem.amount)
        guard let jsonData = try? JSONEncoder().encode(smokeItemCodable) else { return }
        self.lastSmokeItemData = jsonData
    }
}

//MARK: UICollectionViewDataSource, UICollectionViewDelegate and UICollectionViewDelegateFlowLayout extension

/// Class for adapting CollectionView for Calendar View Controller
final class CalendarCollectionViewAdapter {
    /// store collection view
    private let collectionView: UICollectionView
    
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        configureCollectionView()
    }
    
    /// Configurates collection view with needed settings
    private func configureCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(CalendarCollectionViewCell.self,
                                forCellWithReuseIdentifier: CalendarCollectionViewCell.identifier)
    }
    
    /// Reloads data in collection view
    func reload() {
        collectionView.reloadData()
    }
}

extension CalendarViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITabBarControllerDelegate {
    //MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        do {
            let number = try viewModel.getDataItems().count
            return number
        } catch {
            //TODO: Handle with error
            print("getDataItems() error")
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CalendarCollectionViewCell.identifier,
            for: indexPath
        ) as? CalendarCollectionViewCell else {
            return collectionView.dequeueReusableCell(
                withReuseIdentifier: CalendarCollectionViewCell.identifier,
                for: indexPath
            )
        }
        
        let index = indexPath.row
        let dataArray = viewModel.savedData
        let item = dataArray[index]
        
        if index < (dataArray.count - 1) {
            cell.configure(item: item, viewController: self)
        } else if index == (dataArray.count - 1) {
            cell.configure(item: item, viewController: self, as: .lastCell)
        }
        return cell
    }
    
    //MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        do {
            let smokeItemArray = try viewModel.getDataItems()
            let index = indexPath.row
            guard index < smokeItemArray.count else { return }
            let smokeItem = smokeItemArray[index]
            let dataStorage = viewModel.dataStorageToPush
            let dayViewController = Assembler.shared.buildMVVMDayViewController(
                with: smokeItem,
                dataStorage: dataStorage,
                targetOwner: viewModel.targetOwner
            )
//            animateShowingCollectionView(showing: false) { [weak self] in }
            navigationController?.pushViewController(dayViewController, animated: true)
            
        } catch {
            //TODO: Handle error
        }
    }
    
    //MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return getAppropriateCellSize()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: cellInsetsPadding, bottom: 0, right: cellInsetsPadding)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { [weak self] timer in
            guard let self else { return }
            
            let contentOffset = scrollView.contentOffset.y
            let totalContentHeight = scrollView.contentSize.height
            let scrollViewFixedHeight = scrollView.bounds.height
            
            if contentOffset >= (totalContentHeight - scrollViewFixedHeight - 50), self.buttonHide == false {
                self.buttonHide = true
                let animation = AnimationType.identity
                self.scrollDownButton.animate(
                    animations: [animation],
                    reversed: true,
                    initialAlpha: 0.6,
                    finalAlpha: 0,
                    duration: 0.2
                )
            } else if contentOffset < (totalContentHeight - scrollViewFixedHeight - 100), self.buttonHide == true {
                self.buttonHide = false
                let animation = AnimationType.from(direction: .bottom, offset: 200)
                self.scrollDownButton.animate(
                    animations: [animation],
                    finalAlpha: 0.6,
                    duration: 0.5
                )
            }
            
            timer.invalidate()
        }
    }
    
    //MARK: UITabBarDelegate
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if tabBarController.selectedIndex == 0 {
            if didAppear {
                guard let lastIndexPath = getAllIndexPathsInCollectioView().last else { return }
                collectionView.scrollToItem(at: lastIndexPath, at: .bottom, animated: true)
            }
        }
    }
}

