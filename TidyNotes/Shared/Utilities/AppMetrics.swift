//
//  AppMetrics.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 05/05/25.
//

import SwiftUI

/// Struct untuk menyimpan semua ukuran, jarak, dan radius aplikasi
public struct AppMetrics {
    // MARK: - Spacing
    public let spacingXS: CGFloat
    public let spacingS: CGFloat
    public let spacingM: CGFloat
    public let spacingL: CGFloat
    public let spacingXL: CGFloat
    public let spacingXXL: CGFloat
    
    // MARK: - Corner Radius
    public let cornerRadiusS: CGFloat
    public let cornerRadiusM: CGFloat
    public let cornerRadiusL: CGFloat
    public let cornerRadiusXL: CGFloat
    
    // MARK: - Icon Sizes
    public let iconSizeS: CGFloat
    public let iconSizeM: CGFloat
    public let iconSizeL: CGFloat
    public let iconSizeXL: CGFloat
    
    // MARK: - Component Sizes
    public let buttonHeight: CGFloat
    public let inputHeight: CGFloat
    public let navBarHeight: CGFloat
    public let tabBarHeight: CGFloat
    
    // MARK: - Border Width
    public let borderWidthThin: CGFloat
    public let borderWidthRegular: CGFloat
    public let borderWidthThick: CGFloat
    
    // MARK: - Shadow
    public let shadowRadiusS: CGFloat
    public let shadowRadiusM: CGFloat
    public let shadowRadiusL: CGFloat
    public let shadowOffsetY: CGFloat
    
    /// Single shared instance
    public static let shared = AppMetrics(
        // Spacing
        spacingXS: 4,
        spacingS: 8,
        spacingM: 16,
        spacingL: 24,
        spacingXL: 32,
        spacingXXL: 48,
        
        // Corner Radius
        cornerRadiusS: 4,
        cornerRadiusM: 8,
        cornerRadiusL: 12,
        cornerRadiusXL: 16,
        
        // Icon Sizes
        iconSizeS: 16,
        iconSizeM: 24,
        iconSizeL: 32,
        iconSizeXL: 48,
        
        // Component Sizes
        buttonHeight: 48,
        inputHeight: 48,
        navBarHeight: 44,
        tabBarHeight: 49,
        
        // Border Width
        borderWidthThin: 0.5,
        borderWidthRegular: 1,
        borderWidthThick: 2,
        
        // Shadow
        shadowRadiusS: 2,
        shadowRadiusM: 4,
        shadowRadiusL: 8,
        shadowOffsetY: 2
    )
}
