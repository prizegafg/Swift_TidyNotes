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
        VStack {
            Spacer()
            VStack(spacing: 24) {
                Text("Login")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom, 16)
                VStack(spacing: 16) {
                    TextField("Email", text: $presenter.email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .frame(height: 50)
                    
                    ZStack(alignment: .trailing) {
                        Group {
                            if presenter.showPassword {
                                TextField("Password", text: $presenter.password)
                            } else {
                                SecureField("Password", text: $presenter.password)
                            }
                        }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(height: 50)
                        
                        Button(action: { presenter.toggleShowPassword() }) {
                            Image(systemName: presenter.showPassword ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.gray)
                        }
                        .padding(.trailing, 10)
                    }
                }
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
                            .frame(height: 50)
                    }
                }
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Button("Belum punya akun? Register") {
                    presenter.onRegisterTapped()
                }
                .font(.footnote)
                .foregroundColor(.green)
            }
            .padding(.horizontal, 32)
            Spacer()
        }
        .padding(.top)
        .alert(isPresented: $presenter.showError) {
            Alert(title: Text("Error"), message: Text(presenter.errorMessage), dismissButton: .default(Text("OK")))
        }
    }
}
