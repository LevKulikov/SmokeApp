//
//  WelcomeViewController.swift
//  SmokeApp
//
//  Created by Лев Куликов on 21.09.2024.
//

import UIKit

class WelcomeViewController: UIViewController {
    //MARK: - Properties
    private let workingHoursKey = "workingHoursKey"
    private let smokeBreaksKey = "smokeBreaksKey"
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isScrollEnabled = true
        return scrollView
    }()
    
    private lazy var hoursRectangle: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray5
        view.layer.cornerRadius = 16
        return view
    }()
    
    private lazy var hoursLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Enter amount of working hours"
        label.textAlignment = .left
        label.textColor = .label
        label.font = .preferredFont(forTextStyle: .headline)
        return label
    }()
    
    private lazy var hoursPickers: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.dataSource = self
        picker.delegate = self
        return picker
    }()
    
    private lazy var smokeBreaksRectangle: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray5
        view.layer.cornerRadius = 16
        return view
    }()
    
    private lazy var smokeBreaksLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Enter amount of smoke breaks"
        label.textAlignment = .left
        label.textColor = .label
        label.font = .preferredFont(forTextStyle: .headline)
        return label
    }()
    
    private lazy var smokeBreaksDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.text = "The smoke break lasts 15 minutes. If you go out for 30 minutes, choose 2 breaks"
        label.textAlignment = .left
        label.textColor = .label
        label.font = .preferredFont(forTextStyle: .caption1)
        return label
    }()
    
    private lazy var smokeBreaksPickers: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.dataSource = self
        picker.delegate = self
        return picker
    }()
    
    private lazy var saveButton: UIButton = {
        var buttonCongig = UIButton.Configuration.borderedProminent()
        buttonCongig.cornerStyle = .large
        buttonCongig.title = "Save"
        
        let button = UIButton(configuration: buttonCongig)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    //MARK: - ViewController Life Cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        view.addSubview(saveButton)
        
        scrollView.addSubview(hoursRectangle)
        scrollView.addSubview(smokeBreaksRectangle)
        
        hoursRectangle.addSubview(hoursLabel)
        hoursRectangle.addSubview(hoursPickers)
        
        setScrollViewConstraints()
        setSaveButtonConstraints()
        
        setHoursRectangleConstraints()
        setHoursLabelConstraints()
        setHoursPickersConstraints()
        
        smokeBreaksRectangle.addSubview(smokeBreaksLabel)
        smokeBreaksRectangle.addSubview(smokeBreaksDescriptionLabel)
        smokeBreaksRectangle.addSubview(smokeBreaksPickers)
        
        setSmokeBreakRectangleConstraints()
        setSmokeBreakLabelConstraints()
        setSmokeBreaksDescriptionLabelConstraints()
        setSmokeBreaksPickersConstraints()
        
        let selectedHours = UserDefaults.standard.integer(forKey: workingHoursKey)
        hoursPickers.selectRow(selectedHours > 0 ? selectedHours - 1 : 0, inComponent: 0, animated: true)
        
        let smokeBreaks = UserDefaults.standard.integer(forKey: smokeBreaksKey)
        smokeBreaksPickers.selectRow(smokeBreaks, inComponent: 0, animated: true)
    }
    
    //MARK: - Methods
    @objc
    private func saveButtonTapped() {
        dismiss(animated: true)
    }
    
    private func saveHours(_ hours: Int) {
        UserDefaults.standard.set(hours, forKey: workingHoursKey)
    }
    
    private func saveSmokeBreaks(_ breaks: Int) {
        UserDefaults.standard.set(breaks, forKey: smokeBreaksKey)
    }
    
    private func setScrollViewConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func setSaveButtonConstraints() {
        NSLayoutConstraint.activate([
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            saveButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setHoursRectangleConstraints() {
        NSLayoutConstraint.activate([
            hoursRectangle.topAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.topAnchor, constant: 40),
            hoursRectangle.leadingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            hoursRectangle.trailingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            hoursRectangle.bottomAnchor.constraint(equalTo: hoursPickers.bottomAnchor, constant: 10)
        ])
    }
    
    private func setHoursLabelConstraints() {
        NSLayoutConstraint.activate([
            hoursLabel.topAnchor.constraint(equalTo: hoursRectangle.topAnchor, constant: 10),
            hoursLabel.leadingAnchor.constraint(equalTo: hoursRectangle.leadingAnchor, constant: 10)
        ])
    }
    
    private func setHoursPickersConstraints() {
        NSLayoutConstraint.activate([
            hoursPickers.topAnchor.constraint(equalTo: hoursLabel.bottomAnchor, constant: 10),
            hoursPickers.leadingAnchor.constraint(equalTo: hoursRectangle.leadingAnchor),
            hoursPickers.trailingAnchor.constraint(equalTo: hoursRectangle.trailingAnchor),
        ])
    }
    
    private func setSmokeBreakRectangleConstraints() {
        NSLayoutConstraint.activate([
            smokeBreaksRectangle.topAnchor.constraint(equalTo: hoursRectangle.bottomAnchor, constant: 20),
            smokeBreaksRectangle.leadingAnchor.constraint(equalTo: hoursRectangle.leadingAnchor),
            smokeBreaksRectangle.trailingAnchor.constraint(equalTo: hoursRectangle.trailingAnchor),
            smokeBreaksRectangle.bottomAnchor.constraint(equalTo: smokeBreaksPickers.bottomAnchor, constant: 10)
        ])
    }
    
    private func setSmokeBreakLabelConstraints() {
        NSLayoutConstraint.activate([
            smokeBreaksLabel.topAnchor.constraint(equalTo: smokeBreaksRectangle.topAnchor, constant: 10),
            smokeBreaksLabel.leadingAnchor.constraint(equalTo: smokeBreaksRectangle.leadingAnchor, constant: 10)
        ])
    }
    
    private func setSmokeBreaksDescriptionLabelConstraints() {
        NSLayoutConstraint.activate([
            smokeBreaksDescriptionLabel.topAnchor.constraint(equalTo: smokeBreaksLabel.bottomAnchor, constant: 5),
            smokeBreaksDescriptionLabel.leadingAnchor.constraint(equalTo: smokeBreaksLabel.leadingAnchor),
            smokeBreaksDescriptionLabel.trailingAnchor.constraint(equalTo: smokeBreaksRectangle.trailingAnchor, constant: -10)
        ])
    }
    
    private func setSmokeBreaksPickersConstraints() {
        NSLayoutConstraint.activate([
            smokeBreaksPickers.topAnchor.constraint(equalTo: smokeBreaksDescriptionLabel.bottomAnchor, constant: 10),
            smokeBreaksPickers.leadingAnchor.constraint(equalTo: smokeBreaksRectangle.leadingAnchor),
            smokeBreaksPickers.trailingAnchor.constraint(equalTo: smokeBreaksRectangle.trailingAnchor),
        ])
    }
}

extension WelcomeViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        switch pickerView {
        case hoursPickers: return 1
        case smokeBreaksPickers: return 1
        default: return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case hoursPickers: return 24
        case smokeBreaksPickers: return 50
        default: return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case hoursPickers: return "\(row + 1) hour\(row == 1 ? "" : "s")"
        case smokeBreaksPickers: return String(row)
        default: return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case hoursPickers: saveHours(row + 1)
        case smokeBreaksPickers: saveSmokeBreaks(row)
        default: break
        }
    }
}
