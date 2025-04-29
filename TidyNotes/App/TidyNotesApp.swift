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
//            ContentView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
            let repository = InMemoryTaskRepository()
            let interactor = TaskListInteractor(taskRepository: repository, presenter: nil)
            let intent = TaskListIntent(interactor: interactor)
            interactor.setPresenter(intent)
            
            TaskListView(intent: intent, projectId: nil)
        }
    }
}
