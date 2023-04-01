//
//  TargetViewController.swift
//  SmokeApp
//
//  Created by Лев Куликов on 17.02.2023.
//

import UIKit
import ViewAnimator
import RxSwift

/// Protocol for TargetViewController
protocol TargetViewControllerProtocol: AnyObject {
    
}

/// View Controller that displays view for setting the target that user wants to reach. Target can vary like how many smokes user wants to do a day, a week, a month, or when user wants to stop smoking (in what period of time)
final class TargetViewController: UIViewController, TargetViewControllerProtocol {
    private enum TargetError: Error {
        case noValue
        case unableToConvertValueIntoInt16
    }
    
    //MARK: Properties
    /// ViewModel for TargetViewController
    private let viewModel: TargetViewModelProtocol
    
    /// Bag to dispose RxSwift items
    private let disposeBag = DisposeBag()
    
    /// Initial Y point for circleView
    private var circleViewInitialY: CGFloat!
    
    /// Initial Y point for quitDaysInitialLimitLabel
    private var quitDaysLimitLabelInitialY: CGFloat!
    
    /// Constraint for quitDaysInitialLimitLabel, which is needed for animation
    private var quitDaysLimitLabelTopConstraint: NSLayoutConstraint!
    
    /// Introdaction label displays general information to user about what is this view about
    private lazy var introLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .label
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .left
        
        let textString = """
        Here you can set target for smoking, which will be considered when you count your everyday smokes. Target can be 2 types:
        
         **- Daily limit**:
           Enter amount of smokes that you do not want to exceed, SmokeApp will help you to track when you do so and will alert about it
        
         **- Days to quit**:
           Enter amount of days in which you want to quit smoking, SmokeApp will count limits automatically for the each next day so the last day limit will be 0
        """
        if let attributedText = try? NSMutableAttributedString(
            markdown: textString,
            options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        ) {
            let range = NSRange(location: 0, length: attributedText.mutableString.length)
            attributedText.addAttribute(NSAttributedString.Key.font, value: UIFont.preferredFont(forTextStyle: .title2), range: range)
            label.attributedText = attributedText
        }
        
