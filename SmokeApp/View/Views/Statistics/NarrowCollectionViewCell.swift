//
//  NarrowCollectionViewCell.swift
//  SmokeApp
//
//  Created by Лев Куликов on 14.02.2023.
//

import UIKit

/// Cell to display in Narrow Info Section. It is able to show different information like min and max smokes count, avarage amount and other (maybe days when user registered smokes like how many days he or she smoked
class NarrowCollectionViewCell: UICollectionViewCell {
    typealias NumberValue = Numeric
    
    //MARK: Properties
    static let identifier = "NarrowCollectionViewCell"
    
    /// Numeric value that will be displayed on the cell
    private var value: (any NarrowCollectionViewCell.NumberValue)? {
        didSet {
            guard let value else {
                valueLabel.text = nil
                return
            }
            valueLabel.text = "\(value)"
        }
    }
    
    /// Displayed title of the cell
    private var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    /// Date to be displayed in the cell if needed
    private var date: Date? {
        didSet {
            dateLabel.text = date?.formatted(date: .abbreviated, time: .omitted)
        }
    }
    
    /// Label to display title of the cell (describes what it displays)
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 17)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    /// Label to display provided value
    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.font = .boldSystemFont(ofSize: 40)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    /// Label to display provided date
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 17)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    //MARK: Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = Constants.shared.statisticsCellCornerRadius
        backgroundColor = Constants.shared.cellBackgroundColor
        contentView.addSubviews(titleLabel, valueLabel, dateLabel)
    }
    
    required init?(coder: NSCoder) {
        print("NarrowCollectionViewCell init?(coder:) is unsupported")
        return nil
    }
    
    //MARK: Lyfe Cycle
    override func layoutSubviews() {
        super.layoutSubviews()
        setConstraints()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        value = nil
        title = nil
        date = nil
    }
    //MARK: Methods
    /// Sets layout constraints to all UI elements
    private func setConstraints() {
        // Set titleLabel constraint
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.heightAnchor.constraint(equalToConstant: 20),
            titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 5),
            titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -5)
        ])
        
        // Set valueLabel constraint
        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: 20),
            valueLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -25),
            valueLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            valueLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])
        
        // Set dateLabel constraint
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            dateLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            dateLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])
    }
    
    /// Configures cell data to be displayed on it
    /// - Parameters:
    ///   - value: Provide statistical value to be displayd on the center
    ///   - title: Provide title to name cell for user and describe cell's purpose
    ///   - date: Provide date that is related to provided statistical value, date will be shown in the botton of the cell
    public func configureCell(value: (some Numeric)?, title: String?, date: Date?) {
        self.value = value
        self.title = title
        self.date = date
    }
}
