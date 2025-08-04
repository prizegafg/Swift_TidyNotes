//
//  UserServices.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 02/07/25.
//

import Foundation
import RealmSwift
import FirebaseFirestore
import FirebaseAuth
import Combine


final class UserProfileService {
    static let shared = UserProfileService()
    
    
    func registerWithEmail(email: String, password: String) -> AnyPublisher<String, Error> {
        Future<String, Error> { promise in
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    promise(.failure(error))
                } else if let uid = authResult?.user.uid {
                    promise(.success(uid))
                } else {
                    promise(.failure(AppError.unknown))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    static func loadProfileFromLocal(userId: String) -> UserProfileEntity? {
        do {
            let realm = try Realm()
            guard let obj = realm.objects(RealmUserProfileObject.self).filter("userId == %@", userId).first else { return nil }
            return obj.toEntity()
        } catch {
            print("❌ Gagal load profile dari local: \(error)")
            return nil
        }
    }
    
    static func saveProfileToLocal(_ profile: UserProfileEntity) {
        do {
            let realm = try Realm()
            if let existing = realm.objects(RealmUserProfileObject.self).filter("userId == %@", profile.userId).first {
                try realm.write {
                    existing.username = profile.username
                    existing.firstName = profile.firstName
                    existing.lastName = profile.lastName
                    existing.email = profile.email
                    existing.profession = profile.profession
                }
            } else {
                let object = RealmUserProfileObject(entity: profile)
                try realm.write {
                    realm.add(object)
                }
            }
        } catch {
            print("❌ failed to save profile to local: \(error)")
        }
    }
    
    

    static func fetchUserProfileFromFirestore(userId: String, completion: @escaping (Result<UserProfileEntity, Error>) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { doc, error in
            if let error = error {
                completion(.failure(AppError.networkError(error.localizedDescription)))
                return
            }
            guard let data = doc?.data() else {
                completion(.failure(AppError.notFound))
                return
            }
            let profile = UserProfileEntity(
                userId: userId,
                username: data["username"] as? String ?? "",
                firstName: data["firstName"] as? String ?? "",
                lastName: data["lastName"] as? String ?? "",
                email: data["email"] as? String ?? "",
                profession: data["profession"] as? String
            )
            completion(.success(profile))
        }
    }
    
    static func clearProfileFromLocal(userId: String) {
        do {
            let realm = try Realm()
            if let obj = realm.objects(RealmUserProfileObject.self).filter("userId == %@", userId).first {
                try realm.write {
                    realm.delete(obj)
                }
            }
        } catch {
            print("❌ Failed to clear user profile: \(error)")
        }
        SessionManager.shared.currentUser = nil
        UserDefaults.standard.removeObject(forKey: "currentUserId")
    }
}
