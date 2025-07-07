//
//  RealmUserProfile.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 15/05/25.
//

import RealmSwift

class RealmUserProfileObject: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var userId: String
    @Persisted var username: String
    @Persisted var password: String
    @Persisted var firstName: String
    @Persisted var lastName: String
    @Persisted var email: String
    @Persisted var profession: String?
    
    convenience init(entity: UserProfileEntity) {
        self.init()
        self.userId = entity.userId
        self.username = entity.username
        self.firstName = entity.firstName
        self.lastName = entity.lastName
        self.email = entity.email
        self.profession = entity.profession
    }
    
    func toEntity() -> UserProfileEntity {
        UserProfileEntity(
            userId: userId,
            username: username,
            firstName: firstName,
            lastName: lastName,
            email: email,
            profession: profession
        )
    }
}
