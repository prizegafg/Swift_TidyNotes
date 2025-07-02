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

class UserProfileService {
    static let shared = UserProfileService()
    private let db = Firestore.firestore()

    func fetchProfile(userId: String, completion: @escaping (UserProfile?) -> Void) {
        db.collection("users").document(userId).getDocument { doc, error in
            if let data = doc?.data(), let entity = UserProfile(dict: data) {
                Self.saveProfileToLocal(entity)
                completion(entity)
            } else {
                completion(Self.loadProfileFromLocal(userId: userId))
            }
        }
    }

    func saveProfile(_ profile: UserProfile, completion: @escaping (Bool) -> Void) {
        var dict: [String: Any] = [
            "userId": profile.userId,
            "username": profile.username,
            "firstName": profile.firstName,
            "lastName": profile.lastName,
            "email": profile.email
        ]
        if let prof = profile.profession {
            dict["profession"] = prof
        }
        db.collection("users").document(profile.userId).setData(dict) { error in
            if error == nil {
                Self.saveProfileToLocal(profile)
            }
            completion(error == nil)
        }
    }

    static func loadProfileFromLocal(userId: String) -> UserProfile? {
        let realm = try! Realm()
        if let realmObj = realm.objects(RealmUserProfile.self).filter("userId == %@", userId).first {
            return UserProfile(realm: realmObj)
        }
        return nil
    }

    static func saveProfileToLocal(_ profile: UserProfile) {
        let realm = try! Realm()
        var obj = realm.objects(RealmUserProfile.self).filter("userId == %@", profile.userId).first
        if obj == nil {
            obj = RealmUserProfile()
            obj?.userId = profile.userId
        }
        try! realm.write {
            obj?.username = profile.username
            obj?.firstName = profile.firstName
            obj?.lastName = profile.lastName
            obj?.email = profile.email
            if let profession = profile.profession, obj?.responds(to: Selector("setProfession:")) ?? false {
                obj?.setValue(profession, forKey: "profession")
            }
            if realm.objects(RealmUserProfile.self).filter("userId == %@", profile.userId).first == nil, let obj = obj {
                realm.add(obj)
            }
        }
    }
}
