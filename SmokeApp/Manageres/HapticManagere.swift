//
//  HapticManagere.swift
//  SmokeApp
//
//  Created by Лев Куликов on 01.03.2023.
//

import Foundation
import UIKit

/// Class that manages haptic feedbacks calls, like different types of vibrations
final class HapticManagere {
    //MARK: Singleton instances
    static public let shared = HapticManagere()
    private init() {}
    
    //MARK: Methods
    /// Perferms notification vibration for selected type
    /// - Parameter type: type of needed vibration
    public func notificationVibrate(type: UINotificationFeedbackGenerator.FeedbackType) {
        let notificationGenerator = UINotificationFeedbackGenerator()
        notificationGenerator.prepare()
        notificationGenerator.notificationOccurred(type)
    }
    
    /// Perferms selection vibration
    public func selectionVibration() {
        let selectionGenerator = UISelectionFeedbackGenerator()
        selectionGenerator.prepare()
        selectionGenerator.selectionChanged()
    }
    
    /// Perferms impact vibration for selected style
    /// - Parameter style: style of needed vibration
    public func impactVibration(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let imapactGenerator = UIImpactFeedbackGenerator(style: style)
        imapactGenerator.prepare()
        imapactGenerator.impactOccurred()
    }
}
