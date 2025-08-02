//
//  UserModel.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 30/07/25.
//

struct UserProfileModel: Identifiable, Equatable {
    var id: String { userId }
    var userId: String
    var username: String
    var firstName: String
    var lastName: String
    var email: String
    var profession: String?
    
    init(entity: UserProfileEntity) {
        self.userId = entity.userId
        self.username = entity.username
        self.firstName = entity.firstName
        self.lastName = entity.lastName
        self.email = entity.email
        self.profession = entity.profession
    }
    
    func toEntity() -> UserProfileEntity {
        return UserProfileEntity(
            userId: userId,
            username: username,
            firstName: firstName,
            lastName: lastName,
            email: email,
            profession: profession
        )
    }
}
