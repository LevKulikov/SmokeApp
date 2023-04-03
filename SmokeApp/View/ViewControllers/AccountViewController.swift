//
//  AccountViewController.swift
//  SmokeApp
//
//  Created by Лев Куликов on 30.03.2023.
//

import UIKit

protocol AccountViewControllerProtocol {
    
}

final class AccountViewController: UIViewController, AccountViewControllerProtocol {
    //MARK: Properties
    /// ViewModel for Account ViewController
    private let viewModel: AccountViewModelProtocol
    /// ImageView that displays logo of user
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.image = UIImage(systemName: "person.crop.circle")
        imageView.tintColor = .systemGray
        imageView.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTappedToSetImage))
        imageView.addGestureRecognizer(tapGesture)
        return imageView
    }()
    
    //MARK: Initializer
    init(viewModel: AccountViewModelProtocol) {
        self.viewModel = viewModel
        super.init()
    }
    
    required init?(coder: NSCoder) {
        print("AccountViewController init?(coder:) is not supported")
        return nil
    }
    
    //MARK: Lyfe Cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //MARK: Methods
    /// Calls alert to manipulate with user's image
    @objc
    private func imageViewTappedToSetImage() {
        //TODO: Continue this method
    }
}
