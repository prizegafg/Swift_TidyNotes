//
//  ThemedComponent.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 05/05/25.
//

import SwiftUI

public struct ThemedComponents {
    public struct PrimaryButtonStyle: ButtonStyle {
        public func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding(.horizontal, AppMetrics.shared.spacingM)
                .frame(height: AppMetrics.shared.buttonHeight)
                .background(
                    configuration.isPressed ?
                    AppColors.current.primaryVariant :
                    AppColors.current.primary
                )
                .foregroundColor(AppColors.current.textOnPrimary)
                .font(AppTypography.shared.headline)
                .cornerRadius(AppMetrics.shared.cornerRadiusM)
                .shadow(
                    color: AppColors.current.shadow,
                    radius: AppMetrics.shared.shadowRadiusS,
                    x: 0,
                    y: configuration.isPressed ? 1 : AppMetrics.shared.shadowOffsetY
                )
                .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
        }
        
        public init() {}
    }
    
    public struct SecondaryButtonStyle: ButtonStyle {
        public func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding(.horizontal, AppMetrics.shared.spacingM)
                .frame(height: AppMetrics.shared.buttonHeight)
                .background(AppColors.current.surface)
                .foregroundColor(AppColors.current.primary)
                .font(AppTypography.shared.headline)
                .cornerRadius(AppMetrics.shared.cornerRadiusM)
                .overlay(
                    RoundedRectangle(cornerRadius: AppMetrics.shared.cornerRadiusM)
                        .stroke(AppColors.current.primary, lineWidth: AppMetrics.shared.borderWidthRegular)
                )
                .opacity(configuration.isPressed ? 0.8 : 1.0)
                .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
        }
        
        public init() {}
    }
    
    public struct PrimaryText: View {
        private let text: String
        private let style: TextStyle
        
        public var body: some View {
            Text(text)
                .foregroundColor(AppColors.current.textPrimary)
        }
        
        public init(_ text: String, style: TextStyle = .body) {
            self.text = text
            self.style = style
        }
    }
    
    public struct SecondaryText: View {
        private let text: String
        private let style: TextStyle
        
        public var body: some View {
            Text(text)
                .foregroundColor(AppColors.current.textSecondary)
        }
        
        public init(_ text: String, style: TextStyle = .body) {
            self.text = text
            self.style = style
        }
    }
    
    public struct ThemedCard<Content: View>: View {
        private let content: Content
        private let elevation: CardElevation
        
        public var body: some View {
            content
                .padding(AppMetrics.shared.spacingM)
                .background(AppColors.current.surface)
                .cornerRadius(AppMetrics.shared.cornerRadiusM)
                .shadow(
                    color: AppColors.current.shadow,
                    radius: shadowRadius,
                    x: 0,
                    y: shadowOffsetY
                )
        }
        
        private var shadowRadius: CGFloat {
            switch elevation {
            case .low:
                return AppMetrics.shared.shadowRadiusS
            case .medium:
                return AppMetrics.shared.shadowRadiusM
            case .high:
                return AppMetrics.shared.shadowRadiusL
            }
        }
        
        private var shadowOffsetY: CGFloat {
            switch elevation {
            case .low:
                return 1
            case .medium:
                return 2
            case .high:
                return 4
            }
        }
        
        public init(@ViewBuilder content: () -> Content, elevation: CardElevation = .medium) {
            self.content = content()
            self.elevation = elevation
        }
    }
    
    public struct ThemedTextField: View {
        private let placeholder: String
        @Binding private var text: String
        private let keyboardType: UIKeyboardType
        private let isSecure: Bool
        private let icon: String?
        
        public var body: some View {
            HStack(spacing: AppMetrics.shared.spacingS) {
                if let iconName = icon {
                    Image(systemName: iconName)
                        .foregroundColor(AppColors.current.primary)
                        .frame(width: AppMetrics.shared.iconSizeM)
                }
                
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .keyboardType(keyboardType)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboardType)
                }
            }
            .padding(.horizontal, AppMetrics.shared.spacingM)
            .frame(height: AppMetrics.shared.inputHeight)
            .background(AppColors.current.surface)
            .cornerRadius(AppMetrics.shared.cornerRadiusM)
            .overlay(
                RoundedRectangle(cornerRadius: AppMetrics.shared.cornerRadiusM)
                    .stroke(AppColors.current.border, lineWidth: AppMetrics.shared.borderWidthRegular)
            )
        }
        
        public init(
            _ placeholder: String,
            text: Binding<String>,
            keyboardType: UIKeyboardType = .default,
            isSecure: Bool = false,
            icon: String? = nil
        ) {
            self.placeholder = placeholder
            self._text = text
            self.keyboardType = keyboardType
            self.isSecure = isSecure
            self.icon = icon
        }
    }
}

public enum TextStyle {
    case largeTitle, title1, title2, title3, headline, body, callout, subheadline, footnote, caption
}

public enum CardElevation {
    case low, medium, high
}


