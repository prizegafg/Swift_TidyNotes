//
//  UserProfile.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 02/07/25.
//

import Foundation

struct UserProfileEntity: Identifiable, Codable {
    var id: String { userId }
    let userId: String
    var username: String
    var firstName: String
    var lastName: String
    var email: String
    var profession: String?

    init(realm: RealmUserProfile) {
        self.userId = realm.userId
        self.username = realm.username
        self.firstName = realm.firstName
        self.lastName = realm.lastName
        self.email = realm.email
        self.profession = ""
    }
    init?(dict: [String: Any]) {
        guard let userId = dict["userId"] as? String,
              let username = dict["username"] as? String,
              let firstName = dict["firstName"] as? String,
              let lastName = dict["lastName"] as? String,
              let email = dict["email"] as? String
        else { return nil }
        self.userId = userId
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.profession = dict["profession"] as? String ?? ""
    }
}
