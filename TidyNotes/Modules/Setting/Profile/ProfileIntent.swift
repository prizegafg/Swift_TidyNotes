//
//  ProfileIntent.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 17/07/25.
//

import Foundation
import Combine
import SwiftUI

final class ProfilePresenter: ObservableObject {
    @Published var username: String = ""
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var profession: String = ""
    @Published var profileImage: UIImage? = nil

    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var showSuccess = false

    private let interactor: ProfileInteractor
    private let router: ProfileRouter
    private var cancellables = Set<AnyCancellable>()

    init(interactor: ProfileInteractor, router: ProfileRouter) {
        self.interactor = interactor
        self.router = router
    }

    func onAppear() {
        guard let user = SessionManager.shared.currentUser else {
            showError(message: "User not logged in.")
            return
        }
        username = user.username
        firstName = user.firstName
        lastName = user.lastName
        email = user.email
        profession = user.profession ?? ""
        if let image = interactor.loadSavedProfileImage() {
            profileImage = image
        }
    }

    func onSaveTapped() {
        guard !username.trimmed.isEmpty,
              !firstName.trimmed.isEmpty,
              !lastName.trimmed.isEmpty else {
            showError(message: "Field Cannot be Empty")
            return
        }
        guard let currentUser = SessionManager.shared.currentUser else {
            showError(message: "User Not Found")
            return
        }

        isLoading = true
        let updated = UserProfileEntity(
            userId: currentUser.userId,
            username: username,
            firstName: firstName,
            lastName: lastName,
            email: email,
            profession: profession
        )

        interactor.saveUserProfile(updated, image: profileImage)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] comp in
                self?.isLoading = false
                if case let .failure(err) = comp {
                    self?.showError(message: err.localizedDescription)
                } else {
                    self?.showSuccess = true
                    SessionManager.shared.currentUser = updated
                }
            }, receiveValue: { })
            .store(in: &cancellables)
    }

    func onSelectPhotoTapped() {
//        router.presentImagePicker { [weak self] image in
//            if let img = image {
//                self?.profileImage = img
//            }
//        }
    }

    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}
