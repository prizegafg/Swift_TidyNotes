//
//  SettingView.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 15/05/25.
//

import SwiftUI
import PhotosUI

import SwiftUI

struct SettingsView: View {
    @ObservedObject var presenter: SettingsPresenter
    @State private var showThemeSelector = false
    
    var body: some View {
        List {
            // --- Section Akun, ganti sesuai kebutuhan ---
            Section(header: Text("Account")) {
                // Contoh isi menu akun
                HStack {
                    Image(systemName: "person.crop.circle.fill")
                        .foregroundColor(.gray)
                    Text(presenter.name.isEmpty ? "No Name" : presenter.name)
                }
                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.gray)
                    Text(presenter.email)
                }
            }
            
            // --- Section Appearance/Theme ---
            Section(header: Text("Appearance")) {
                Button {
                    showThemeSelector = true
                } label: {
                    HStack {
                        Image(systemName: "moon.circle.fill")
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text("Theme")
                            Text(ThemeManager.shared.selectedThemeMode.rawValue)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 10)
                }
            }
            
            // --- Section Lain (reset password, logout, dll) ---
            Section {
                Button("Reset Password") {
                    presenter.resetPassword()
                }
                .foregroundColor(.orange)
                
                Button("Logout") {
                    presenter.logout()
                }
                .foregroundColor(.red)
            }
        }
        .listStyle(GroupedListStyle())
        .sheet(isPresented: $showThemeSelector) {
            ThemeSelector()
                .withAppTheme()
        }
        .navigationTitle("Settings")
        .withAppTheme()
        .alert(isPresented: $presenter.showAlert) {
            Alert(title: Text("Info"), message: Text(presenter.alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}
