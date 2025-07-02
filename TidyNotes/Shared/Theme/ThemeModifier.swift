//
//  ThemeModifier.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 05/05/25.
//

import SwiftUI
import Combine

public struct ThemeModifier: ViewModifier {
    @ObservedObject private var themeManager = ThemeManager.shared
    
    public func body(content: Content) -> some View {
        content
            .preferredColorScheme(themeManager.colorScheme)
            .environment(\.colorScheme, themeManager.isDarkMode ? .dark : .light)
    }
}

public struct ThemeSelector: View {
    @ObservedObject private var themeManager = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss
    
    public var body: some View {
        NavigationView {
            List {
                ForEach(ThemeMode.allCases, id: \.self) { theme in
                    Button(action: {
                        themeManager.setTheme(theme)
                    }) {
                        HStack {
                            Text(theme.rawValue)
                                .foregroundColor(AppColors.current.textPrimary)
                            
                            Spacer()
                            
                            if theme == themeManager.selectedThemeMode {
                                Image(systemName: "checkmark")
                                    .foregroundColor(AppColors.current.primary)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Choose Theme")
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
    }
    
    public init() {}
}

extension View {
    public func withAppTheme() -> some View {
        self.modifier(ThemeModifier())
    }
}

