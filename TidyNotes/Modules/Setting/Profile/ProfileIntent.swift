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
    @Published var profileImage: UIImage? = nil

    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var showSuccess = false
    @Published var userModel: UserProfileModel

    private let interactor: ProfileInteractor
    private let router: ProfileRouter
    private var cancellables = Set<AnyCancellable>()

    init(interactor: ProfileInteractor, router: ProfileRouter) {
        self.interactor = interactor
        self.router = router
        
        if let user = SessionManager.shared.currentUser {
            self.userModel = UserProfileModel(entity: user)
        } else {
            self.userModel = UserProfileModel(entity: UserProfileEntity(userId: "", username: "", firstName: "", lastName: "", email: ""))
        }
    }

    func onAppear() {
        if let image = interactor.loadSavedProfileImage() {
            profileImage = image
        }
    }

    func onSaveTapped() {
        guard !userModel.username.trimmed.isEmpty,
              !userModel.firstName.trimmed.isEmpty,
              !userModel.lastName.trimmed.isEmpty else {
            showError(message: "Field Cannot be Empty")
            return
        }
        guard let currentUser = SessionManager.shared.currentUser else {
            showError(message: "User Not Found")
            return
        }

        isLoading = true
        let updated = userModel.toEntity()

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
