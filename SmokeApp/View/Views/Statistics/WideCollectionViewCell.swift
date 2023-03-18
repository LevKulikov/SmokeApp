//
//  WideCollectionViewCell.swift
//  SmokeApp
//
//  Created by Лев Куликов on 14.02.2023.
//

import UIKit

/// Cell to display in Wide Info Section. Displays total amout of registered smokes and dinamics through previous 7 days (or last month)
final class WideCollectionViewCell: UICollectionViewCell {
    //MARK: Properties
    static let identifier = "WideCollectionViewCell"
    
    public var dynamicsDays: Int = 7 {
        didSet {
            dynamicsTitleLabel.text = "\(dynamicsDays) days dynamics"
        }
    }
    
    /// Total amount of registered smokes
    private var totalSmokes: Int = 0 {
        didSet {
            countLabel.text = String(totalSmokes)
        }
    }
    
    /// Dinamic in percentage
    private var smokesDynamic: Float = 0 {
        didSet {
            let percentage = Float(Int(smokesDynamic * 1000))/10
            if percentage > 0 {
                dynamicsLabel.text = "+\(percentage)%"
                dynamicsLabel.textColor = .systemRed
            } else {
                dynamicsLabel.text = "\(percentage)%"
                dynamicsLabel.textColor = .systemGreen
            }
        }
    }
    
    /// Title above total smokes label
    private lazy var totalTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 17)
        label.textAlignment = .center
        label.text = "All times smokes"
        return label
    }()
    
    /// Title above total dinamics label
    private lazy var dynamicsTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 17)
        label.textAlignment = .center
        label.text = "\(dynamicsDays) days dynamics"
        return label
    }()
    
    /// Label to display total count of smokes
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.font = .boldSystemFont(ofSize: 40)
        label.textAlignment = .center
        return label
    }()
    
    /// Label to display smokes dinamics
    private lazy var dynamicsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.font = .boldSystemFont(ofSize: 40)
        label.textAlignment = .center
        return label
    }()
    
    //MARK: Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = Constants.shared.statisticsCellCornerRadius
        backgroundColor = Constants.shared.cellBackgroundColor
        contentView.addSubviews(totalTitleLabel, dynamicsTitleLabel, countLabel, dynamicsLabel)
    }
    
    required init?(coder: NSCoder) {
        print("WideCollectionViewCell init?(coder:) is unsupported")
        return nil
    }
    
    //MARK: Lyfe Cycle
    override func layoutSubviews() {
        super.layoutSubviews()
        setLabelsConstraints()
    }
    
    //MARK: Methods
    /// Sets constraints to all labels
    private func setLabelsConstraints() {
        // Set constraints to totalTitleLabel
        NSLayoutConstraint.activate([
            totalTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            totalTitleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 5),
            totalTitleLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1/2),
            totalTitleLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 1/2)
        ])
        
        // Set constraints to countLabel
        NSLayoutConstraint.activate([
            countLabel.topAnchor.constraint(equalTo: totalTitleLabel.bottomAnchor),
            countLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            countLabel.rightAnchor.constraint(equalTo: totalTitleLabel.rightAnchor),
            countLabel.leftAnchor.constraint(equalTo: totalTitleLabel.leftAnchor)
        ])
        
        // Set constraints to dynamicsTitleLabel
        NSLayoutConstraint.activate([
            dynamicsTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            dynamicsTitleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -5),
            dynamicsTitleLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1/2),
            dynamicsTitleLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 1/2)
        ])
        
        // Set constraints to dynamicsLabel
        NSLayoutConstraint.activate([
            dynamicsLabel.topAnchor.constraint(equalTo: dynamicsTitleLabel.bottomAnchor),
            dynamicsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            dynamicsLabel.rightAnchor.constraint(equalTo: dynamicsTitleLabel.rightAnchor),
            dynamicsLabel.leftAnchor.constraint(equalTo: dynamicsTitleLabel.leftAnchor)
        ])
    }
    
    /// Configures cell information to display
    /// - Parameters:
    ///   - totalSmokes: total amount of smokes to show on the cell
    ///   - dinamics: dynamincs of smokes to show on the cell
    public func configureCell(totalSmokes: Int, dynamics: Float, dynamicsDays: Int = 7) {
        self.totalSmokes = totalSmokes
        self.smokesDynamic = dynamics
        self.dynamicsDays = dynamicsDays
    }
}
