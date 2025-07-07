//
//  RegisterIntent.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 15/05/25.
//

import Foundation
import Combine

final class RegisterPresenter: ObservableObject {
    @Published var username: String = ""
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var profession: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var showSuccess: Bool = false

    private let interactor: RegisterInteractor
    private let router: RegisterRouter
    private var cancellables = Set<AnyCancellable>()

    init(interactor: RegisterInteractor, router: RegisterRouter) {
        self.interactor = interactor
        self.router = router
    }

    func onRegisterTapped() {
        guard !username.trimmed.isEmpty,
              !firstName.trimmed.isEmpty,
              !lastName.trimmed.isEmpty,
              !profession.trimmed.isEmpty,
              !email.trimmed.isEmpty,
              !password.trimmed.isEmpty else {
            showError(message: "All field must be filled")
            return
        }
        
        guard password == confirmPassword else {
            showError(message: "Password and repeat password do not match.")
            return
        }

        isLoading = true
        interactor.register(email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.showError(message: error.localizedDescription)
                }
            }, receiveValue: { _ in [weak self]; in
                self?.showSuccess = true
            })
            .store(in: &cancellables)
    }

    func onLoginTapped() {
        router.navigateToLogin()
    }

    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}
