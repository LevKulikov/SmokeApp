//
//  AccountSettingsViewController.swift
//  SmokeApp
//
//  Created by Лев Куликов on 06.04.2023.
//

import UIKit
import PhotosUI

/// Protocol for ViewController, that provides UI to set account info
protocol AccountSettingsViewControllerProtocol: AnyObject {
    
}

class AccountSettingsViewController: UIViewController, AccountSettingsViewControllerProtocol {
    //MARK: Properties
    /// ViewModel for AccountSettingsViewController
    private let viewModel: AccountSettingsViewModelProtocol
    
    /// Instance to store image name
    private var imageData: Data? {
        didSet {
            guard let imageData else {
                accountImageView.image = UIImage(systemName: AccountDataStorage.defaultImageName)
                return
            }
            accountImageView.image = UIImage(data: imageData)
        }
    }
    
    /// Instance to srore user's birth year
    private var userBirthYear: Int? {
        didSet {
            guard
                let userBirthYear,
                userBirthYear > 0,
                let index = yearsData.firstIndex(of: userBirthYear)
            else {
                birthYearTextField.text = "Unidentified"
                return
            }
            birthYearTextField.text = String(userBirthYear)
            birthYearPickerView.selectRow(index, inComponent: 0, animated: false)
        }
    }
    
    /// Array of year to set in birthYearPickerView
    private var yearsData: [Int] = []
    
    /// Constraint for birth label that changes
    private var birthLabelChangeableYConstraint: NSLayoutConstraint!
    
