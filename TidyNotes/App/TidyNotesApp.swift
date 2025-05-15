//
//  TidyNotesApp.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 29/04/25.
//

import SwiftUI

@main
struct TidyNotesApp: App {
    
    init() {
        NotificationManager.shared.registerNotificationActions()
        NotificationManager.shared.requestPermissionIfNeeded()
                _ = NotificationDelegate.shared 
    }
    
    var body: some Scene {
        WindowGroup {
            let session = SessionManager.shared
            if let user = session.currentUser, user.isLoggedIn {
                TaskListModule.makeTaskListView()
            } else {
                LoginModule.makeLoginView()
            }
        }
    }
    
}
