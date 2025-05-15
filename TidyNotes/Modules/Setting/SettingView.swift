//
//  SettingView.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 15/05/25.
//

import SwiftUI
import PhotosUI

struct SettingsView: View {
    @ObservedObject var presenter: SettingsPresenter

    var body: some View {
        Form {
            Section(header: Text("User Info")) {
                TextField("Full Name", text: $presenter.name)
                TextField("Email", text: $presenter.email)
            }

            Section(header: Text("Photo")) {
                if let image = presenter.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                        .clipShape(Circle())
                }

                PhotosPicker(selection: $presenter.selectedItem, matching: .images) {
                    Text("Select Photo")
                }
            }

            Section {
                Button("Save Profile", action: presenter.saveProfile)
                Button("Reset Password", action: presenter.resetPassword)
                    .foregroundColor(.red)
                Button("Logout", action: presenter.logout)
                    .foregroundColor(.red)
            }
        }
        .navigationTitle("Settings")
        .alert(isPresented: $presenter.showAlert) {
            Alert(title: Text("Info"), message: Text(presenter.alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}
