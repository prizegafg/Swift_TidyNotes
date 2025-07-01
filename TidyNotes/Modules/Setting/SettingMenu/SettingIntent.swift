//
//  SettingIntent.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 15/05/25.
//

import SwiftUI
import Combine
import PhotosUI

final class SettingsPresenter: ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var image: UIImage? = nil
    @Published var selectedItem: PhotosPickerItem? = nil {
        didSet {
            loadImage()
        }
    }

    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""

    private let interactor: SettingsInteractor
    private let router: SettingsRouter
    private var cancellables = Set<AnyCancellable>()

    init(interactor: SettingsInteractor, router: SettingsRouter) {
        self.interactor = interactor
        self.router = router
        loadInitialData()
    }

    func loadInitialData() {
        let user = interactor.getCurrentUserProfile()
        name = user.name
        email = user.email
        if let savedImage = interactor.loadSavedImage() {
            image = savedImage
        }
    }

    func saveProfile() {
        interactor.saveUserProfile(name: name, email: email, image: image)
        showAlert(message: "Profile updated.")
    }

    func resetPassword() {
        interactor.resetPassword { [weak self] success, error in
            if success {
                self?.showAlert(message: "Password reset email sent.")
            } else {
                self?.showAlert(message: error ?? "Failed to send reset email.")
            }
        }
    }

    func logout() {
        interactor.logout { [weak self] error in
            if let error = error {
                self?.showAlert(message: error.localizedDescription)
            } else {
                self?.router.navigateToLogin()
            }
        }
    }

    private func loadImage() {
        guard let item = selectedItem else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                await MainActor.run {
                    self.image = uiImage
                }
            }
        }
    }

    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
}
