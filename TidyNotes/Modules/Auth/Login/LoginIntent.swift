//
//  LoginIntent.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 15/05/25.
//

import Foundation
import Combine

final class LoginPresenter: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
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
                self?.router.navigateToTaskList()
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
