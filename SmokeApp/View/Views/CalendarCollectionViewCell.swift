//
//  CalendarCollectionViewCell.swift
//  SmokeApp
//
//  Created by Лев Куликов on 30.01.2023.
//

import UIKit

/// Custom collection view cell to display calendar (collectionView) data
final class CalendarCollectionViewCell: UICollectionViewCell {
    //MARK: Properties
    /// Enumeration to define cell data
    public enum CellType {
        case dataCell
        case lastCell
    }
    
    /// Contains cell type to identify needed action if it is tapped
    private var cellType: CellType!
    
    /// Static property with cell identifier to use for cell registration and dequeue process
    static let identifier = "CalendarCollectionViewCellIdentifier"
    
    /// Instance to bind cell with view controller
    private weak var viewController: (CalendarViewControllerProtocol & UIViewController)?
    
    /// Instance that indicates it long press happend and prevents continious action performing
    private var longPressHappend = false
    
    /// SmokeItem data to set information to UI elements, when it is set
    private var smokeItem: SmokeItem? {
        didSet {
            countLabel.text = String(describing: smokeItem?.amount ?? 0)
            dateLabel.text = smokeItem?.date?.formatted(date: .abbreviated, time: .omitted)
        }
    }
    
    /// Get instance to securly get smokeItem from selected cell
    public var getSmokeItem: SmokeItem? {
        return smokeItem
    }
    
    /// ImageView with Plus image to indicate that cell has adding purpose
    private lazy var plusImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.isHidden = true
        imageView.image = UIImage(systemName: "plus.circle.fill")
        return imageView
    }()
    
    /// Label to display number of smokes
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 50)
        label.textAlignment = .center
        label.textColor = .label
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    /// Label to display date of smokes number registration
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 13)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        return label
    }()
    
    //MARK: Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Constants.shared.cellBackgroundColor
        clipsToBounds = true
        layer.cornerRadius = 15
        
//        let longPressGestureRecognizer = UILongPressGestureRecognizer( //TODO: If needed to show delete action - uncomment
//            target: self,
//            action: #selector(didLongPress)
//        )
//        addGestureRecognizer(longPressGestureRecognizer)
    }
    
    required init?(coder: NSCoder) {
        print("CalendarCollectionViewCell init?(coder:) is unsupported")
        return nil
    }
    //MARK: Lyfe Cycle methods
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.addSubview(plusImageView)
        contentView.addSubview(dateLabel)
        contentView.addSubview(countLabel)
        setPlusImageViewConstraints()
        setDateLabelConstraints()
        setCountLabelConstraints()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        smokeItem = nil
        viewController = nil
        countLabel.text = nil
        dateLabel.text = nil
    }
    
    //MARK: Methods
    /// Calls when long press happens (**if gesture recognizer is set**), and prevents contineous action performing using longPressHappend instance and Timer
    @objc
    private func didLongPress() {
        guard !longPressHappend else {
            return
        }
        longPressHappend = true
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            self?.longPressHappend = false
        }
        viewController?.showActionSheetWithCell(with: nil)
    }
    
    /// Sets layout constraits to plusImageView
    private func setPlusImageViewConstraints() {
        let paddingConstant: CGFloat = 20
        NSLayoutConstraint.activate([
            plusImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: paddingConstant),
            plusImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -paddingConstant),
            plusImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: paddingConstant),
            plusImageView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -paddingConstant)
        ])
    }

    /// Sets layout constraits to dateLabel
    private func setDateLabelConstraints() {
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            dateLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 1/6),
            dateLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            dateLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])
    }
    
    /// Sets layout constraits to countLabel
    private func setCountLabelConstraints() {
        NSLayoutConstraint.activate([
            countLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            countLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            countLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            countLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])
    }
    
    /// Configures cell with provided SmokeItem and ViewController
    /// - Parameters:
    ///   - item: data item to push in cell and to display information on it
    ///   - viewController: view controller that if presenting this cell and able to perform some CalendarViewControllerProtocol methods
    public func configure(item: SmokeItem?, viewController: (CalendarViewControllerProtocol & UIViewController)?, as cellType: CellType = .dataCell) {
        self.smokeItem = item
        self.viewController = viewController
        
        switch cellType {
        case .dataCell:
            self.cellType = .dataCell
            backgroundColor = Constants.shared.cellBackgroundColor
            dateLabel.textColor = .secondaryLabel
        case .lastCell:
            self.cellType = .lastCell
            backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
            dateLabel.textColor = .label
        }
    }
}

