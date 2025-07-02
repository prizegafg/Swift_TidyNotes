//
//  AppTypography.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 05/05/25.
//

import SwiftUI

public struct AppTypography {
    // MARK: - Font Weights
    public let regular: Font.Weight = .regular
    public let medium: Font.Weight = .medium
    public let semibold: Font.Weight = .semibold
    public let bold: Font.Weight = .bold
    
    // MARK: - Font Sizes
    public let captionSize: CGFloat = 12
    public let footnoteSize: CGFloat = 13
    public let subheadlineSize: CGFloat = 15
    public let bodySize: CGFloat = 17
    public let titleSize: CGFloat = 20
    public let title2Size: CGFloat = 22
    public let title3Size: CGFloat = 28
    public let largeTitle: CGFloat = 34
    
    // MARK: - Line Heights
    public let captionLineHeight: CGFloat = 16
    public let footnoteLineHeight: CGFloat = 18
    public let subheadlineLineHeight: CGFloat = 20
    public let bodyLineHeight: CGFloat = 22
    public let titleLineHeight: CGFloat = 24
    public let title2LineHeight: CGFloat = 28
    public let title3LineHeight: CGFloat = 34
    public let largeTitleLineHeight: CGFloat = 41
    
    // MARK: - Typography Styles
    public var largeTitle1: Font {
        .system(size: largeTitle, weight: bold)
    }
    
    public var title1: Font {
        .system(size: title3Size, weight: bold)
    }
    
    public var title2: Font {
        .system(size: title2Size, weight: bold)
    }
    
    public var title3: Font {
        .system(size: titleSize, weight: semibold)
    }
    
    public var headline: Font {
        .system(size: bodySize, weight: semibold)
    }
    
    public var body: Font {
        .system(size: bodySize, weight: regular)
    }
    
    public var callout: Font {
        .system(size: subheadlineSize, weight: medium)
    }
    
    public var subheadline: Font {
        .system(size: subheadlineSize, weight: regular)
    }
    
    public var footnote: Font {
        .system(size: footnoteSize, weight: regular)
    }
    
    public var caption: Font {
        .system(size: captionSize, weight: regular)
    }
    
    public static let shared = AppTypography()
}

// MARK: - Text Modifier Extensions
extension View {
    public func largeTitle1Style() -> some View {
        self.font(AppTypography.shared.largeTitle1)
            .lineSpacing(AppTypography.shared.largeTitleLineHeight - AppTypography.shared.largeTitle)
    }
    
    public func title1Style() -> some View {
        self.font(AppTypography.shared.title1)
            .lineSpacing(AppTypography.shared.title3LineHeight - AppTypography.shared.title3Size)
    }
    
    public func title2Style() -> some View {
        self.font(AppTypography.shared.title2)
            .lineSpacing(AppTypography.shared.title2LineHeight - AppTypography.shared.title2Size)
    }
    
    public func title3Style() -> some View {
        self.font(AppTypography.shared.title3)
            .lineSpacing(AppTypography.shared.titleLineHeight - AppTypography.shared.titleSize)
    }
    
    public func headlineStyle() -> some View {
        self.font(AppTypography.shared.headline)
            .lineSpacing(AppTypography.shared.bodyLineHeight - AppTypography.shared.bodySize)
    }
    
    public func bodyStyle() -> some View {
        self.font(AppTypography.shared.body)
            .lineSpacing(AppTypography.shared.bodyLineHeight - AppTypography.shared.bodySize)
    }
    
    public func calloutStyle() -> some View {
        self.font(AppTypography.shared.callout)
            .lineSpacing(AppTypography.shared.subheadlineLineHeight - AppTypography.shared.subheadlineSize)
    }
    
    public func subheadlineStyle() -> some View {
        self.font(AppTypography.shared.subheadline)
            .lineSpacing(AppTypography.shared.subheadlineLineHeight - AppTypography.shared.subheadlineSize)
    }
    
    public func footnoteStyle() -> some View {
        self.font(AppTypography.shared.footnote)
            .lineSpacing(AppTypography.shared.footnoteLineHeight - AppTypography.shared.footnoteSize)
    }
    
    public func captionStyle() -> some View {
        self.font(AppTypography.shared.caption)
            .lineSpacing(AppTypography.shared.captionLineHeight - AppTypography.shared.captionSize)
    }
}
