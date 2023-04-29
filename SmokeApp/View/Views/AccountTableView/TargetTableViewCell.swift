//
//  TargetTableViewCell.swift
//  SmokeApp
//
//  Created by Лев Куликов on 19.04.2023.
//

import UIKit

/// TableViewCell to display target information
class TargetTableViewCell: UITableViewCell {
    //MARK: Properties
    /// TargetOwner to provide target information
    private var targetOwner: TargetOwnerProtocol?
    
    /// DataStorage to provide infro about smokeItems data
    private var dataStorage: DataStorageProtocol?
    
    /// View that is shown when target is not set
    private let noTargetView = NoTargetCellView()
    
    /// View that is shown when target is set
    private let targetExistsView = TargetExistsCellView()

    //MARK: Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = Constants.shared.cellBackgroundColor
        contentView.addSubviews(noTargetView, targetExistsView)
    }
    
    required init?(coder: NSCoder) {
        print("TargetTableViewCell init?(coder:) is not supported")
        return nil
    }
    
    //MARK: Lyfe Cycle methods
    override func layoutSubviews() {
        super.layoutSubviews()
        setNoTargetViewConstraints()
        seTargetExistsViewConstraints()
    }
    
    //MARK: Methods
    /// Set constraints to noTargetView
    private func setNoTargetViewConstraints() {
        NSLayoutConstraint.activate([
            noTargetView.topAnchor.constraint(equalTo: contentView.topAnchor),
            noTargetView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            noTargetView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            noTargetView.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])
    }
    
    /// Set constraints to noTargetView
    private func seTargetExistsViewConstraints() {
        NSLayoutConstraint.activate([
            targetExistsView.topAnchor.constraint(equalTo: contentView.topAnchor),
            targetExistsView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            targetExistsView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            targetExistsView.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])
    }
    
    /// Configures cell with relevant information about target
    /// - Parameter targetOwner: Object that stores and provide target infromation
    func configure(targetOwner: TargetOwnerProtocol?, dataStorage: DataStorageProtocol?) {
        self.targetOwner = targetOwner
        self.dataStorage = dataStorage
        bindTargetInfomation()
        bindSmokeDataInformation()
        defineCellAppearance()
    }
    
    /// Set binding to get relevant target updates
    private func bindTargetInfomation() {
        let bindClosure: (Target?) -> Void = { [weak self] _ in
            self?.defineCellAppearance()
        }
        targetOwner?.targetUpdateAccountCell = bindClosure
    }
    
    /// Set binding to get relevant smoke data
    private func bindSmokeDataInformation() {
        let bindClosure: ([SmokeItem]?) -> Void = { [weak self] smokeItems in
            guard let _ = smokeItems else {
                print("No smoke data")
                return
            }
            self?.defineCellAppearance()
        }
        dataStorage?.updateTableCell = bindClosure
    }
    
    /// Determines what views should be shown depending on if target set
    private func defineCellAppearance() {
        //TODO: Conmplete this method
        guard let targetOwner, let dataStorage, let _ = targetOwner.userTarget else {
            noTargetView.isHidden = false
            targetExistsView.isHidden = true
            return
        }
        noTargetView.isHidden = true
        targetExistsView.isHidden = false
        targetExistsView.configureView(targetOwner: targetOwner, dataStorage: dataStorage)
    }
}

//MARK: Custom View No Target
///View for contenView of the cell to display that target is not set
final class NoTargetCellView: UIView {
    //MARK: Properties
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Target is not set"
        label.font = .boldSystemFont(ofSize: 22)
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Tap here to set your smoking target"
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var supportingImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "target")
        imageView.tintColor = .systemRed
        return imageView
    }()
    
    //MARK: Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        addSubviews(titleLabel, descriptionLabel, supportingImageView)
    }
    
    required init?(coder: NSCoder) {
        print("NoTargetCellView init?(coder:) in not supported")
        return nil
    }
    
    //MARK: Lyfe Cycle
    override func layoutSubviews() {
        super.layoutSubviews()
        setTitleLabelConstraints()
        setDescriptionLabelConstraints()
        setSupportingImageViewConstraints()
    }
    
    //MARK: Methods
    private func setTitleLabelConstraints() {
        let padding: CGFloat = 10
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: padding),
            titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: padding * 2),
            titleLabel.heightAnchor.constraint(equalToConstant: 25),
            titleLabel.widthAnchor.constraint(equalToConstant: self.bounds.width * 2/3)
        ])
    }
    
    private func setDescriptionLabelConstraints() {
        let padding: CGFloat = 10
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: padding),
            descriptionLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -padding),
            descriptionLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor),
            descriptionLabel.rightAnchor.constraint(equalTo: titleLabel.rightAnchor)
        ])
    }
    
    private func setSupportingImageViewConstraints() {
        let padding: CGFloat = 10
        NSLayoutConstraint.activate([
            supportingImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: padding),
            supportingImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -padding),
            supportingImageView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -padding),
            supportingImageView.widthAnchor.constraint(equalToConstant: self.bounds.height - 2 * padding)
        ])
    }
}

//MARK: Custom View Target exists
///View for contenView of the cell to display that target does exist
final class TargetExistsCellView: UIView {
    //MARK: Propeties
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "You fulfil your target for"
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 22)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private lazy var fulfilmentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        label.font = .boldSystemFont(ofSize: 55)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    //MARK: Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        addSubviews(descriptionLabel, fulfilmentLabel)
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    //MARK: Lyfe Cycle
    override func layoutSubviews() {
        super.layoutSubviews()
        setDescriptionLabelConstraints()
        setFulfilmentLabelConstraints()
    }
    
    //MARK: Methods
    private func setDescriptionLabelConstraints() {
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: self.topAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            descriptionLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20),
            descriptionLabel.widthAnchor.constraint(equalToConstant: self.bounds.width * 2/5)
        ])
    }
    
    private func setFulfilmentLabelConstraints() {
        let padding: CGFloat = 10
        NSLayoutConstraint.activate([
            fulfilmentLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: padding),
            fulfilmentLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -padding),
            fulfilmentLabel.leftAnchor.constraint(equalTo: descriptionLabel.rightAnchor, constant: padding * 2),
            fulfilmentLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -padding * 2),
        ])
    }
    
    func configureView(targetOwner: TargetOwnerProtocol, dataStorage: DataStorageProtocol) {
        DispatchQueue.main.async { [weak self] in
            guard let self else {
                return
            }
            let targetViewModel = TargetViewModel(targetOwner: targetOwner, dataStorage: dataStorage)
            guard let targetFulfimentValue = targetViewModel.currentTargetPerformance() else {
                fulfilmentLabel.text = "NuN"
                fulfilmentLabel.textColor = .label
                return
            }
            
            var resultedValue = targetFulfimentValue * 100
            switch resultedValue {
            case 0..<60:
                fulfilmentLabel.textColor = .systemRed
            case 60..<85:
                fulfilmentLabel.textColor = .systemOrange
            case 85...:
                fulfilmentLabel.textColor = .systemGreen
                if resultedValue > 9999 {
                    resultedValue = 999
                }
            default:
                fulfilmentLabel.textColor = .label
            }
            
            let string = String(Int(resultedValue)) + "%"
            fulfilmentLabel.text = string
        }
    }
}
