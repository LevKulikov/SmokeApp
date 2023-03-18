//
//  Useful.swift
//  SmokeApp
//
//  Created by Лев Куликов on 14.02.2023.
//

import Foundation
import UIKit
import RxSwift

extension UIView {
    /// Adds a number of subviews, this method is convenient when you want to add some subviews at one time
    /// - Parameter views: Views to add as subviews
    public func addSubviews(_ views: UIView...) {
        for view in views {
            addSubview(view)
        }
    }
}

extension UICollectionViewCell {
    /// Convenient property to set identifier for basic UICollectionViewCell
    static let basicIdentifier = "UICollectionViewCell basicIdentifier"
}

extension UITextField {
    
    /// Retruns Int value from TextField if it is possible, either it returns nil. Text in the TextField should contain only number te get Int, this property does not identify numbers among text
    public var getIntFromText: Int? {
        guard let string = self.text else { return nil }
        return Int(string)
    }
    
    /// Rx method that subscribe TextField to accept only Int16 values
    /// - Parameter successCompletion: code block that is perfermed after success completion
    /// - Returns: Disposable for DisposeBag
    public func rxAcceptingOnlyInt16Field(successCompletion: ((Int16) -> Void)? = nil) -> Disposable {
        return self.rx.text
            .subscribe { [weak self] event in
                switch event {
                case .next(let newValue):
                    guard let newValue else {
                        self?.text = "0"
                        return
                    }
                    // Prevents text insertion
                    let filtered = newValue.filter { "0123456789".contains($0) }
                    if newValue != filtered, let int = Int(newValue), int < 0 {
                        self?.text = "0"
                    }
                    // Prevents insertion multiple 0
                    guard let int = Int(newValue) else { return }
                    if int == 0 {
                        self?.text = "0"
                        return
                    }
                    // Prevents insertion negative values
                    if int < 0 {
                        self?.text = "0"
                        return
                    }
                    // Prevents expiring of max value for Int16
                    guard int <= 32767 else {
                        self?.text = "32767"
                        return
                    }
                    // Prevents insertion value with 0 in the start
                    self?.text = String(int)
                    // Perferms success completion
                    successCompletion?(Int16(int))
                    
                case .completed:
                    break
                case .error(let error):
                    //TODO: Handle error
                    print(error)
                }
            }
    }
}
