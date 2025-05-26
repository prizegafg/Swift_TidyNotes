//
//  RegisterView.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 15/05/25.
//

import SwiftUI

struct RegisterView: View {
    @ObservedObject var presenter: RegisterPresenter

    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 24) {
                Text("Buat Akun Baru")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom, 16)

                VStack(spacing: 16) {
                    TextField("Email", text: $presenter.email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .frame(height: 50)

                    SecureField("Password", text: $presenter.password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(height: 50)

                    SecureField("Konfirmasi Password", text: $presenter.confirmPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(height: 50)
                }

                Button(action: {
                    presenter.onRegisterTapped()
                }) {
                    if presenter.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Register")
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                    }
                }
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)

                Button("Sudah punya akun? Login") {
                    presenter.onLoginTapped()
                }
                .font(.footnote)
                .foregroundColor(.blue)
            }
            .padding(.horizontal, 32)
            Spacer()
        }
        .padding(.top)
        .alert(isPresented: $presenter.showError) {
            Alert(title: Text("Error"), message: Text(presenter.errorMessage), dismissButton: .default(Text("OK")))
        }
        .alert("Registrasi Berhasil", isPresented: $presenter.showSuccess) {
            Button("OK", role: .cancel) {
                presenter.onLoginTapped()
            }
        }
    }
}
