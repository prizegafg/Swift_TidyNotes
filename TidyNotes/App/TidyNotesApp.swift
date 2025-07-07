//
//  TidyNotesApp.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 29/04/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

@main
struct TidyNotesApp: App {
    
    init() {
        FirebaseApp.configure()
        NotificationManager.shared.registerNotificationActions()
        NotificationManager.shared.requestPermissionIfNeeded()
        _ = NotificationDelegate.shared
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .withAppTheme()
        }
    }
    
}

struct RootView: View {
    @State private var isLoggedIn: Bool = false
    @State private var checked: Bool = false
    
    var body: some View {
        if checked {
            if isLoggedIn {
                TaskListModule.makeTaskListView()
            } else {
                LoginModule.makeLoginView()
            }
        } else {
            ProgressView()
                .onAppear {
                    if let user = Auth.auth().currentUser {
                        if SessionManager.shared.isLoggedIn() {
                            isLoggedIn = true
                        } else {
                            isLoggedIn = false
                        }
                    } else {
                        isLoggedIn = false
                    }
                    checked = true
                }
        }
        
    }
}
