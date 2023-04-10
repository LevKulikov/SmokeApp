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

extension String {
    /// Converts string to UIImage if its possible
    /// - Returns: Image from String, or nil if there is no data to be get from string
    func toImage() -> UIImage? {
        if let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters){
            return UIImage(data: data)
        }
        return nil
    }
}

extension UIImage {
    /// Converts UIImage to String representation of PNG data
    /// - Returns: String representation
    func toPngString() -> String? {
        let data = self.pngData()
        return data?.base64EncodedString(options: .endLineWithLineFeed)
    }
    
    /// Compress and converts UIImage to String representation of PNG data
    /// - Parameter cq: provide numerical representation (from 0.0 to 1.0) how image shound be compressed, input 1.0 if compression is not needed
    /// - Returns: The Base-64 encoded string
    func toJpegString(compressionQuality cq: CGFloat) -> String? {
        let data = self.jpegData(compressionQuality: cq)
        return data?.base64EncodedString(options: .endLineWithLineFeed)
    }
    
    /// Resizes image with provided paramener
    /// - Parameter targetSize: Size to scale image
    /// - Returns: new scaled image 
    func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
            // Determine the scale factor that preserves aspect ratio
            let widthRatio = targetSize.width / size.width
            let heightRatio = targetSize.height / size.height
            
            let scaleFactor = min(widthRatio, heightRatio)
            
            // Compute the new image size that preserves aspect ratio
            let scaledImageSize = CGSize(
                width: size.width * scaleFactor,
                height: size.height * scaleFactor
            )

            // Draw and return the resized UIImage
            let renderer = UIGraphicsImageRenderer(
                size: scaledImageSize
            )

            let scaledImage = renderer.image { _ in
                self.draw(in: CGRect(
                    origin: .zero,
                    size: scaledImageSize
                ))
            }
            
            return scaledImage
        }
}

/// Object that provides presentation lyfe cycle methods of UIViewController
@objc
protocol UIViewControllerPresentationDelegate: AnyObject {
    /// Calls when UIViewController will de dismissed
    /// - Parameter viewController: UIViewController that should be dismissed
    @objc
    optional func presentationWillEnd(for viewController: UIViewController)
}

extension UIViewController {
    private static weak var presentationDelegateStored: UIViewControllerPresentationDelegate? = nil
    /// Delegate object for presentation
    var presentationDelegate: UIViewControllerPresentationDelegate? {
        get {
            return UIViewController.presentationDelegateStored
        }
        set {
            UIViewController.presentationDelegateStored = newValue
        }
    }
}

/// UITextField that does not show action menu
final class NoActionTextField: UITextField {
    override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
        return []
    }
   
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
         return false
    }
    
    override func buildMenu(with builder: UIMenuBuilder) {
        builder.remove(menu: .lookup)
        super.buildMenu(with: builder)
    }
}

extension CGFloat {
    /// Converts value in radians
    /// - Returns: Radians value
    func toRadians() -> CGFloat {
        return self * CGFloat(Double.pi) / 180.0
    }
}

extension UIColor {
    /// Converts hex code to UIImage
    /// - Parameter hex: hex code, should start with #
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}