    /// Standart Y constant for birth label
    private var birthLabelYConstant: CGFloat = 45
    
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
        imageView.tintColor = .systemGray
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        
        imageView.layer.borderColor = UIColor.systemGray.cgColor
        imageView.layer.borderWidth = 3
        
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
        textField.autocorrectionType = .no
        return textField
    }()
    
    /// Picker for photos to set it in account image
    private lazy var photoPickerController: PHPickerViewController = {
        var pickerConfig = PHPickerConfiguration()
        pickerConfig.filter = .images
        pickerConfig.selectionLimit = 1
        pickerConfig.preferredAssetRepresentationMode = .compatible
        let photoPicker = PHPickerViewController(configuration: pickerConfig)
        photoPicker.delegate = self
        return photoPicker
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
    
    /// Description label for birth year picker view
    private lazy var birthYearLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.font = .systemFont(ofSize: 20)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.text = "Birth year"
        return label
    }()
    
    /// TextField to display date picker to set birth year
    private lazy var birthYearTextField: NoActionTextField = {
        let textField = NoActionTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.textAlignment = .center
        textField.borderStyle = .none
        textField.autocorrectionType = .no
        textField.font = .systemFont(ofSize: 23)
        textField.tintColor = .clear
        return textField
    }()
    
    /// DatePicker to pick birth year
    private lazy var birthYearPickerView: UIPickerView = {
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
            genderTextField,
            birthYearLabel,
            birthYearTextField
        )
        setAccountData()
        birthLabelChangeableYConstraint = birthYearLabel.topAnchor.constraint(equalTo: genderTextField.centerYAnchor, constant: 30 + 15)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setDoneButtonConstraints()
        setAccountImageViewConstraints()
        setNameTextFieldConstraints()
        setGenderLabelConstraints()
        setGenderTextFieldConstraints()
        setBirthYearLabelConstraints()
        setBirthYaerTextFieldConstraints()
        setBirthYearTextFieldInputViews()
        if view.bounds.height < 700 {
            changeBirthYearViewWithKeyboard()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    //MARK: Methods
    /// Sets constraints to doneButton
    private func setDoneButtonConstraints() {
        NSLayoutConstraint.activate([
            doneButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            doneButton.heightAnchor.constraint(equalToConstant: 30),
            doneButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -5),
            doneButton.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    /// Sets constraints to accountImageView
    private func setAccountImageViewConstraints() {
        let padding: CGFloat = 130
        NSLayoutConstraint.activate([
            accountImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 70),
            accountImageView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: padding),
            accountImageView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -padding),
            accountImageView.heightAnchor.constraint(equalToConstant: view.bounds.width - padding * 2)
        ])
        accountImageView.layer.cornerRadius = accountImageView.bounds.height / 2
    }
    
    /// Sets constraints to nameTextField
    private func setNameTextFieldConstraints() {
        NSLayoutConstraint.activate([
            nameTextField.centerYAnchor.constraint(equalTo: accountImageView.bottomAnchor, constant: 30 + 15),
            nameTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            nameTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20)
        ])
    }
    
    /// Sets constraints to genderLabel
    private func setGenderLabelConstraints() {
        NSLayoutConstraint.activate([
            genderLabel.topAnchor.constraint(equalTo: nameTextField.centerYAnchor, constant: 30 + 15),
            genderLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            genderLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            genderLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    /// Sets constraints to genderTextField
    private func setGenderTextFieldConstraints() {
        NSLayoutConstraint.activate([
            genderTextField.centerYAnchor.constraint(equalTo: genderLabel.bottomAnchor, constant: 15),
            genderTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 70),
            genderTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -70),
        ])
    }
    
    /// Sets constraints to birthYearLabel
    private func setBirthYearLabelConstraints() {
        NSLayoutConstraint.activate([
            birthLabelChangeableYConstraint,
            birthYearLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            birthYearLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            birthYearLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    /// Sets constraints to birthYearTextField
    private func setBirthYaerTextFieldConstraints() {
        NSLayoutConstraint.activate([
            birthYearTextField.centerYAnchor.constraint(equalTo: birthYearLabel.bottomAnchor, constant: 15),
            birthYearTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 70),
            birthYearTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -70),
        ])
    }
    
    /// Sets to birthYearTextField input views and accessory input views
    private func setBirthYearTextFieldInputViews() {
        birthYearTextField.inputView = birthYearPickerView
        
        let toolBar = UIToolbar()
        let deleteBarButton = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(deleteBarButtonPressed))
        let spaceBar = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let saveBarButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveBarButtonPressed))
        toolBar.sizeToFit()
        toolBar.setItems([deleteBarButton, spaceBar, saveBarButton], animated: false)
        
        birthYearTextField.inputAccessoryView = toolBar
    }
    
    /// Configures array of years to set in birthYearPickerView
    private func configureDataForYears() {
        let min = AccountDataStorage.minimumYear
        let max = AccountDataStorage.maximumYear
        for i in (min...max).reversed() {
            yearsData.append(i)
        }
    }
    
    /// Sets previously saved data
    private func setAccountData() {
        configureDataForYears()
        imageData = viewModel.accountImageData
        nameTextField.text = viewModel.accountName
        genderTextField.text = viewModel.accountGender.rawValue
        userBirthYear = viewModel.accountBirthYear
    }
    
    /// Saves entered by user account info
    private func saveAccountInfo() {
        viewModel.accountImageData = imageData
        
        checkIfTextFieldEmpty()
        viewModel.accountName = nameTextField.text!
        
        if let textFromTextField = genderTextField.text, let pickedGender = Gender(rawValue: textFromTextField) {
            viewModel.accountGender = pickedGender
        } else {
            viewModel.accountGender = AccountDataStorage.defaultGender
        }
        
        if let userBirthYear {
            viewModel.accountBirthYear = userBirthYear
        } else {
            viewModel.accountBirthYear = AccountDataStorage.defaultBirthYear
        }
    }
    
    /// Checks if nameTextField is epty, and if it is, sets default name into it
    private func checkIfTextFieldEmpty() {
        guard let text = nameTextField.text, !text.isEmpty else {
            nameTextField.text = AccountDataStorage.defaultName
            return
        }
    }
    
    /// Changes birth year Vies appearance with keyboard showing or hiding
    private func changeBirthYearViewWithKeyboard() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    /// Called when keyboard wiil show
    @objc
    private func keyboardWillShow(notification: NSNotification) {
        if birthYearTextField.isFirstResponder {
            nameTextField.isEnabled = false
            genderTextField.isEnabled = false
            let newAlpha: CGFloat = 0.1
            nameTextField.alpha = newAlpha
            genderLabel.alpha = newAlpha
            genderTextField.alpha = newAlpha
            
            birthLabelChangeableYConstraint.constant = -5
            UIView.animate(withDuration: 0.5, delay: 0) { [weak self] in
                self?.view.layoutIfNeeded()
            }
        }
    }
    
    /// Called when keyboard wiil hide
    @objc
    private func keyboardWillHide(notification: NSNotification) {
        if birthYearTextField.isFirstResponder {
            nameTextField.isEnabled = true
            genderTextField.isEnabled = true
            nameTextField.alpha = 1
            genderLabel.alpha = 1
            genderTextField.alpha = 1
            
            birthLabelChangeableYConstraint.constant = birthLabelYConstant
            UIView.animate(withDuration: 0.5, delay: 0) { [weak self] in
                self?.view.layoutIfNeeded()
            }
        }
    }
    
    /// Dismisses view and saves set data
    @objc
    private func dismissAndSave() {
        saveAccountInfo()
        presentationDelegate?.presentationWillEnd?(for: self)
        dismiss(animated: true)
    }
    
    /// Selector for birthYearTextField toolbar save button
    @objc
    private func saveBarButtonPressed() {
        birthYearTextField.resignFirstResponder()
        let selectedIndex = birthYearPickerView.selectedRow(inComponent: 0)
        userBirthYear = yearsData[selectedIndex]
    }
    
    /// Selector for birthYearTextField toolbar delete button
    @objc
    private func deleteBarButtonPressed() {
        birthYearTextField.resignFirstResponder()
        userBirthYear = 0
    }
    
    /// Provides interface to change account image
    @objc
    private func imageViewTappedToSetImage() {
        guard let _ = imageData else {
            present(photoPickerController, animated: true)
            return
        }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let changePhotoAction = UIAlertAction(title: "Change photo", style: .default) { [weak self] _ in
            guard let self else { return }
            self.present(self.photoPickerController, animated: true)
        }
        let deleteAction = UIAlertAction(title: "Delete photo", style: .destructive) { [weak self] _ in
            self?.imageData = nil
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(changePhotoAction)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
}

//MARK: TextField delegate
extension AccountSettingsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
        if textField == genderTextField || textField == birthYearTextField {
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
        switch pickerView {
        case genderPickerView:
            return Gender.allCases.count
        case birthYearPickerView:
            return yearsData.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case genderPickerView:
            return Gender.allCases[row].rawValue
        case birthYearPickerView:
            return String(yearsData[row])
        default:
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case genderPickerView:
            genderTextField.text = Gender.allCases[row].rawValue
            genderTextField.resignFirstResponder()
        case birthYearPickerView:
            break
        default:
            break
        }
    }
}

//MARK: PHPickerViewControllerDelegate extension
extension AccountSettingsViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard !results.isEmpty else { return }
        let item = results.first!.itemProvider
        if item.canLoadObject(ofClass: UIImage.self) {
            item.loadObject(ofClass: UIImage.self) { [weak self] imageItem, _ in
                DispatchQueue.main.async {
                    let image = imageItem as? UIImage
                    self?.imageData = image?.jpegData(compressionQuality: 0.1)
                }
            }
        }
    }
}
