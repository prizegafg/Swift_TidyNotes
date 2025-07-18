//
//  ResetPasswordIntent.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 02/07/25.
//

import Foundation
import Combine

final class ResetPasswordPresenter: ObservableObject {
    @Published var email: String = ""
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var showSuccess = false

    private let interactor: ResetPasswordInteractor
    private let router: ResetPasswordRouter
    private var cancellables = Set<AnyCancellable>()

    init(interactor: ResetPasswordInteractor, router: ResetPasswordRouter) {
        self.interactor = interactor
        self.router = router
    }

    func onSendTapped() {
        guard !email.trimmed.isEmpty else {
            showError(message: "Email wajib diisi.")
            return
        }
        isLoading = true
        interactor.sendResetPassword(email: email)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.showError(message: error.localizedDescription)
                } else {
                    self?.showSuccess = true
                }
            }, receiveValue: { })
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
