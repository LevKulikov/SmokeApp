//
//  DayViewController.swift
//  SmokeApp
//
//  Created by Лев Куликов on 01.02.2023.
//

import UIKit
import RxSwift
import ViewAnimator

protocol DayViewControllerPotocol: AnyObject {
    
}

/// ViewController that defines view appearence for daily data input, that is shown after selecting cell from CalendarViewController
final class DayViewController: UIViewController, DayViewControllerPotocol {
    //MARK: Properties
    /// Contains view model reference to bind with
    private let viewModel: DayViewModelProtocol
    
    /// Bag to dispose RxSwift items
    private let disposeBag = DisposeBag()
    
    /// Flag that identifies if todays limit is exceeded, when this property is set, observer fulfils task
    private var limitIsExceeded: Bool = false {
        didSet {
            // Prevent showing
            guard limitIsExceeded != oldValue else { return }
            limitWasExceeded(isExceeded: limitIsExceeded, animate: limitExceedingAnimationNeeded)
            if limitExceedingAnimationNeeded, limitIsExceeded {
                HapticManagere.shared.impactVibration(style: .heavy)
            }
        }
    }
    
    /// Flag that identifies if limit excess animation is needed
    private var limitExceedingAnimationNeeded: Bool = false
    
    /// View for background circle for countTextField
    private lazy var circleView: UIView = {
        let circleView = UIView()
        circleView.translatesAutoresizingMaskIntoConstraints = false
        circleView.backgroundColor = .systemBlue
        circleView.isUserInteractionEnabled = true
        circleView.isHidden = false
        return circleView
    }()
    
    /// TextField to set count number from SmokeItem
    private lazy var countTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textAlignment = .center
        textField.textColor = .white
        textField.tintColor = .systemGray
        textField.keyboardType = .numberPad
        textField.returnKeyType = .done
        textField.borderStyle = .none
        textField.placeholder = "0"
        textField.delegate = self
        
        /// Filters only number values
        textField
            .rxAcceptingOnlyInt16Field(successCompletion: { [weak self] int16Value in
                guard let limit = self?.viewModel.selectedSmokeItem.targetAmount as? Int16 else { return }
                if int16Value > limit {
                    self?.limitIsExceeded = true
                } else {
                    self?.limitIsExceeded = false
                }
            })
            .disposed(by: disposeBag)
        
