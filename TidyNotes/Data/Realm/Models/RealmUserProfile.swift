//
//  RealmUserProfile.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 15/05/25.
//

import RealmSwift

class UserProfile: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var userId: String // ID dari MongoDB Realm
    @Persisted var username: String
    @Persisted var password: String // (⚠️ nanti harus di-hash, bukan plaintext)
    @Persisted var firstName: String
    @Persisted var lastName: String
    @Persisted var email: String
}
