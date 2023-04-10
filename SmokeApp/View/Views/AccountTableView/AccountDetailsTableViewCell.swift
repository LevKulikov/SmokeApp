//
//  AccountDetailsTableViewCell.swift
//  SmokeApp
//
//  Created by Лев Куликов on 04.04.2023.
//

import UIKit

/// TableVIew Cell to show user account information
class AccountDetailsTableViewCell: UITableViewCell {
    //MARK: Properties
    /// ImageView that displays logo of user
    private lazy var accountImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.image = UIImage(systemName: AccountDataStorage.defaultImageName)
        imageView.tintColor = .systemGray
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    /// Label to show user's name
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 22)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var genderAndBirthYearLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17)
        label.textColor = .secondaryLabel
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    //MARK: Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator
        backgroundColor = Constants.shared.cellBackgroundColor
        clipsToBounds = true
        contentView.addSubviews(accountImageView, nameLabel, genderAndBirthYearLabel)
    }
    
    required init?(coder: NSCoder) {
        print("AccountDetailsTableViewCell init?(coder:) is not supported")
        return nil
    }
    
    //MARK: Lyfe Cycle methods
    override func layoutSubviews() {
        super.layoutSubviews()
        setAccountImageViewConstraints()
        setNameLabelConstraints()
        setGenderAndBirthYearLabelConstraints()
    }
    
    //MARK: Methods
    /// Sets constraints to accountImageView
    private func setAccountImageViewConstraints() {
        let padding: CGFloat = 10
        NSLayoutConstraint.activate([
            accountImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            accountImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding),
            accountImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: padding),
            accountImageView.widthAnchor.constraint(equalToConstant: contentView.bounds.height - 2 * padding),
        ])
        accountImageView.layoutIfNeeded()
        accountImageView.layer.cornerRadius = accountImageView.bounds.width / 2
    }
    
    /// Sets constraints to nameLabel
    private func setNameLabelConstraints() {
        let contentViewHeight = contentView.bounds.height
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: contentViewHeight * 0.25),
            nameLabel.heightAnchor.constraint(equalToConstant: 25),
            nameLabel.leftAnchor.constraint(equalTo: accountImageView.rightAnchor, constant: 20),
            nameLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20)
        ])
    }
    
    /// Sets constraints to genderAndBirthYearLabel
    private func setGenderAndBirthYearLabelConstraints() {
        NSLayoutConstraint.activate([
            genderAndBirthYearLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            genderAndBirthYearLabel.heightAnchor.constraint(equalToConstant: 20),
            genderAndBirthYearLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor),
            genderAndBirthYearLabel.rightAnchor.constraint(equalTo: nameLabel.rightAnchor)
        ])
    }
    
    /// Provides string to set in genderAndBirthYearLabel
    /// - Parameters:
    ///   - gender: user's gender, nil = unidentified
    ///   - birthYear: user's birth year, nil and 0 value hides year in return string
    /// - Returns: String to set in the label
    private func getGenderAndYearString(gender: Gender?, birthYear: Int?) -> String {
        var stringToReturn: String
        if let gender {
            stringToReturn = gender.rawValue
        } else {
            stringToReturn = Gender.unidentified.rawValue
        }
        
        guard let birthYear, birthYear > 0 else {
            return stringToReturn
        }
        stringToReturn += ", " + String(birthYear)
        return stringToReturn
    }
    
    /// Configures cell with image and name of an account
    /// - Parameters:
    ///   - image: account image to set in cell, provide nil to set default image
    ///   - name: account name to set in cell
    ///   - gender: user's gender, nil = unidentified
    ///   - birthYear: user's birth year, nil and 0 value hides year in return string
    func configure(imageData: Data?, name: String, gender: Gender?, birthYear: Int?) {
        if let imageData {
            DispatchQueue.main.async { [weak self] in
                self?.accountImageView.image = UIImage(data: imageData)
            }
        } else {
            accountImageView.image = UIImage(systemName: AccountDataStorage.defaultImageName)
        }
        nameLabel.text = name
        genderAndBirthYearLabel.text = getGenderAndYearString(gender: gender, birthYear: birthYear)
    }
}
