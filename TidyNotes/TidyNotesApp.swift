//
//  TidyNotesApp.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 29/04/25.
//

import SwiftUI

@main
struct TidyNotesApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
