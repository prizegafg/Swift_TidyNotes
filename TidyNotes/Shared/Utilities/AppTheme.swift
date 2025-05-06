//
//  AppTheme.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 05/05/25.
//

import SwiftUI
import Combine

/// Tipe tema yang tersedia dalam aplikasi
public enum ThemeMode: String, CaseIterable {
    case light = "Light"
    case dark = "Dark"
    case system = "System"
}

/// Kelas untuk mengelola tema aplikasi
public class ThemeManager: ObservableObject {
    // Singleton instance
    public static let shared = ThemeManager()
    
    // Current theme mode yang dipilih
    @Published public private(set) var selectedThemeMode: ThemeMode
    
    // Key untuk menyimpan tema di UserDefaults
    private let themeUserDefaultsKey = "app_theme_mode"
    
    private init() {
        // Load tema dari UserDefaults atau gunakan system sebagai default
        if let savedThemeValue = UserDefaults.standard.string(forKey: themeUserDefaultsKey),
           let savedTheme = ThemeMode(rawValue: savedThemeValue) {
            self.selectedThemeMode = savedTheme
        } else {
            self.selectedThemeMode = .system
        }
    }
    
    /// Mengubah tema aplikasi
    public func setTheme(_ theme: ThemeMode) {
        selectedThemeMode = theme
        UserDefaults.standard.set(theme.rawValue, forKey: themeUserDefaultsKey)
    }
    
    /// Mendapatkan ColorScheme berdasarkan tema yang dipilih
    public var colorScheme: ColorScheme? {
        switch selectedThemeMode {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil // Mengikuti sistem
        }
    }
    
    /// Mengecek apakah tema saat ini adalah dark mode
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
