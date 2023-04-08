//
//  AccountSettingsViewController.swift
//  SmokeApp
//
//  Created by Лев Куликов on 06.04.2023.
//

import UIKit

/// Protocol for ViewController, that provides UI to set account info
protocol AccountSettingsViewControllerProtocol: AnyObject {
    
}

class AccountSettingsViewController: UIViewController, AccountSettingsViewControllerProtocol {
    //MARK: Properties
    /// ViewModel for AccountSettingsViewController
    private let viewModel: AccountSettingsViewModelProtocol
    
    /// Done button to dismiss view and save account data
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Done", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(dismissAndSave), for: .touchUpInside)
        return button
    }()
    
    /// ImageView that displays and change logo of user
    private lazy var accountImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.image = UIImage(systemName: AccountDataStorage.defaultImageName)
        imageView.tintColor = .systemGray
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTappedToSetImage))
        imageView.addGestureRecognizer(tapGesture)
        return imageView
    }()
    
    /// Text field to edit account name
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.placeholder = "Your name"
        textField.textAlignment = .center
        textField.borderStyle = .none
        textField.font = .boldSystemFont(ofSize: 25)
        textField.returnKeyType = .done
        textField.clearButtonMode = .whileEditing
        textField.autocorrectionType = .no
        return textField
    }()
    
    /// Label for description that downside is gender picker
    private lazy var genderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.font = .systemFont(ofSize: 20)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.text = "Gender"
        return label
    }()
    
    /// TextField to call PickerView to set gender
    private lazy var genderTextField: NoActionTextField = {
        let textField = NoActionTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.textAlignment = .center
        textField.borderStyle = .none
        textField.autocorrectionType = .no
        textField.font = .systemFont(ofSize: 23)
        textField.tintColor = .clear
        textField.inputView = genderPickerView
        return textField
    }()
    
    /// Gender picker
    private lazy var genderPickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.dataSource = self
        pickerView.delegate = self
        return pickerView
    }()
    
    //MARK: Initializer
    init(viewModel: AccountSettingsViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        print("AccountSettingsViewController init?(coder:) is unsupported")
        return nil
    }
    
    //MARK: Lyfe Cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.shared.viewControllerBackgroundColor
        view.addSubviews(
            doneButton,
            accountImageView,
            nameTextField,
            genderLabel,
            genderTextField
        )
        setAccountData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setDoneButtonConstraints()
        setAccountImageViewConstraints()
        setNameTextFieldConstraints()
        setGenderLabelConstraints()
        setGenderTextFieldConstraints()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        nameTextField.resignFirstResponder()
        genderTextField.resignFirstResponder()
    }
    
    //MARK: Methods
    /// Sets constraints to doneButton
    private func setDoneButtonConstraints() {
        NSLayoutConstraint.activate([
            doneButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            doneButton.heightAnchor.constraint(equalToConstant: 30),
            doneButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -5),
            doneButton.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    /// Sets constraints to accountImageView
    private func setAccountImageViewConstraints() {
        let padding: CGFloat = 130
        NSLayoutConstraint.activate([
            accountImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            accountImageView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: padding),
            accountImageView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -padding),
            accountImageView.heightAnchor.constraint(equalToConstant: view.bounds.width - padding * 2)
        ])
    }
    
    /// Sets constraints to nameTextField
    private func setNameTextFieldConstraints() {
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: accountImageView.bottomAnchor, constant: 30),
            nameTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            nameTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20)
        ])
    }
    
    /// Sets constraints to genderLabel
    private func setGenderLabelConstraints() {
        NSLayoutConstraint.activate([
            genderLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 30),
            genderLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            genderLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            genderLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    /// Sets constraints to genderTextField
    private func setGenderTextFieldConstraints() {
        NSLayoutConstraint.activate([
            genderTextField.topAnchor.constraint(equalTo: genderLabel.bottomAnchor),
            genderTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 70),
            genderTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -70),
        ])
    }
    
    /// Sets previously saved data
    private func setAccountData() {
        nameTextField.text = viewModel.accountName
        genderTextField.text = viewModel.accountGender.rawValue
    }
    
    /// Saves entered by user account info
    private func saveAccountInfo() {
        //TODO: Save data when closing
        checkIfTextFieldEmpty()
        viewModel.accountName = nameTextField.text!
        if let textFromTextField = genderTextField.text, let pickedGender = Gender(rawValue: textFromTextField) {
            viewModel.accountGender = pickedGender
        }
    }
    
    /// Checks if nameTextField is epty, and if it is, sets default name into it
    private func checkIfTextFieldEmpty() {
        guard let text = nameTextField.text, !text.isEmpty else {
            nameTextField.text = AccountDataStorage.defaultName
            return
        }
    }
    
    /// Dismisses view and saves set data
    @objc
    private func dismissAndSave() {
        saveAccountInfo()
        presentationDelegate?.presentationWillEnd?(for: self)
        dismiss(animated: true)
    }
    
    /// Provides interface to change account image
    @objc
    private func imageViewTappedToSetImage() {
        //TODO: Continue this method, call alert (change or delete) and add photo picker
        print("ImageViewTapped")
    }
}

//MARK: TextField delegate
extension AccountSettingsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        func errorReturn() {
//            HapticManagere.shared.notificationVibrate(type: .error)
//            UIView.animate(
//                withDuration: 0.3,
//                delay: 0) {
//                    textField.backgroundColor = .systemRed
//                } completion: { _ in
//                    textField.backgroundColor = nil
//                }
//        }
//        guard let textFromTextField = textField.text else {
//            errorReturn()
//            return false
//        }
//
//        guard !textFromTextField.isEmpty else {
//            errorReturn()
//            return false
//        }
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        UIView.animate(
            withDuration: 0.3,
            delay: 0) {
                textField.borderStyle = .roundedRect
            }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == genderTextField {
            return false
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(
            withDuration: 0.3,
            delay: 0) {
                textField.borderStyle = .none
            }
        switch textField {
        case nameTextField:
            checkIfTextFieldEmpty()
        default:
            break
        }
    }
}

//MARK: UIPickerViewDataSource, UIPickerViewDelegate
extension AccountSettingsViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Gender.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Gender.allCases[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genderTextField.text = Gender.allCases[row].rawValue
        genderTextField.resignFirstResponder()
    }
}
