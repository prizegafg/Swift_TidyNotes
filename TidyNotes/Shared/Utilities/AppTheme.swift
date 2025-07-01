//
//  AppTheme.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 05/05/25.
//

import SwiftUI
import Combine

public enum ThemeMode: String, CaseIterable {
    case light = "Light"
    case dark = "Dark"
    case system = "System"
}

public class ThemeManager: ObservableObject {
    public static let shared = ThemeManager()
    @Published public private(set) var selectedThemeMode: ThemeMode
    private let themeUserDefaultsKey = "app_theme_mode"
    
    private init() {
        if let savedThemeValue = UserDefaults.standard.string(forKey: themeUserDefaultsKey),
           let savedTheme = ThemeMode(rawValue: savedThemeValue) {
            self.selectedThemeMode = savedTheme
        } else {
            self.selectedThemeMode = .system
        }
    }
    
    public func setTheme(_ theme: ThemeMode) {
        selectedThemeMode = theme
        UserDefaults.standard.set(theme.rawValue, forKey: themeUserDefaultsKey)
    }
    
    public var colorScheme: ColorScheme? {
        switch selectedThemeMode {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil
        }
    }
    
    public var isDarkMode: Bool {
        if selectedThemeMode == .dark {
            return true
        } else if selectedThemeMode == .system {
            let userInterfaceStyle = UITraitCollection.current.userInterfaceStyle
            return userInterfaceStyle == .dark
        }
        return false
    }
}
