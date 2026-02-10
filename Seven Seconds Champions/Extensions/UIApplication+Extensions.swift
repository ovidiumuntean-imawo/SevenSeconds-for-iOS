//
//  UIApplication+Extensions.swift
//  Seven Seconds Champions
//
//  Created by Ovidiu Muntean on 16.01.2025.
//

import UIKit
import SwiftUI

// MARK: EXTENSIONS (Culori Neon)
extension Color {
    static let neonCyan = Color(red: 0, green: 1, blue: 1)
    static let neonBlue = Color(red: 0, green: 0.5, blue: 1)
    static let neonPurple = Color(red: 0.5, green: 0, blue: 1)
    static let neonRed = Color(red: 1, green: 0.1, blue: 0.1)
    static let neonOrange = Color(red: 1, green: 0.5, blue: 0)
    static let deepSpace = Color(red: 0.05, green: 0.05, blue: 0.1)
}

extension UIApplication {
    static func getRootViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return nil
        }
        return window.rootViewController
    }
}

