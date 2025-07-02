//
//  RealmUserProfile.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 15/05/25.
//

import RealmSwift

class RealmUserProfile: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var userId: String
    @Persisted var username: String
    @Persisted var password: String
    @Persisted var firstName: String
    @Persisted var lastName: String
    @Persisted var email: String
    @Persisted var profession: String?
}
