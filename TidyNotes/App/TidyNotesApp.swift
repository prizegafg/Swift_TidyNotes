//
//  TidyNotesApp.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 29/04/25.
//

import SwiftUI

@main
struct TidyNotesApp: App {
    
    var body: some Scene {
        WindowGroup {
            TaskListModule.makeTaskListView()
        }
    }
    
}
