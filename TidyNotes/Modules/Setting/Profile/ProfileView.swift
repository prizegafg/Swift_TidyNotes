//
//  ProfileView.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 17/07/25.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    @ObservedObject var presenter: ProfilePresenter
    @State private var showImagePicker = false
    @State private var selectedPhoto: PhotosPickerItem?

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Foto profil
                ZStack(alignment: .bottomTrailing) {
                    Group {
                        if let image = presenter.profileImage {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .foregroundColor(.blue)
                        }
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray, lineWidth: 1))

                    Button(action: { showImagePicker = true }) {
                        Image(systemName: "camera.fill")
                            .padding(8)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                    .offset(x: -8, y: -8)
                }
                .padding(.top, 32)

                // Data User
                VStack(spacing: 16) {
                    TextField("Username", text: $presenter.username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .frame(height: 50)
                    TextField("First Name", text: $presenter.firstName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(height: 50)
                    TextField("Last Name", text: $presenter.lastName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(height: 50)
                    TextField("Profession", text: $presenter.profession)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(height: 50)
                    TextField("Email", text: .constant(presenter.email))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(height: 50)
                        .disabled(true)
                        .opacity(0.7)
                }

                // Tombol simpan
                Button(action: { presenter.onSaveTapped() }) {
                    if presenter.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Simpan")
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                    }
                }
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.top, 16)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Profile")
        .onAppear { presenter.onAppear() }
        .alert(isPresented: $presenter.showError) {
            Alert(title: Text("Error"), message: Text(presenter.errorMessage), dismissButton: .default(Text("OK")))
        }
        .alert("Update Berhasil", isPresented: $presenter.showSuccess) {
            Button("OK", role: .cancel) { }
        }
        .photosPicker(isPresented: $showImagePicker, selection: $selectedPhoto, matching: .images)
        .onChange(of: selectedPhoto) { newItem in
            if let newItem = newItem {
                Task {
                    if let data = try? await newItem.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        presenter.profileImage = uiImage
                    }
                }
            }
        }
    }
}
