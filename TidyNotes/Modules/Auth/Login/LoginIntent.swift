//
//  LoginIntent.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 15/05/25.
//

import Foundation
import Combine
import FirebaseAuth

final class LoginPresenter: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var showPassword = false
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    
    private let interactor: LoginInteractor
    private let router: LoginRouter
    private var cancellables = Set<AnyCancellable>()
    
    init(interactor: LoginInteractor, router: LoginRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func toggleShowPassword() {
        showPassword.toggle()
    }
    
    func onLoginTapped() {
        guard !email.trimmed.isEmpty, !password.trimmed.isEmpty else {
            showError(message: "Email dan password wajib diisi.")
            return
        }
        isLoading = true
        interactor.login(email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.showError(message: error.localizedDescription)
                }
            }, receiveValue: { [weak self] in
                guard let self = self else { return }
                // Ambil userId Firebase Auth
                if let userId = Auth.auth().currentUser?.uid {
                    TaskSyncService.shared.fetchTasksFromFirestoreAndReplaceRealm(for: userId) { success in
                        if success {
                            // Setelah sukses sync, masuk ke halaman TaskList
                            DispatchQueue.main.async {
                                self.router.navigateToTaskList()
                            }
                        } else {
                            // Kalau sync gagal, tampilkan error atau tetap lanjut (bebas)
                            DispatchQueue.main.async {
                                self.showError(message: "Gagal sync data dari cloud.")
                            }
                        }
                    }
                } else {
                    // Handle jika userId tidak ditemukan
                    self.showError(message: "User ID tidak ditemukan.")
                }
            })
            .store(in: &cancellables)
    }
    
    func onRegisterTapped() {
        router.navigateToRegister()
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}
