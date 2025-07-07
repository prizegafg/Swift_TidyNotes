//
//  RegisterInteractor.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 15/05/25.
//

import Foundation
import Combine
import FirebaseAuth

final class RegisterInteractor {
    func register(email: String, password: String) -> AnyPublisher<String, Error> {
        UserProfileService.shared.registerWithEmail(email: email, password: password)
    }
    func saveUserProfile(_ profile: UserProfileEntity) -> AnyPublisher<Void, Error> {
        UserProfileRepository.shared.saveUserProfileToCloud(profile)
    }
}
