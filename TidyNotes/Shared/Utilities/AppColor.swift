//
//  AppColor.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 05/05/25.
//

import SwiftUI

public struct AppColors {
    // MARK: - Primary Colors
    public let primary: Color
    public let primaryVariant: Color
    public let secondary: Color
    public let secondaryVariant: Color
    public let accent: Color
    
    // MARK: - Background Colors
    public let background: Color
    public let surface: Color
    public let surfaceVariant: Color
    
    // MARK: - Text Colors
    public let textPrimary: Color
    public let textSecondary: Color
    public let textTertiary: Color
    public let textOnPrimary: Color
    public let textOnSecondary: Color
    
    // MARK: - Status Colors
    public let success: Color
    public let warning: Color
    public let error: Color
    public let info: Color
    
    // MARK: - Border & Divider
    public let border: Color
    public let divider: Color
    
    // MARK: - Shadow
    public let shadow: Color
    
    // Private initializer
    private init(
        primary: Color,
        primaryVariant: Color,
        secondary: Color,
        secondaryVariant: Color,
        accent: Color,
        background: Color,
        surface: Color,
        surfaceVariant: Color,
        textPrimary: Color,
        textSecondary: Color,
        textTertiary: Color,
        textOnPrimary: Color,
        textOnSecondary: Color,
        success: Color,
        warning: Color,
        error: Color,
        info: Color,
        border: Color,
        divider: Color,
        shadow: Color
    ) {
        self.primary = primary
        self.primaryVariant = primaryVariant
        self.secondary = secondary
        self.secondaryVariant = secondaryVariant
        self.accent = accent
        self.background = background
        self.surface = surface
        self.surfaceVariant = surfaceVariant
        self.textPrimary = textPrimary
        self.textSecondary = textSecondary
        self.textTertiary = textTertiary
        self.textOnPrimary = textOnPrimary
        self.textOnSecondary = textOnSecondary
        self.success = success
        self.warning = warning
        self.error = error
        self.info = info
        self.border = border
        self.divider = divider
        self.shadow = shadow
    }
    
    // MARK: - Light Theme Colors
    public static let light = AppColors(
        primary: Color(hex: "1A73E8"),         // Blue
        primaryVariant: Color(hex: "0D47A1"),  // Dark Blue
        secondary: Color(hex: "6C757D"),       // Grey
        secondaryVariant: Color(hex: "495057"),// Dark Grey
        accent: Color(hex: "009688"),          // Teal
        
        background: Color(hex: "FFFFFF"),      // White
        surface: Color(hex: "F8F9FA"),         // Bright Grey
        surfaceVariant: Color(hex: "F1F3F4"),  // Light Grey
        
        textPrimary: Color(hex: "202124"),     // Black
        textSecondary: Color(hex: "5F6368"),   // Grey
        textTertiary: Color(hex: "9AA0A6"),    // Light Grey
        textOnPrimary: Color(hex: "FFFFFF"),   // White
        textOnSecondary: Color(hex: "FFFFFF"), // White
        
        success: Color(hex: "34A853"),         // Green
        warning: Color(hex: "FBBC05"),         // Yellow
        error: Color(hex: "EA4335"),           // Red
        info: Color(hex: "4285F4"),            // Light Blue
        
        border: Color(hex: "DADCE0"),          // Bright Grey
        divider: Color(hex: "E8EAED"),         // Light Bright Grey
        
        shadow: Color(hex: "000000").opacity(0.1) // Dark Shadow
    )
    
    // MARK: - Dark Theme Colors
    public static let dark = AppColors(
        primary: Color(hex: "8AB4F8"),         // Light Blue
        primaryVariant: Color(hex: "669DF6"),  // Blue
        secondary: Color(hex: "A8AAAD"),       // Light Grey
        secondaryVariant: Color(hex: "868B90"),// Grey
        accent: Color(hex: "80CBC4"),          // Light Teal
        
        background: Color(hex: "202124"),      // Black
        surface: Color(hex: "292A2D"),         // Greyish Black
        surfaceVariant: Color(hex: "35363A"),  // Dark Grey
        
        textPrimary: Color(hex: "E8EAED"),     // White
        textSecondary: Color(hex: "9AA0A6"),   // Light Grey
        textTertiary: Color(hex: "747775"),    // Grey
        textOnPrimary: Color(hex: "202124"),   // Black
        textOnSecondary: Color(hex: "202124"), // Black
        
        success: Color(hex: "81C995"),         // Light Green
        warning: Color(hex: "FDD663"),         // Light Yellow
        error: Color(hex: "F28B82"),           // Pink
        info: Color(hex: "8AB4F8"),            // Light Blue
        
        border: Color(hex: "5F6368"),          // Grey
        divider: Color(hex: "3C4043"),         // Dark Grey
        
        shadow: Color(hex: "000000").opacity(0.3) // Dark Shadow
    )
    
    public static func colors(for isDarkMode: Bool) -> AppColors {
        return isDarkMode ? .dark : .light
    }
    
    public static var current: AppColors {
        return colors(for: ThemeManager.shared.isDarkMode)
    }
}

// MARK: - Color Extension untuk Hex
extension Color {
    public init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
