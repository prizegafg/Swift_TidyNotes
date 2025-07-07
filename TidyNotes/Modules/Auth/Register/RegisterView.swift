//
//  RegisterView.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 15/05/25.
//

import SwiftUI

struct RegisterView: View {
    @ObservedObject var presenter: RegisterPresenter
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 24) {
                Text("Create New Account")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom, 16)
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
                    TextField("Email", text: $presenter.email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .frame(height: 50)
                    
                    ZStack(alignment: .trailing) {
                        Group {
                            if showPassword {
                                TextField("Password", text: $presenter.password)
                            } else {
                                SecureField("Password", text: $presenter.password)
                            }
                        }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(height: 50)
                        
                        Button(action: { showPassword.toggle() }) {
                            Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.gray)
                        }
                        .padding(.trailing, 10)
                    }
                    
                    ZStack(alignment: .trailing) {
                        Group {
                            if showConfirmPassword {
                                TextField("Repeat Password", text: $presenter.confirmPassword)
                            } else {
                                SecureField("Repeat Password", text: $presenter.confirmPassword)
                            }
                        }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(height: 50)
                        
                        Button(action: { showConfirmPassword.toggle() }) {
                            Image(systemName: showConfirmPassword ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.gray)
                        }
                        .padding(.trailing, 10)
                    }
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
                
                Button("Already Have Account? Login") {
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