        return label
    }()
    
    /// Button that shows views to add new target
    private lazy var addTargetButton: UIButton = {
        var buttonConfig = UIButton.Configuration.borderedProminent()
        buttonConfig.title = "Add target"
        buttonConfig.image = UIImage(systemName: "target")
        buttonConfig.imagePadding = 10
        buttonConfig.imagePlacement = .trailing
        buttonConfig.cornerStyle = .large
        
        let button = UIButton(configuration: buttonConfig)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    /// Provides user a types of target to select while setting target
    private lazy var targetTypeSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.insertSegment(withTitle: "Daily limit", at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: "Days to quit", at: 1, animated: false)
        segmentedControl.setTitleTextAttributes([.font: UIFont.boldSystemFont(ofSize: 17)], for: .normal)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentSelected), for: .valueChanged)
        segmentedControl.isHidden = true
        return segmentedControl
    }()
    
    /// View for background circle for limitTextField
    private lazy var circleView: UIView = {
        let circleView = UIView()
        circleView.translatesAutoresizingMaskIntoConstraints = false
        circleView.backgroundColor = .systemGray5
        circleView.isUserInteractionEnabled = true
        circleView.isHidden = true
        return circleView
    }()
    
    /// View for background circle for limitTextField to enter initial limit when user chooses to set days to quit smoking
    private lazy var secondCircleView: UIView = {
        let circleView = UIView()
        circleView.translatesAutoresizingMaskIntoConstraints = false
        circleView.backgroundColor = .systemGray5
        circleView.isUserInteractionEnabled = true
        circleView.isHidden = true
        return circleView
    }()
    
    /// TextField to set count number from limit
    private lazy var limitTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textAlignment = .center
        textField.textColor = .label
        textField.tintColor = .systemGray
        textField.keyboardType = .numberPad
        textField.returnKeyType = .done
        textField.borderStyle = .none
        textField.placeholder = "0"
        textField.delegate = self
        
        // Recommended value is minimal registered smokes amount ever, except 0 value
        if let recommendedValue = viewModel.getAllTimeMinimalSmokes() {
            textField.text = String(recommendedValue)
        } else {
            textField.text = "0"
        }
        
        /// Filters only number values
        textField.rxAcceptingOnlyInt16Field().disposed(by: disposeBag)
        
        return textField
    }()
    
    /// TextField to set count number for initial limit when user chooses to set days to quit smoking
    private lazy var initialLimitTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textAlignment = .center
        textField.textColor = .label
        textField.tintColor = .systemGray
        textField.keyboardType = .numberPad
        textField.returnKeyType = .done
        textField.borderStyle = .none
        textField.text = "20"
        textField.placeholder = "0"
        textField.delegate = self
        
        /// Filters only number values
        textField.rxAcceptingOnlyInt16Field().disposed(by: disposeBag)
        
        return textField
    }()
    
    private lazy var quitDaysInitialLimitLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Initial smoke limit"
        label.font = .systemFont(ofSize: 35)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.textColor = .label
        label.isHidden = true
        return label
    }()
    
    /// Label displays set target type
    private lazy var targetTypeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 35)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.textColor = .label
        return label
    }()
    
    /// Label displays set target limit of quit days
    private lazy var targetValue: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 50)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.textColor = .systemGreen
        return label
    }()
    
    /// Displays description for target fulfilmint label
    private lazy var targetFulfilmentDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 35)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.textColor = .label
        label.text = "You fulfil your target for"
        return label
    }()
    
    /// Provides user information about how he or she perform / fulfil set target in %
    private lazy var targetFulfilmentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 50)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        return label
    }()
    
    /// Value with user's target fulfilment, it is binded with targetFulfilmentLabel to provide actual data
    private var targetFulfimentValue: Float? {
        didSet {
            guard let targetFulfimentValue else {
                targetFulfilmentLabel.text = "Nil"
                targetFulfilmentLabel.textColor = .label
                return
            }
            
            var resultedValue = targetFulfimentValue * 100
            switch resultedValue {
            case 0..<60:
                targetFulfilmentLabel.textColor = .systemRed
            case 60..<85:
                targetFulfilmentLabel.textColor = .systemOrange
            case 85...:
                targetFulfilmentLabel.textColor = .systemGreen
                if resultedValue > 9999 {
                    resultedValue = 9999
                }
            default:
                targetFulfilmentLabel.textColor = .label
            }
            
            let string = String(Int(resultedValue)) + "%"
            targetFulfilmentLabel.text = string
        }
    }
    
    //MARK: Initializer
    init(viewModel: TargetViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("No required init")
    }
    
    //MARK: Lyfe Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Smokes Target"
        view.backgroundColor = Constants.shared.viewControllerBackgroundColor
        view.addSubviews(
            introLabel,
            addTargetButton,
            targetTypeSegmentedControl,
            circleView,
            targetTypeLabel,
            targetValue,
            targetFulfilmentDescriptionLabel,
            targetFulfilmentLabel,
            quitDaysInitialLimitLabel,
            secondCircleView
        )
        circleView.addSubview(limitTextField)
        secondCircleView.addSubview(initialLimitTextField)
        // Identifies if its needed to show inro label or set target information
        if let _ = viewModel.target {
            setTargetViews()
        } else {
            setIntroAndToolsToSetTargetViews()
        }
        changeCircleViewsWithKeyboard()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setCircleViewConstraints()
        circleView.layoutIfNeeded()
        quitDaysLimitLabelInitialY = circleViewInitialY + circleView.bounds.height + 20
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadLabelsData()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        limitTextField.resignFirstResponder()
        initialLimitTextField.resignFirstResponder()
    }
    
    //MARK: Methdos
    /// Sets layout constraints to introLabel. Firstly need to set constraints to addTargetButton
    private func setIntroLabelConstraints() {
        NSLayoutConstraint.activate([
            introLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            introLabel.bottomAnchor.constraint(equalTo: addTargetButton.topAnchor, constant: -15),
            introLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            introLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
        ])
    }
    
    /// Sets layout constraints to addTargetButton
    private func setAddTargetButtonConstraints() {
        NSLayoutConstraint.activate([
            addTargetButton.heightAnchor.constraint(equalToConstant: 70),
            addTargetButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15),
            addTargetButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            addTargetButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
        ])
    }
    
    /// Sets layout constraints to targetTypeSegmentedControl
    private func setTargetTypeSegmentedControlConstraints() {
        NSLayoutConstraint.activate([
            targetTypeSegmentedControl.heightAnchor.constraint(equalToConstant: 40),
            targetTypeSegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            targetTypeSegmentedControl.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            targetTypeSegmentedControl.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
        ])
    }
    
    /// Sets layout constraints to circleView
    private func setCircleViewConstraints() {
        var multiplier: CGFloat = 0.65
        if view.safeAreaLayoutGuide.layoutFrame.height < 570 {
            multiplier = 0.3
        }
        let maxDimensionValue: CGFloat = 150
        
        let circleViewHeightAnchor = circleView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: multiplier)
        circleViewHeightAnchor.priority = .defaultHigh
        let circleViewHeightAnchorMax = circleView.heightAnchor.constraint(lessThanOrEqualToConstant: maxDimensionValue)
        circleViewHeightAnchorMax.priority = .required
        
        let topAnchorConstant: CGFloat = 90
        NSLayoutConstraint.activate([
            circleView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: topAnchorConstant),
            circleView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            circleViewHeightAnchor,
            circleViewHeightAnchorMax,
            circleView.widthAnchor.constraint(equalTo: circleView.heightAnchor, multiplier: 2)
        ])
        circleView.layer.cornerRadius = circleView.safeAreaLayoutGuide.layoutFrame.width / 8
        circleViewInitialY = topAnchorConstant
    }
    
    /// Sets layout constraints to limitTextField **and text font depending on circleView width**
    private func setLimitTextFieldConstraints() {
        NSLayoutConstraint.activate([
            limitTextField.topAnchor.constraint(equalTo: circleView.topAnchor),
            limitTextField.bottomAnchor.constraint(equalTo: circleView.bottomAnchor),
            limitTextField.leftAnchor.constraint(equalTo: circleView.leftAnchor),
            limitTextField.rightAnchor.constraint(equalTo: circleView.rightAnchor)
        ])
        circleView.layoutIfNeeded()
        limitTextField.font = .boldSystemFont(ofSize: circleView.safeAreaLayoutGuide.layoutFrame.width * 0.35)
    }
    
    /// Sets layout constraints to quitDaysInitialLimitLabel
    private func setQuitDaysInitialLimitLabelConstraints() {
        quitDaysLimitLabelTopConstraint = quitDaysInitialLimitLabel.topAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.topAnchor,
            constant: quitDaysLimitLabelInitialY
        )
        NSLayoutConstraint.activate([
            quitDaysLimitLabelTopConstraint,
            quitDaysInitialLimitLabel.heightAnchor.constraint(equalToConstant: 36),
            quitDaysInitialLimitLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    /// Sets layout constraints to secondCircleView
    private func setSecondCircleViewConstraints() {
        NSLayoutConstraint.activate([
            secondCircleView.topAnchor.constraint(equalTo: quitDaysInitialLimitLabel.bottomAnchor, constant: 10),
            secondCircleView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            secondCircleView.heightAnchor.constraint(equalTo: circleView.heightAnchor),
            secondCircleView.widthAnchor.constraint(equalTo: secondCircleView.heightAnchor, multiplier: 2)
        ])
        secondCircleView.layer.cornerRadius = secondCircleView.safeAreaLayoutGuide.layoutFrame.width / 8
    }
    
    /// Sets layout constraints to initialLimitTextField
    private func setInitialLimitTextFieldConstraints() {
        NSLayoutConstraint.activate([
            initialLimitTextField.topAnchor.constraint(equalTo: secondCircleView.topAnchor),
            initialLimitTextField.bottomAnchor.constraint(equalTo: secondCircleView.bottomAnchor),
            initialLimitTextField.leftAnchor.constraint(equalTo: secondCircleView.leftAnchor),
            initialLimitTextField.rightAnchor.constraint(equalTo: secondCircleView.rightAnchor)
        ])
        initialLimitTextField.font = .boldSystemFont(ofSize: secondCircleView.safeAreaLayoutGuide.layoutFrame.width * 0.35)
    }
    
    /// Sets layout constraints to targetTypeLabel
    private func setTargetTypeLabelConstraints() {
        var topAnchorConstant: CGFloat = 60
        if view.safeAreaLayoutGuide.layoutFrame.height < 570 {
            topAnchorConstant = 40
        }
        
        NSLayoutConstraint.activate([
            targetTypeLabel.heightAnchor.constraint(equalToConstant: 40),
            targetTypeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: topAnchorConstant),
            targetTypeLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            targetTypeLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
        ])
    }
    
    /// Sets layout constraints to targetValue
    private func setTargetValueConstraints() {
        let multiplier: CGFloat = 0.65
        let maxDimensionValue: CGFloat = 150
        
        let targetValueHeightAnchor = targetValue.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: multiplier)
        targetValueHeightAnchor.priority = .defaultHigh
        let targetValueHeightAnchorMax = targetValue.heightAnchor.constraint(lessThanOrEqualToConstant: maxDimensionValue)
        targetValueHeightAnchorMax.priority = .required
        
        NSLayoutConstraint.activate([
            targetValue.topAnchor.constraint(equalTo: targetTypeLabel.bottomAnchor, constant: 10),
            targetValue.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            targetValueHeightAnchor,
            targetValueHeightAnchorMax,
            targetValue.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        targetValue.font = .boldSystemFont(ofSize: targetValue.safeAreaLayoutGuide.layoutFrame.width * 0.35)
    }
    
    /// Sets layout constraints to targetFulfilmentLabel and targetFulfilmentDescriptionLabel
    private func setTargetFulfilmentLabelsConstraints() {
        NSLayoutConstraint.activate([
            targetFulfilmentDescriptionLabel.topAnchor.constraint(equalTo: targetValue.bottomAnchor, constant: 30),
            targetFulfilmentDescriptionLabel.heightAnchor.constraint(equalTo: targetTypeLabel.heightAnchor),
            targetFulfilmentDescriptionLabel.leftAnchor.constraint(equalTo: targetTypeLabel.leftAnchor),
            targetFulfilmentDescriptionLabel.rightAnchor.constraint(equalTo: targetTypeLabel.rightAnchor),
        ])
        
        NSLayoutConstraint.activate([
            targetFulfilmentLabel.topAnchor.constraint(equalTo: targetFulfilmentDescriptionLabel.bottomAnchor, constant: 10),
            targetFulfilmentLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            targetFulfilmentLabel.heightAnchor.constraint(equalTo: targetValue.heightAnchor),
            targetFulfilmentLabel.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        targetFulfilmentLabel.font = targetValue.font
    }
    
    /// Animates addTargetButton showing or disappearing
    /// - Parameter showing: enter *true* if it is needed to show, enter *false* if to disappeare
    /// - Parameter completion: code block that is executed after animation ends
    private func animateAddTargetButton(showing: Bool, completion: (() -> Void)? = nil) {
        guard !addTargetButton.isHidden else { return }
        if showing {
            let animation = AnimationType.from(direction: .bottom, offset: 100)
            addTargetButton.animate(
                animations: [animation],
                duration: 0.4,
                completion: completion
            )
        } else {
            let animation = AnimationType.from(direction: .bottom, offset: 0)
            addTargetButton.animate(
                animations: [animation],
                reversed: true,
                initialAlpha: 1,
                finalAlpha: 0,
                duration: 0.3,
                completion: completion
            )
        }
    }
    
    /// Animates introLabel showing or disappearing
    /// - Parameter showing: enter *true* if it is needed to show, enter *false* if to disappeare
    /// - Parameter completion: code block that is executed after animation ends
    private func animateIntroLabel(showing: Bool, completion: (() -> Void)? = nil) {
        guard !introLabel.isHidden else { return }
        if showing {
            let animation = AnimationType.from(direction: .top, offset: 200)
            introLabel.animate(
                animations: [animation],
                duration: 0.4,
                completion: completion
            )
        } else {
            let animation = AnimationType.from(direction: .top, offset: 0)
            introLabel.animate(
                animations: [animation],
                reversed: true,
                initialAlpha: 1,
                finalAlpha: 0,
                duration: 0.3,
                completion: completion
            )
        }
    }
    
    /// Animates targetTypeSegmentedControl showing or disappearing
    /// - Parameter showing: enter *true* if it is needed to show, enter *false* if to disappeare
    /// - Parameter completion: code block that is executed after animation ends
    private func animateTargetTypeSegmentedControl(showing: Bool, completion: (() -> Void)? = nil) {
        guard !targetTypeSegmentedControl.isHidden else { return }
        if showing {
            let animation = AnimationType.from(direction: .top, offset: 100)
            targetTypeSegmentedControl.animate(
                animations: [animation],
                duration: 0.4,
                completion: completion
            )
        } else {
            let animation = AnimationType.from(direction: .top, offset: 0)
            targetTypeSegmentedControl.animate(
                animations: [animation],
                reversed: true,
                initialAlpha: 1,
                finalAlpha: 0,
                duration: 0.3,
                completion: completion
            )
        }
    }
    
    /// Animates CircleView showing or disappearing
    /// - Parameter showing: enter *true* if it is needed to show, enter *false* if to disappeare
    /// - Parameter completion: code block that is executed after animation ends
    private func animateCircleView(showing: Bool, completion: (() -> Void)? = nil) {
        guard !circleView.isHidden else { return }
        if showing {
            let animation = AnimationType.from(direction: .top, offset: 100)
            circleView.animate(
                animations: [animation],
                delay: 0.15,
                duration: 0.4,
                completion: completion
            )
        } else {
            limitTextField.resignFirstResponder()
            let animation = AnimationType.from(direction: .top, offset: 0)
            circleView.animate(
                animations: [animation],
                reversed: true,
                initialAlpha: 1,
                finalAlpha: 0,
                duration: 0.3,
                completion: completion
            )
        }
    }
    
    /// Animates targetTypeLabel showing or disappearing
    /// - Parameter showing: enter *true* if it is needed to show, enter *false* if to disappeare
    /// - Parameter completion: code block that is executed after animation ends
    private func animateTargetTypeLabel(showing: Bool, completion: (() -> Void)? = nil) {
        guard !targetTypeLabel.isHidden else { return }
        if showing {
            let animation = AnimationType.from(direction: .top, offset: 100)
            targetTypeLabel.animate(
                animations: [animation],
                duration: 0.4,
                completion: completion
            )
        } else {
            let animation = AnimationType.from(direction: .top, offset: 0)
            targetTypeLabel.animate(
                animations: [animation],
                reversed: true,
                initialAlpha: 1,
                finalAlpha: 0,
                duration: 0.3,
                completion: completion
            )
        }
    }
    
    /// Animates targetValue showing or disappearing
    /// - Parameter showing: enter *true* if it is needed to show, enter *false* if to disappeare
    /// - Parameter completion: code block that is executed after animation ends
    private func animateTargetValueLabel(showing: Bool, completion: (() -> Void)? = nil) {
        guard !targetValue.isHidden else { return }
        if showing {
            let animation = AnimationType.from(direction: .top, offset: 100)
            targetValue.animate(
                animations: [animation],
                delay: 0.1,
                duration: 0.4,
                completion: completion
            )
        } else {
            let animation = AnimationType.from(direction: .top, offset: 0)
            targetValue.animate(
                animations: [animation],
                reversed: true,
                initialAlpha: 1,
                finalAlpha: 0,
                duration: 0.3,
                completion: completion
            )
        }
    }
    
    /// Animates targetFulfilmentDescriptionLabel showing or disappearing
    /// - Parameter showing: enter *true* if it is needed to show, enter *false* if to disappeare
    /// - Parameter completion: code block that is executed after animation ends
    private func animateTargetFulfilmentDescriptionLabel(showing: Bool, completion: (() -> Void)? = nil) {
        guard !targetValue.isHidden else { return }
        if showing {
            let animation = AnimationType.from(direction: .top, offset: 100)
            targetFulfilmentDescriptionLabel.animate(
                animations: [animation],
                delay: 0.2,
                duration: 0.4,
                completion: completion
            )
        } else {
            let animation = AnimationType.from(direction: .top, offset: 0)
            targetFulfilmentDescriptionLabel.animate(
                animations: [animation],
                reversed: true,
                initialAlpha: 1,
                finalAlpha: 0,
                duration: 0.3,
                completion: completion
            )
        }
    }
    
    /// Animates targetFulfilmentLabel showing or disappearing
    /// - Parameter showing: enter *true* if it is needed to show, enter *false* if to disappeare
    /// - Parameter completion: code block that is executed after animation ends
    private func animateTargetFulfilmentLabel(showing: Bool, completion: (() -> Void)? = nil) {
        guard !targetValue.isHidden else { return }
        if showing {
            let animation = AnimationType.from(direction: .top, offset: 100)
            targetFulfilmentLabel.animate(
                animations: [animation],
                delay: 0.3,
                duration: 0.4,
                completion: completion
            )
        } else {
            let animation = AnimationType.from(direction: .top, offset: 0)
            targetFulfilmentLabel.animate(
                animations: [animation],
                reversed: true,
                initialAlpha: 1,
                finalAlpha: 0,
                duration: 0.3,
                completion: completion
            )
        }
    }
    
    /// Animates view for setting initial limit when user chooses quit days for target showing or disappearing
    /// - Parameter showing: enter *true* if it is needed to show, enter *false* if to disappeare
    /// - Parameter completion: code block that is executed after animation ends
    private func animateInitialLimitView(showing: Bool, completion: (() -> Void)? = nil) {
        guard !quitDaysInitialLimitLabel.isHidden,
              !secondCircleView.isHidden
        else { return }
        
        if showing {
            let animation = AnimationType.from(direction: .top, offset: 100)
            UIView.animate(
                views: [quitDaysInitialLimitLabel, secondCircleView],
                animations: [animation],
                delay: 0.15,
                duration: 0.4,
                completion: completion
            )
        } else {
            let animation = AnimationType.from(direction: .top, offset: 0)
            UIView.animate(
                views: [quitDaysInitialLimitLabel, secondCircleView],
                animations: [animation],
                reversed: true,
                initialAlpha: 1,
                finalAlpha: 0,
                duration: 0.3,
                completion: completion
            )
        }
    }
    
    /// Sets right button to Navigation Bar
    /// - Parameter image: Image to set in the button
    /// - Parameter selector: selector to set as action in button
    private func setRightNavigationButton(image: UIImage?, selector: Selector?) {
        let barButton = UIBarButtonItem(
            image: image,
            style: .done,
            target: self,
            action: selector
        )
        
        navigationItem.setRightBarButton(
            barButton,
            animated: true
        )
    }
    
    /// Sets left button to Navigation Bar
    /// - Parameters:
    ///   - image: Image to set in the button
    ///   - selector: selector to set as action in button
    private func setLeftNavigationButton(image: UIImage?, selector: Selector?) {
        let barButton = UIBarButtonItem(
            image: image,
            style: .done,
            target: self,
            action: selector
        )
        
        navigationItem.setLeftBarButton(
            barButton,
            animated: true
        )
    }
    
    /// Adds button above keyboard to turn down keyboard
    private func addDoneButtonToKeyboard(for textField: UITextField) {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen().bounds.width, height: 50))
        toolBar.barStyle = .default
        toolBar.backgroundColor = .clear
        
        let spaceButton = UIBarButtonItem.flexibleSpace()
        let doneButton = UIBarButtonItem(
            title: nil,
            image: UIImage(systemName: "keyboard.chevron.compact.down"),
            primaryAction: UIAction(handler: { _ in
                textField.resignFirstResponder()
            })
        )
        
        toolBar.setItems([spaceButton, doneButton], animated: true)
        toolBar.sizeToFit()
        textField.inputAccessoryView = toolBar
    }
    
    /// Changes Circle View appearance with keyboard showing or hiding
    private func changeCircleViewsWithKeyboard() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    /// Sets views that display set by user target, also sets information to views
    private func setTargetViews() {
        introLabel.isHidden = true
        addTargetButton.isHidden = true
        targetTypeLabel.isHidden = false
        targetValue.isHidden = false
        targetFulfilmentDescriptionLabel.isHidden = false
        targetFulfilmentLabel.isHidden = false
                
        setTargetTypeLabelConstraints()
        setTargetValueConstraints()
        setTargetFulfilmentLabelsConstraints()
        setRightNavigationButton(image: UIImage(systemName: "pencil.line"), selector: #selector(editTarget))
        setLeftNavigationButton(image: UIImage(systemName: "trash"), selector: #selector(deleteTarget))
        
        guard let target = viewModel.target else { return }
        switch target.userTarget {
        case .dayLimit(from: _, smokes: let limit):
            targetTypeLabel.text = "Your daily limit"
            targetValue.text = String(limit)
        case .quitTime:
            targetTypeLabel.text = "Days left to quit smoking"
            targetValue.text = String(viewModel.countLeftDaysToQuitSmoking() ?? 0)
        }
        reloadLabelsData()
    }
    
    /// Sets views for inrodaction about smoke target and convenience gestures
    private func setIntroAndToolsToSetTargetViews() {
        targetTypeLabel.isHidden = true
        targetValue.isHidden = true
        targetFulfilmentDescriptionLabel.isHidden = true
        targetFulfilmentLabel.isHidden = true
        navigationItem.setLeftBarButton(nil, animated: true)
        navigationItem.setRightBarButton(nil, animated: true)
        
        addTargetButton.isHidden = false
        introLabel.isHidden = false
        
        setAddTargetButtonConstraints()
        setIntroLabelConstraints()
        setTargetTypeSegmentedControlConstraints()
        setCircleViewConstraints()
        setLimitTextFieldConstraints()
        addDoneButtonToKeyboard(for: limitTextField)
        addDoneButtonToKeyboard(for: initialLimitTextField)
        
        let gestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(turnBackToIntro))
        gestureRecognizer.edges = .left
        view.addGestureRecognizer(gestureRecognizer)
        
        addTargetButton.removeTarget(self, action: #selector(setTargetButtonTap), for: .touchUpInside)
        addTargetButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }
    
    /// Saves set user's target to the Target Owner
    private func saveTarget() throws {
        var int16: Int16
        do {
            int16 = try checkValueInTextField(limitTextField)
        } catch {
            limitTextField.text = "0"
            throw error
        }
        
        switch targetTypeSegmentedControl.selectedSegmentIndex {
        case 0:
            let target = Target(userTarget: .dayLimit(from: Date.now, smokes: int16))
            viewModel.setNewTarget(target)
        case 1:
            var initialInt16: Int16
            do {
                initialInt16 = try checkValueInTextField(initialLimitTextField)
                let target = Target(userTarget: .quitTime(from: Date.now, days: int16, initialLimit: initialInt16))
                viewModel.setNewTarget(target)
            } catch {
                initialLimitTextField.text = "0"
                throw error
            }
        default:
            break
        }
    }
    
    /// Checks if value in text field is int. If it is not, it throws an error
    /// - Returns: If value is Int16, so it returns Int16
    private func checkValueInTextField(_ textField: UITextField) throws -> Int16 {
        guard let string = textField.text else {
            throw TargetError.noValue
        }
        guard let int16 = Int16(string) else {
            throw TargetError.unableToConvertValueIntoInt16
        }
        return int16
    }
    
    /// Reloads / actualizes data in labels
    private func reloadLabelsData() {
        guard let target = viewModel.target else { return }
        switch target.userTarget {
        case .dayLimit:
            break
        case .quitTime:
            targetValue.text = String(viewModel.countLeftDaysToQuitSmoking() ?? 0)
        }
        
        targetFulfimentValue = viewModel.currentTargetPerformance()
    }
    
    /// Target action for addTargetButton, shows views to make user be able to add his or her smoke target
    @objc
    private func addButtonTapped() {
        setRightNavigationButton(image: UIImage(systemName: "arrowshape.turn.up.backward.fill"), selector: #selector(turnBackToIntro))
        
        animateIntroLabel(showing: false) { [weak self] in
            self?.introLabel.isHidden = true
        }
        targetTypeSegmentedControl.isHidden = false
        animateTargetTypeSegmentedControl(showing: true)
        circleView.isHidden = false
        animateCircleView(showing: true)
        
        addTargetButton.removeTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        addTargetButton.addTarget(self, action: #selector(setTargetButtonTap), for: .touchUpInside)
        
        setQuitDaysInitialLimitLabelConstraints()
        setSecondCircleViewConstraints()
        setInitialLimitTextFieldConstraints()
        segmentSelected()
    }
    
    /// Target action for addTargetButton that replaces addButtonTapped() target by first tap, confirmes entered by user target setting
    @objc
    private func setTargetButtonTap() {
        do {
            try saveTarget()
        } catch {
            print(error)
            return
        }
        
        animateCircleView(showing: false) { [weak self] in
            self?.circleView.isHidden = true
        }
        animateTargetTypeSegmentedControl(showing: false) { [weak self] in
            self?.targetTypeSegmentedControl.isHidden = true
        }
        animateAddTargetButton(showing: false) { [weak self] in
            self?.addTargetButton.isHidden = true
        }
        animateInitialLimitView(showing: false) { [weak self] in
            self?.quitDaysInitialLimitLabel.isHidden = true
            self?.secondCircleView.isHidden = true
        }
        
        setTargetViews()
        animateTargetTypeLabel(showing: true)
        animateTargetValueLabel(showing: true)
        animateTargetFulfilmentDescriptionLabel(showing: true)
        animateTargetFulfilmentLabel(showing: true)
    }
    
    /// Cancels target adding
    @objc
    private func turnBackToIntro() {
        // If target is not set, button just returns to intoLabel
        guard let _ = viewModel.target else {
            limitTextField.resignFirstResponder()
            initialLimitTextField.resignFirstResponder()
            addTargetButton.removeTarget(self, action: #selector(setTargetButtonTap), for: .touchUpInside)
            addTargetButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
            
            introLabel.isHidden = false
            animateIntroLabel(showing: true)
            animateTargetTypeSegmentedControl(showing: false) { [weak self] in
                self?.targetTypeSegmentedControl.isHidden = true
            }
            animateCircleView(showing: false) { [weak self] in
                self?.circleView.isHidden = true
            }
            animateInitialLimitView(showing: false) { [weak self] in
                self?.quitDaysInitialLimitLabel.isHidden = true
                self?.secondCircleView.isHidden = true
            }
            
            navigationItem.setRightBarButton(nil, animated: true)
            return
        }
    }
    
    /// Target action for selecting any segments in targetTypeSegmentedControl
    @objc
    private func segmentSelected() {
        if let target = viewModel.target {
            switch targetTypeSegmentedControl.selectedSegmentIndex {
            case 0:
                animateInitialLimitView(showing: false) { [weak self] in
                    self?.quitDaysInitialLimitLabel.isHidden = true
                    self?.secondCircleView.isHidden = true
                }
                switch target.userTarget {
                case .dayLimit(from: _, smokes: let limit):
                    limitTextField.text = String(limit)
                default:
                    break
                }
            case 1:
                quitDaysInitialLimitLabel.isHidden = false
                secondCircleView.isHidden = false
                animateInitialLimitView(showing: true)
                switch target.userTarget {
                case .quitTime:
                    limitTextField.text = String(viewModel.countLeftDaysToQuitSmoking() ?? 0)
                default:
                    break
                }
            default:
                limitTextField.text = "0"
            }
        }
        else {
            switch targetTypeSegmentedControl.selectedSegmentIndex {
            case 0:
                // Recommended value is minimal registered smokes amount ever, except 0 value
                if let recommendedValue = viewModel.getAllTimeMinimalSmokes() {
                    limitTextField.text = String(recommendedValue)
                } else {
                    limitTextField.text = "0"
                }
                animateInitialLimitView(showing: false) { [weak self] in
                    self?.quitDaysInitialLimitLabel.isHidden = true
                    self?.secondCircleView.isHidden = true
                }
            case 1:
                limitTextField.text = "30"
                quitDaysInitialLimitLabel.isHidden = false
                secondCircleView.isHidden = false
                animateInitialLimitView(showing: true)
            default:
                limitTextField.text = "0"
            }
        }
    }
    
    /// Action for editing set target
    @objc
    private func editTarget() {
        setTargetTypeSegmentedControlConstraints()
        setCircleViewConstraints()
        setAddTargetButtonConstraints()
        setLimitTextFieldConstraints()
        addDoneButtonToKeyboard(for: limitTextField)
        addDoneButtonToKeyboard(for: initialLimitTextField)
        setQuitDaysInitialLimitLabelConstraints()
        setSecondCircleViewConstraints()
        setInitialLimitTextFieldConstraints()
        
        animateTargetTypeLabel(showing: false) { [weak self] in
            self?.targetTypeLabel.isHidden = true
        }
        animateTargetValueLabel(showing: false) { [weak self] in
            self?.targetValue.isHidden = true
        }
        animateTargetFulfilmentDescriptionLabel(showing: false) { [weak self] in
            self?.targetFulfilmentDescriptionLabel.isHidden = true
        }
        animateTargetFulfilmentLabel(showing: false) { [weak self] in
            self?.targetFulfilmentLabel.isHidden = true
        }
        
        targetTypeSegmentedControl.isHidden = false
        animateTargetTypeSegmentedControl(showing: true)
        circleView.isHidden = false
        animateCircleView(showing: true)
        addTargetButton.isHidden = false
        animateAddTargetButton(showing: true)
        setRightNavigationButton(image: UIImage(systemName: "arrowshape.turn.up.backward.fill"), selector: #selector(cancelEditing))
        navigationItem.setLeftBarButton(nil, animated: true)
        
        addTargetButton.removeTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        addTargetButton.addTarget(self, action: #selector(setTargetButtonTap), for: .touchUpInside)
        
        guard let target = viewModel.target else { return }
        switch target.userTarget {
        case .dayLimit:
            targetTypeSegmentedControl.selectedSegmentIndex = 0
        case .quitTime:
            targetTypeSegmentedControl.selectedSegmentIndex = 1
        }
        segmentSelected()
    }
    
    /// Cancels editing
    @objc
    private func cancelEditing() {
        limitTextField.resignFirstResponder()
        initialLimitTextField.resignFirstResponder()
        
        animateTargetTypeSegmentedControl(showing: false) { [weak self] in
            self?.targetTypeSegmentedControl.isHidden = true
        }
        animateCircleView(showing: false) { [weak self] in
            self?.circleView.isHidden = true
        }
        animateAddTargetButton(showing: false) { [weak self] in
            self?.addTargetButton.isHidden = true
        }
        animateInitialLimitView(showing: false) { [weak self] in
            self?.quitDaysInitialLimitLabel.isHidden = true
            self?.secondCircleView.isHidden = true
        }
        
        targetTypeLabel.isHidden = false
        targetValue.isHidden = false
        targetFulfilmentDescriptionLabel.isHidden = false
        targetFulfilmentLabel.isHidden = false
        animateTargetTypeLabel(showing: true)
        animateTargetValueLabel(showing: true)
        animateTargetFulfilmentDescriptionLabel(showing: true)
        animateTargetFulfilmentLabel(showing: true)
        
        setRightNavigationButton(image: UIImage(systemName: "pencil.line"), selector: #selector(editTarget))
        setLeftNavigationButton(image: UIImage(systemName: "trash"), selector: #selector(deleteTarget))
    }
    
    /// Delete target
    @objc
    private func deleteTarget() {
        let alertController = UIAlertController(
            title: "DELETE TARGET",
            message: "Are you sure that you want to delete smoking target?",
            preferredStyle: .alert
        )
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.viewModel.deleteTarget()
            self?.animateTargetFulfilmentDescriptionLabel(showing: false)
            self?.animateTargetFulfilmentLabel(showing: false)
            self?.animateTargetTypeLabel(showing: false)
            self?.animateTargetValueLabel(showing: false) {
                self?.setIntroAndToolsToSetTargetViews()
                self?.animateAddTargetButton(showing: true)
                self?.animateIntroLabel(showing: true)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        present(alertController, animated: true)
    }
    
    @objc
    private func keyboardWillShow(notification: NSNotification) {
        if initialLimitTextField.isFirstResponder {
            targetTypeSegmentedControl.isEnabled = false
            limitTextField.isEnabled = false
            targetTypeSegmentedControl.alpha = 0
            circleView.alpha = 0.5
            
            quitDaysLimitLabelTopConstraint.constant = circleViewInitialY - quitDaysInitialLimitLabel.bounds.height - 10
            UIView.animate(withDuration: 0.5, delay: 0) { [weak self] in
                self?.view.layoutIfNeeded()
            }
        } else if limitTextField.isFirstResponder {
            initialLimitTextField.isEnabled = false
        }
    }
    
    @objc
    private func keyboardWillHide(notification: NSNotification) {
        if initialLimitTextField.isFirstResponder {
            targetTypeSegmentedControl.isEnabled = true
            limitTextField.isEnabled = true
            targetTypeSegmentedControl.alpha = 1
            circleView.alpha = 1
            
            quitDaysLimitLabelTopConstraint.constant = quitDaysLimitLabelInitialY
            UIView.animate(withDuration: 0.5, delay: 0) { [weak self] in
                self?.view.layoutIfNeeded()
            }
        } else if limitTextField.isFirstResponder {
            initialLimitTextField.isEnabled = true
        }
    }
}

//MARK: UITextFieldDelegate extension
extension TargetViewController: UITextFieldDelegate {
    /// Checks if value in TextField contains zero in the start
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let string = textField.text else {
            print("Unable to get text from textField")
            textField.text = "0"
            return
        }
        guard let number = Int(string) else {
            print("Unable to convert String to Int16")
            textField.text = "0"
            return
        }
        textField.text = String(number)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let string = textField.text, let number = Int(string), number == 0 else {
            return
        }
        textField.text = nil
    }
}
