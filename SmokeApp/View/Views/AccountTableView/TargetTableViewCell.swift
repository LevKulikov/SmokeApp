//
//  TargetTableViewCell.swift
//  SmokeApp
//
//  Created by Лев Куликов on 19.04.2023.
//

import UIKit

class TargetTableViewCell: UITableViewCell {
    //MARK: Properties

    //MARK: Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = Constants.shared.cellBackgroundColor
    }
    
    required init?(coder: NSCoder) {
        print("TargetTableViewCell init?(coder:) is not supported")
        return nil
    }
    
    //MARK: Lyfe Cycle methods
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    //MARK: Methods
    
}
