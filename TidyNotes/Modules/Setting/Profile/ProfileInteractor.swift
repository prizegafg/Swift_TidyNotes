//
//  ProfileInteractor.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 17/07/25.
//



import Foundation
import Combine
import UIKit

final class ProfileInteractor {
    private let userProfileService = UserProfileService.shared

    func saveUserProfile(_ profile: UserProfileEntity, image: UIImage?) -> AnyPublisher<Void, Error> {
        let saveProfileToCloud = UserProfileRepository.shared.saveUserProfileToCloud(profile)
        let saveProfileToLocal = Future<Void, Error> { promise in
            UserProfileService.saveProfileToLocal(profile)
            promise(.success(()))
        }.eraseToAnyPublisher()
        let saveImagePublisher = Future<Void, Error> { promise in
            if let image = image {
                if let data = image.jpegData(compressionQuality: 0.8) {
                    let url = self.getProfileImageSavePath(userId: profile.userId)
                    do {
                        try data.write(to: url)
                    } catch {
                        promise(.failure(error))
                        return
                    }
                }
            }
            promise(.success(()))
        }.eraseToAnyPublisher()

        return saveProfileToCloud
            .flatMap { _ in saveProfileToLocal }
            .flatMap { _ in saveImagePublisher }
            .eraseToAnyPublisher()
    }

    func loadSavedProfileImage() -> UIImage? {
        guard let userId = SessionManager.shared.currentUser?.userId else { return nil }
        let url = getProfileImageSavePath(userId: userId)
        return UIImage(contentsOfFile: url.path)
    }

    private func getProfileImageSavePath(userId: String) -> URL {
        let filename = "profile_\(userId).jpg"
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)
    }
}
