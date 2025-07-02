//
//  ResetPasswordView.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 02/07/25.
//

import SwiftUI

struct ResetPasswordView: View {
    @ObservedObject var presenter: ResetPasswordPresenter

    var body: some View {
        VStack(spacing: 24) {
            Text("Reset Password")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 40)
            TextField("Email", text: $presenter.email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding(.horizontal)
                .frame(height: 50)
            Button(action: {
                presenter.onSendTapped()
            }) {
                if presenter.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Kirim Email Reset")
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                }
            }
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
            Button("Kembali ke Login") {
                presenter.onLoginTapped()
            }
            .font(.footnote)
            .foregroundColor(.green)
        }
        .alert(isPresented: $presenter.showError) {
            Alert(title: Text("Error"), message: Text(presenter.errorMessage), dismissButton: .default(Text("OK")))
        }
        .alert("Email reset terkirim!", isPresented: $presenter.showSuccess) {
            Button("OK", role: .cancel) {
                presenter.onLoginTapped()
            }
        } message: {
            Text("Cek email kamu untuk reset password.")
        }
        Spacer()
    }
}
