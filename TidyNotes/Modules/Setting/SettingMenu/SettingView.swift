//
//  SettingView.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 15/05/25.
//

import SwiftUI
import PhotosUI

struct SettingsView: View {
    @StateObject var presenter: SettingsPresenter
    @State private var showFeatureInProgress = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ProfileInfoSection(presenter: presenter)
                PreferencesSection(presenter: presenter)
                AccountSection(presenter: presenter)
            }
            .padding()
        }
        .navigationTitle("Settings".localizedDescription)
        .withAppTheme()
        .confirmationDialog(
            isPresented: $presenter.showLogoutDialog,
            title: "Logout".localizedDescription,
            message: "Are you sure you want to logout?".localizedDescription,
            confirmText: "Logout",
            cancelText: "Cancel".localizedDescription,
            onConfirm: {
                presenter.logout()
            }
        )
        .sheet(isPresented: $showFeatureInProgress) {
            InProgressDialog {
                showFeatureInProgress = false
            }
        }
    }
}


// MARK: - Profile Info Section

private struct ProfileInfoSection: View {
    @ObservedObject var presenter: SettingsPresenter

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 64, height: 64)
                .clipShape(Circle())
                .foregroundColor(.blue)
            Text(presenter.model.profile.username)
                .font(.title3).fontWeight(.semibold)
                .foregroundColor(AppColors.current.textPrimary)
            Text(presenter.model.profile.email)
                .font(.footnote)
                .foregroundColor(AppColors.current.textSecondary)
            NavigationLink(destination: ProfileModule.makeProfileView()) {
                Text("Edit profile".localizedDescription)
                    .font(.callout)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
            .tint(AppColors.current.primary)
        }
    }
}


// MARK: - Preferences Section

private struct PreferencesSection: View {
    @ObservedObject var presenter: SettingsPresenter

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Preferences".localizedDescription)
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.current.textSecondary)
                .padding(.leading, 6)
            ThemedComponents.ThemedCard {
                VStack(spacing: 0) {
                    DropdownRow(
                        icon: "globe",
                        title: "Language".localizedDescription,
                        selected: presenter.selectedLanguageLocalized,
                        options: presenter.languageOptions,
                        showDropdown: $presenter.showLanguageDropdown,
                        onSelect: { presenter.selectLanguage($0) }
                    )
                    Divider().padding(.leading, 44)
                    DropdownRow(
                        icon: "paintbrush",
                        title: "Theme".localizedDescription,
                        selected: presenter.model.preferences.theme.rawValue,
                        options: presenter.themeOptions,
                        showDropdown: $presenter.showThemeDropdown,
                        onSelect: { presenter.selectTheme($0) }
                    )
                }
            }
        }
    }
}

// MARK: - Account Section

private struct AccountSection: View {
    @ObservedObject var presenter: SettingsPresenter

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Account".localizedDescription)
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.current.textSecondary)
                .padding(.top, 20)
                .padding(.leading, 6)
            ThemedComponents.ThemedCard {
                VStack(spacing: 0) {
                    SettingRow(
                        icon: "lock",
                        title: "Change Password".localizedDescription,
                        onTap: { presenter.isResetPasswordActive = true }
                    )
                    .navigationDestination(isPresented: $presenter.isResetPasswordActive) {
                        ResetPasswordModule.makeResetPasswordView(email: presenter.model.profile.email)
                    }
                    Divider().padding(.leading, 44)
                    HStack {
                        SettingRow(
                            icon: "faceid",
                            title: "Login with Face ID".localizedDescription
                        )
                        Toggle("", isOn: $presenter.model.account.faceIDEnabled)
                            .labelsHidden()
                            .onChange(of: presenter.model.account.faceIDEnabled) { newValue in
                                presenter.onFaceIDToggled(newValue)
                            }
                    }
                    Divider().padding(.leading, 44)
                    Button(role: .destructive) {
                        presenter.onLogoutTapped()
                    } label: {
                        HStack(spacing: 16) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(AppColors.current.error)
                                .frame(width: 24)
                            Text("Logout".localizedDescription)
                                .foregroundColor(AppColors.current.error)
                            Spacer()
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 4)
                    }
                }
            }
        }
    }
}

//MARK: SettingRow

private struct SettingRow: View {
    let icon: String
    let title: String
    var detail: String? = nil
    var showDivider: Bool = false
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button(action: { onTap?() }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .frame(width: 24)
                    .foregroundColor(AppColors.current.primary)
                Text(title)
                    .foregroundColor(AppColors.current.textPrimary)
                Spacer()
                if let detail = detail {
                    Text(detail)
                        .foregroundColor(AppColors.current.textSecondary)
                }
                if onTap != nil {
                    Image(systemName: "chevron.right")
                        .foregroundColor(AppColors.current.divider)
                        .font(.system(size: 14))
                }
            }
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .overlay(
            showDivider ?
                Divider().offset(x: 44, y: 22)
                : nil,
            alignment: .bottom
        )
    }
}

