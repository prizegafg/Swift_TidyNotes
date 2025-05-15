//
//  LoginView.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 15/05/25.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var presenter: LoginPresenter

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Welcome Back 👋")
                    .font(.title)
                    .fontWeight(.bold)

                TextField("Email", text: $presenter.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)

                SecureField("Password", text: $presenter.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(action: {
                    presenter.onLoginTapped()
                }) {
                    if presenter.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Login")
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 50)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                Button("Belum punya akun? Register") {
                    presenter.onRegisterTapped()
                }
                .font(.footnote)
                .foregroundColor(.blue)

                Spacer()
            }
            .padding()
            .navigationTitle("Login")
            .alert(isPresented: $presenter.showError) {
                Alert(title: Text("Login Gagal"), message: Text(presenter.errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}
