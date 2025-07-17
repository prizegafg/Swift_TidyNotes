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
    @State private var isFaceIDAuthenticated = false
    @State private var showFaceIDError = false
    @State private var faceIDErrorMsg: String?
    
    var body: some View {
        if checked {
            if isLoggedIn {
                if UserDefaults.standard.isFaceIDEnabled && !isFaceIDAuthenticated {
                    FaceIDGateView(
                        onSuccess: { isFaceIDAuthenticated = true },
                        onFail: { errorMsg in
                            faceIDErrorMsg = errorMsg ?? "Face ID Required."
                            showFaceIDError = true
                        }
                    )
                    .alert(isPresented: $showFaceIDError) {
                        Alert(
                            title: Text("Authentication Failed"),
                            message: Text(faceIDErrorMsg ?? "Face ID authentication is required."),
                            dismissButton: .default(Text("Retry")) {
                                isFaceIDAuthenticated = false
                            }
                        )
                    }
                } else {
                    TaskListModule.makeTaskListView()
                }
            } else {
                LoginModule.makeLoginView()
            }
        } else {
            ProgressView().onAppear {
                if let user = Auth.auth().currentUser,
                   let profile = UserProfileService.loadProfileFromLocal(userId: user.uid) {
                    SessionManager.shared.currentUser = profile
                    isLoggedIn = true
                } else {
                    isLoggedIn = false
                }
                checked = true
            }
        }
        
    }
}
