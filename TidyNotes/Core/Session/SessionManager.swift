//
//  SessionManager.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 15/05/25.
//

import Foundation
import RealmSwift

final class SessionManager {
    static let shared = SessionManager()

    let realmApp: RealmSwift.App
    var currentUser: User? {
        realmApp.currentUser
    }

    private init() {
        // Ganti dengan App ID kamu
        self.realmApp = RealmSwift.App(id: "tidynotesapp-fjyavvn")
    }
}
