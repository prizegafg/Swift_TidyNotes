//
//  ResetPasswordView.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 02/07/25.
//

import SwiftUI

struct ResetPasswordView: View {
    @ObservedObject var presenter: ResetPasswordPresenter
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            Text("Password Reset".localizedDescription)
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 40)
            Text("Please input your account email to reset password".localizedDescription)
                .font(.caption)
                .fontWeight(.regular)

            TextField("Email", text: $presenter.email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding(.horizontal)
                .frame(height: 50)
                .disabled(!presenter.email.isEmpty) // Disable jika email auto-isi dari Setting

            Button(action: {
                presenter.onSendTapped()
            }) {
                if presenter.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Send Reset Email".localizedDescription)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                }
            }
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
            .disabled(presenter.email.trimmed.isEmpty) // disable kalau field kosong

            Spacer()
        }
        .alert(isPresented: $presenter.showError) {
            Alert(title: Text("Error"), message: Text(presenter.errorMessage), dismissButton: .default(Text("OK")))
        }
        .alert("Reset email sent!".localizedDescription, isPresented: $presenter.showSuccess) {
            Button("OK", role: .cancel) {
                dismiss()
            }
        } message: {
            Text("Check your email to reset password".localizedDescription)
        }
    }
}
