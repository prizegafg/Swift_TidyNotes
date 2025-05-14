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
        NotificationManager.shared.requestPermissionIfNeeded()
    }
    
    var body: some Scene {
        WindowGroup {
            TaskListModule.makeTaskListView()
        }
    }
    
}
