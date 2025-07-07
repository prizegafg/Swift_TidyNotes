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
    private init() {}
    
    var isFirstLogin: Bool {
        get { !UserDefaults.standard.bool(forKey: "hasLoggedInBefore") }
        set { UserDefaults.standard.set(!newValue, forKey: "hasLoggedInBefore") }
    }
    func markFirstLoginCompleted() {
        UserDefaults.standard.set(true, forKey: "hasLoggedInBefore")
    }
    
    func isLoggedIn() -> Bool {
        return currentUser != nil
    }
    
    var currentUser: UserProfileEntity? {
        get {
            guard let userId = UserDefaults.standard.string(forKey: "currentUserId") else { return nil }
            return UserProfileService.loadProfileFromLocal(userId: userId)
        }
        set {
            if let user = newValue {
                UserDefaults.standard.set(user.id, forKey: "currentUserId")
            } else {
                UserDefaults.standard.removeObject(forKey: "currentUserId")
            }
        }
    }
}
