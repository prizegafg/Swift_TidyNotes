//
//  UserProfileRepository.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 05/07/25.
//

import Foundation
import Combine
import FirebaseFirestore

final class UserProfileRepository {
    static let shared = UserProfileRepository()
    private init() {}

    func saveUserProfileToCloud(_ profile: UserProfileEntity) -> AnyPublisher<Void, Error> {
        let db = Firestore.firestore()
        let data: [String: Any] = [
            "userId": profile.id,
            "email": profile.email,
            "username": profile.username,
            "firstName": profile.firstName,
            "lastName": profile.lastName,
            "profession": profile.profession
        ]
        return Future<Void, Error> { promise in
            db.collection("users").document(profile.id).setData(data) { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func fetchUserProfileFromCloud(userId: String, completion: @escaping (Result<UserProfileEntity, Error>) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { document, error in
            if let error = error {
                completion(.failure(error))
            } else if let document = document, let data = document.data() {
                do {
                    let profile = UserProfileEntity(
                        userId: data["id"] as? String ?? userId,
                        username: data["email"] as? String ?? "",
                        firstName: data["username"] as? String ?? "",
                        lastName: data["firstName"] as? String ?? "",
                        email: data["lastName"] as? String ?? "",
                        profession: data["profession"] as? String ?? ""
                    )
                    completion(.success(profile))
                } catch {
                    completion(.failure(error))
                }
            } else {
                completion(.failure(AppError.notFound))
            }
        }
    }
}
