//
//  DropdownRow.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 15/07/25.
//

import SwiftUI
 
struct DropdownRow: View {
    let icon: String
    let title: String
    let selected: String
    let options: [String]
    @Binding var showDropdown: Bool
    let onSelect: (String) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                withAnimation { showDropdown.toggle() }
            }) {
                HStack(spacing: 16) {
                    Image(systemName: icon)
                        .frame(width: 24)
                        .foregroundColor(AppColors.current.primary)
                    Text(title)
                        .foregroundColor(AppColors.current.textPrimary)
                    Spacer()
                    Text(selected)
                        .foregroundColor(AppColors.current.textSecondary)
                    Image(systemName: showDropdown ? "chevron.up" : "chevron.down")
                        .foregroundColor(AppColors.current.divider)
                        .font(.system(size: 14))
                }
                .padding(.vertical, 12)
            }
            .buttonStyle(.plain)
            if showDropdown {
                VStack(spacing: 0) {
                    ForEach(options, id: \.self) { option in
                        Button(action: {
                            onSelect(option)
                        }) {
                            HStack {
                                Text(option)
                                    .foregroundColor(AppColors.current.textPrimary)
                                Spacer()
                                if selected == option {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(AppColors.current.primary)
                                }
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                        }
                        .background(AppColors.current.surface.opacity(0.9))
                    }
                }
                .background(AppColors.current.surface)
                .cornerRadius(8)
                .shadow(radius: 2)
                .padding(.leading, 44)
                .transition(.opacity)
            }
        }
    }
}