        return textField
    }()
    
    /// Button that decreases smoke count value
    private lazy var decreaseButton: UIButton = {
        //TODO: Change image size
        var buttonCongig = UIButton.Configuration.borderedProminent()
        buttonCongig.cornerStyle = .large
        buttonCongig.baseBackgroundColor = .systemRed
        buttonCongig.image = UIImage(systemName: "arrow.down.circle.fill")
        buttonCongig.imagePadding = 10
        buttonCongig.imagePlacement = .trailing
        buttonCongig.title = "Decrease"
        buttonCongig.titleAlignment = .center
        
        let button = UIButton(configuration: buttonCongig)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(decreaseButtonPressed), for: .touchUpInside)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(decreaseButtonPressed))
        button.addGestureRecognizer(longPress)
        
        return button
    }()
    
    /// Button that increases smoke count value
    private lazy var increaseButton: UIButton = {
        //TODO: Change image size
        var buttonCongig = UIButton.Configuration.borderedProminent()
        buttonCongig.cornerStyle = .large
        buttonCongig.baseBackgroundColor = .systemGreen
        buttonCongig.image = UIImage(systemName: "arrow.up.circle.fill")
        buttonCongig.imagePadding = 10
        buttonCongig.imagePlacement = .trailing
        buttonCongig.title = "Increase"
        buttonCongig.titleAlignment = .center
        
        let button = UIButton(configuration: buttonCongig)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(increaseButtonPressed), for: .touchUpInside)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(increaseButtonPressed))
        button.addGestureRecognizer(longPress)
        
        return button
    }()
    
    /// Label shows smoke limit for selected day
    private lazy var limitLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .systemGray5
        label.textColor = .systemGreen
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 20)
        label.layer.cornerRadius = 20
        label.clipsToBounds = true
        return label
    }()
    
    //MARK: Initializer
    init(viewModel: DayViewModelProtocol) {
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
        title = viewModel.selectedSmokeItem.date?.formatted(date: .abbreviated, time: .omitted)
        
        setBindingWithViewModel()
        countTextField.text = String(describing: viewModel.selectedSmokeItem.amount)
        view.addSubviews(circleView, decreaseButton, increaseButton)
        circleView.addSubview(countTextField)
        addLimitLabelIfNeeded()
        
        checkLimitExcess()
        
        animateCircleView()
        animateLimitLabel()
        // When app is went to background, this code saves set smoke data
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(
            self,
            selector: #selector(saveCountData),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addDoneButtonToKeyboard()
        setCircleViewConstraints()
        setCountTextFieldConstraints()
        setButtonsConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        limitExceedingAnimationNeeded = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveCountData()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        countTextField.resignFirstResponder()
    }
    //MARK: Methods
    /// Sets layout constraints to circleView
    private func setCircleViewConstraints() {
        let multiplier: CGFloat = 0.65
        let maxDimensionValue: CGFloat = 300
        var topAnchorConstant: CGFloat = 60
        if view.safeAreaLayoutGuide.layoutFrame.height < 570 {
            topAnchorConstant = 30
        }
        
        let imageViewHeightAnchor = circleView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: multiplier)
        imageViewHeightAnchor.priority = .defaultHigh
        let imageViewHeightAnchorMax = circleView.heightAnchor.constraint(lessThanOrEqualToConstant: maxDimensionValue)
        imageViewHeightAnchorMax.priority = .required
        
        NSLayoutConstraint.activate([
            circleView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: topAnchorConstant),
            circleView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            imageViewHeightAnchor,
            imageViewHeightAnchorMax,
            circleView.widthAnchor.constraint(equalTo: circleView.heightAnchor)
        ])
        circleView.layer.cornerRadius = circleView.safeAreaLayoutGuide.layoutFrame.width / 2
    }
    
    /// Sets layout constraints to countTextField **and text font depending on circleView width**
    private func setCountTextFieldConstraints() {
        NSLayoutConstraint.activate([
            countTextField.topAnchor.constraint(equalTo: circleView.topAnchor),
            countTextField.bottomAnchor.constraint(equalTo: circleView.bottomAnchor),
            countTextField.leftAnchor.constraint(equalTo: circleView.leftAnchor),
            countTextField.rightAnchor.constraint(equalTo: circleView.rightAnchor)
        ])
        countTextField.font = .boldSystemFont(ofSize: circleView.safeAreaLayoutGuide.layoutFrame.width * 0.35)
    }
    
    /// Sets layout constraints to decrease and increase buttons
    private func setButtonsConstraints() {
        let buttonHightConstraint = decreaseButton.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 1/5)
        buttonHightConstraint.priority = .defaultHigh
        let buttonHightConstraintMax = decreaseButton.heightAnchor.constraint(lessThanOrEqualToConstant: 130)
        buttonHightConstraintMax.priority = .required
        
        NSLayoutConstraint.activate([
            buttonHightConstraint,
            buttonHightConstraintMax,
            decreaseButton.widthAnchor.constraint(equalTo: decreaseButton.heightAnchor, multiplier: 2),
            decreaseButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 25),
            decreaseButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            
            increaseButton.heightAnchor.constraint(equalTo: decreaseButton.heightAnchor),
            increaseButton.widthAnchor.constraint(equalTo: decreaseButton.widthAnchor),
            increaseButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -25),
            increaseButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
        ])
    }
    
    /// Sets layout constraints to limitLabel
    private func setLimitLabelConstraints() {
        NSLayoutConstraint.activate([
            limitLabel.heightAnchor.constraint(equalToConstant: 40),
            limitLabel.widthAnchor.constraint(equalToConstant: 200),
            limitLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            limitLabel.topAnchor.constraint(equalTo: circleView.bottomAnchor, constant: 30)
        ])
    }
    
    /// Animates showing or disappearing of circleView
    /// - Parameters:
    ///   - showing: true = view will be shown, false = view will disappeare. Default is true
    ///   - completion: closure which will be executed after animation ends (showing or disappearing)
    private func animateCircleView(showing: Bool = true, completion: (() -> Void)? = nil) {
        circleView.isHidden = false
        let animation = AnimationType.from(direction: .right, offset: 300)
        if showing {
            circleView.animate(
                animations: [animation],
                duration: 0.4,
                completion: completion
            )
        } else {
            circleView.animate(
                animations: [animation],
                reversed: true,
                initialAlpha: 1,
                finalAlpha: 0,
                duration: 0.2,
                completion: completion
            )
        }
    }
    
    /// Animates showing or disappearing of limitLabel
    /// - Parameters:
    ///   - showing: true = view will be shown, false = view will disappeare. Default is true
    ///   - completion: closure which will be executed after animation ends (showing or disappearing)
    private func animateLimitLabel(showing: Bool = true, completion: (() -> Void)? = nil) {
        let animation = AnimationType.from(direction: .right, offset: 300)
        if showing {
            limitLabel.animate(
                animations: [animation],
                delay: 0.07,
                duration: 0.4,
                completion: completion
            )
        } else {
            limitLabel.animate(
                animations: [animation],
                reversed: true,
                initialAlpha: 1,
                finalAlpha: 0,
                duration: 0.2,
                completion: completion
            )
        }
    }
    
    /// Animates showing or disappearing of buttons. If you need completion execution, past closure to animatecircleView(completion:)
    /// - Parameters:
    ///   - showing: true = view will be shown, false = view will disappeare. Default is true
    private func animateButtons(showing: Bool = true) {
        let animationLeft = AnimationType.from(direction: .bottom, offset: 200)
        let animationRight = AnimationType.from(direction: .bottom, offset: 200)
        if showing {
            decreaseButton.animate(
                animations: [animationLeft],
                duration: 0.4
            )
            increaseButton.animate(
                animations: [animationRight],
                duration: 0.4
            )
        } else {
            decreaseButton.animate(
                animations: [animationLeft],
                reversed: true,
                initialAlpha: 1,
                finalAlpha: 0,
                duration: 0.4
            )
            increaseButton.animate(
                animations: [animationRight],
                reversed: true,
                initialAlpha: 1,
                finalAlpha: 0,
                duration: 0.4
            )
        }
    }
    
    /// Shows user that daily limit is exceeded by changing views
    /// - Parameters:
    ///   - isExceeded: true - limit is exceeded, false - it is not, this parameter identifies what animation should be shown
    ///   - animate: identifies if animation should be shown
    ///   - completion: block that is perfermed after animation ends
    private func limitWasExceeded(isExceeded: Bool = true, animate: Bool, completion: ((Bool) -> Void)? = nil) {
        var animationClosure: () -> Void
        if isExceeded {
            animationClosure = { [weak self] in
                self?.view.backgroundColor = .systemRed
                self?.circleView.backgroundColor = Constants.shared.viewControllerBackgroundColor
                self?.limitLabel.backgroundColor = Constants.shared.viewControllerBackgroundColor
                self?.limitLabel.textColor = .red
                self?.countTextField.textColor = .label
                self?.decreaseButton.configuration?.baseBackgroundColor = .red
            }
        } else {
            animationClosure = { [weak self] in
                self?.view.backgroundColor = Constants.shared.viewControllerBackgroundColor
                self?.circleView.backgroundColor = .systemBlue
                self?.limitLabel.backgroundColor = .systemGray5
                self?.limitLabel.textColor = .systemGreen
                self?.countTextField.textColor = .white
                self?.decreaseButton.configuration?.baseBackgroundColor = .systemRed
            }
        }
        
        if animate {
            UIView.animate(
                withDuration: 0.4,
                delay: 0,
                animations: animationClosure,
                completion: completion
            )
            
        } else {
            animationClosure()
            completion?(true)
        }
    }
    
    /// Checks if limit is exceeded
    private func checkLimitExcess() {
        if viewModel.isLimitExceeded {
            limitIsExceeded = true
        }
    }
    
    /// Adds button above keyboard to turn down keyboard
    private func addDoneButtonToKeyboard() {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen().bounds.width, height: 50))
        toolBar.barStyle = .default
        toolBar.backgroundColor = .clear
        
        let spaceButton = UIBarButtonItem.flexibleSpace()
        let doneButton = UIBarButtonItem(
            image: UIImage(systemName: "keyboard.chevron.compact.down"),
            style: .done,
            target: self,
            action: #selector(donePuttonTapped)
        )
        
        toolBar.setItems([spaceButton, doneButton], animated: true)
        toolBar.sizeToFit()
        countTextField.inputAccessoryView = toolBar
    }
    
    /// Puts down keyboard
    @objc private func donePuttonTapped() {
        countTextField.resignFirstResponder()
    }
    
    /// Increases smoke count
    @objc private func increaseButtonPressed() {
        addOneSmoke(increase: true)
    }
    
    /// Decreases smoke count
    @objc private func decreaseButtonPressed() {
        addOneSmoke(increase: false)
    }
    
    /// Change for one smoke of text of countTextField
    /// - Parameter increase: indicates if value should be increased by 1 or decrease
    private func addOneSmoke(increase: Bool) {
        let valueToAdd = increase ? 1 : -1
        let textFieldString = countTextField.text != nil ? countTextField.text! : "0"
        guard let textFieldInt = Int(textFieldString) else {
            print("class: DayViewController; method: addOneSmoke(increase:); Unable to get Int from textField String")
            return
        }
        let resultingValue = textFieldInt + valueToAdd >= 0 ? textFieldInt + valueToAdd : 0
        countTextField.text = String( resultingValue <= 32767 ? resultingValue : 32767 )
        
        guard let limit = viewModel.selectedSmokeItem.targetAmount as? Int else { return }
        if resultingValue > limit {
            limitIsExceeded = true
        } else {
            limitIsExceeded = false
        }
    }
    
    /// Saves set amount of smokes to the DataStorage
    @objc private func saveCountData() {
        guard let string = countTextField.text else {
            print("Unable to get text from textField")
            countTextField.text = "0"
            return
        }
        guard let int16 = Int16(string) else {
            print("Unable to convert String to Int16")
            countTextField.text = "0"
            return
        }
        viewModel.updateSmokeItemCount(with: int16)
    }
    
    /// Adds as subview (and layout) limitLabel if there is set limit for selected day
    private func addLimitLabelIfNeeded() {
        guard let smokeLimit = viewModel.selectedSmokeItem.targetAmount as? Int16, smokeLimit >= 0 else { return }
        view.addSubviews(limitLabel)
        limitLabel.text = "Todays limit: \(smokeLimit)"
        setLimitLabelConstraints()
    }
    
    /// Sets closure to bind with ViewModel
    private func setBindingWithViewModel() {
        let bindingTargetCloser: (Int16?) -> Void = { [weak self] newLimit in
            if let newLimit {
                self?.addLimitLabelIfNeeded()
                self?.limitLabel.text = "Todays limit: \(newLimit)"
                self?.limitLabel.isHidden = false
                guard let smokesAmount = self?.viewModel.selectedSmokeItem.amount else { return }
                self?.limitIsExceeded = smokesAmount > newLimit
            } else {
                self?.limitLabel.text = nil
                self?.limitLabel.isHidden = true
                self?.limitIsExceeded = false
            }
        }
        
        viewModel.targetUpdate = bindingTargetCloser
    }
}

//MARK: UITextFieldDelegate extension
extension DayViewController: UITextFieldDelegate {
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
