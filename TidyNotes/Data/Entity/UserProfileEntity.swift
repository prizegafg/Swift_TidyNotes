//
//  UserProfile.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 02/07/25.
//

import Foundation

struct UserProfileEntity: Identifiable, Codable {
    var id: String { userId }
    var userId: String
    var username: String
    var firstName: String
    var lastName: String
    var email: String
    var profession: String?
    
    init(
        userId: String,
        username: String = "",
        firstName: String = "",
        lastName: String = "",
        email: String = "",
        profession: String? = nil
    ) {
        self.userId = userId
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.profession = profession
    }
    
    init(userId: String, dict: [String: Any]) {
        self.userId = userId
        self.username = dict["username"] as? String ?? ""
        self.firstName = dict["firstName"] as? String ?? ""
        self.lastName = dict["lastName"] as? String ?? ""
        self.email = dict["email"] as? String ?? ""
        self.profession = dict["profession"] as? String
    }
}
