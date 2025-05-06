//
//  AppColor.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 05/05/25.
//

// AppColors.swift
import SwiftUI

/// Struct untuk menyimpan semua warna aplikasi
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
        primary: Color(hex: "1A73E8"),         // Biru
        primaryVariant: Color(hex: "0D47A1"),  // Biru gelap
        secondary: Color(hex: "6C757D"),       // Abu-abu
        secondaryVariant: Color(hex: "495057"),// Abu-abu gelap
        accent: Color(hex: "009688"),          // Teal
        
        background: Color(hex: "FFFFFF"),      // Putih
        surface: Color(hex: "F8F9FA"),         // Abu-abu sangat terang
        surfaceVariant: Color(hex: "F1F3F4"),  // Abu-abu terang
        
        textPrimary: Color(hex: "202124"),     // Hitam
        textSecondary: Color(hex: "5F6368"),   // Abu-abu
        textTertiary: Color(hex: "9AA0A6"),    // Abu-abu terang
        textOnPrimary: Color(hex: "FFFFFF"),   // Putih
        textOnSecondary: Color(hex: "FFFFFF"), // Putih
        
        success: Color(hex: "34A853"),         // Hijau
        warning: Color(hex: "FBBC05"),         // Kuning
        error: Color(hex: "EA4335"),           // Merah
        info: Color(hex: "4285F4"),            // Biru muda
        
        border: Color(hex: "DADCE0"),          // Abu-abu terang
        divider: Color(hex: "E8EAED"),         // Abu-abu sangat terang
        
        shadow: Color(hex: "000000").opacity(0.1) // Bayangan hitam transparan
    )
    
    // MARK: - Dark Theme Colors
    public static let dark = AppColors(
        primary: Color(hex: "8AB4F8"),         // Biru muda
        primaryVariant: Color(hex: "669DF6"),  // Biru
        secondary: Color(hex: "A8AAAD"),       // Abu-abu terang
        secondaryVariant: Color(hex: "868B90"),// Abu-abu
        accent: Color(hex: "80CBC4"),          // Teal muda
        
        background: Color(hex: "202124"),      // Hitam
        surface: Color(hex: "292A2D"),         // Hitam keabu-abuan
        surfaceVariant: Color(hex: "35363A"),  // Abu-abu gelap
        
        textPrimary: Color(hex: "E8EAED"),     // Putih
        textSecondary: Color(hex: "9AA0A6"),   // Abu-abu terang
        textTertiary: Color(hex: "747775"),    // Abu-abu
        textOnPrimary: Color(hex: "202124"),   // Hitam
        textOnSecondary: Color(hex: "202124"), // Hitam
        
        success: Color(hex: "81C995"),         // Hijau muda
        warning: Color(hex: "FDD663"),         // Kuning muda
        error: Color(hex: "F28B82"),           // Merah muda
        info: Color(hex: "8AB4F8"),            // Biru muda
        
        border: Color(hex: "5F6368"),          // Abu-abu
        divider: Color(hex: "3C4043"),         // Abu-abu gelap
        
        shadow: Color(hex: "000000").opacity(0.3) // Bayangan hitam lebih gelap
    )
    
    /// Mendapatkan warna berdasarkan mode tema
    public static func colors(for isDarkMode: Bool) -> AppColors {
        return isDarkMode ? .dark : .light
    }
    
    /// Mendapatkan warna berdasarkan ThemeManager
    public static var current: AppColors {
        return colors(for: ThemeManager.shared.isDarkMode)
    }
}

// MARK: - Color Extension untuk Hex
extension Color {
    /// Inisialisasi Color dari nilai hex string
    /// - Parameter hex: String hex, misalnya "FF0000" untuk merah
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
