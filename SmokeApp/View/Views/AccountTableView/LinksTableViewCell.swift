//
//  LinksTableViewCell.swift
//  SmokeApp
//
//  Created by Лев Куликов on 04.04.2023.
//

import UIKit

class LinksTableViewCell: UITableViewCell {
    //MARK: Properties
    var linkToGet: ContactsAndLinks? {
        return link
    }
    
    private var link: ContactsAndLinks?
    
    //MARK: Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = Constants.shared.cellBackgroundColor
        accessoryType = .disclosureIndicator
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        print("AccountDetailsTableViewCell init?(coder:) is not supported")
        return nil
    }
    
    //MARK: Lyfe Cycle methods
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        //TODO: Prepate
    }
    
    //MARK: Methods
    func configure(type: ContactsAndLinks) {
        link = type
        var configuration = defaultContentConfiguration()
        
        switch type {
        case .appManual:
            configuration.image = ContactsAndLinks.appManualImage
            configuration.imageProperties.tintColor = .systemYellow
            configuration.text = "App manual (russian)"
        case .telegramChanel:
            configuration.image = ContactsAndLinks.telegramChanelImage
            configuration.imageProperties.tintColor = UIColor(hex: "0088cc")
            configuration.text = "Our telegaram chanel"
        }
        
        contentConfiguration = configuration
    }
}
