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
        // Inisialisasi CoreData dan repository
        CoreDataManager.shared
        RepositoryFactory.shared.setRepositoryType(.coreData)
        
#if DEBUG
        logCoreDataDirectory()
#endif
    }

    
    var body: some Scene {
        WindowGroup {
//            ContentView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
            TaskListModule.makeTaskListView()
        }
    }
    
    // MARK: - Logging for debug
    private func logCoreDataDirectory() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        print("📁 Documents Directory: \(documentsDirectory?.path ?? "unknown")")
        checkEntityCounts()
    }
    
    private func checkEntityCounts() {
        let viewContext = CoreDataStack.shared.viewContext
        
        let projectFetchRequest = CDProject.fetchRequest()
        projectFetchRequest.fetchLimit = 1000
        do {
            let count = try viewContext.count(for: projectFetchRequest)
            print("📊 Project count: \(count)")
        } catch {
            print("❌ Error counting projects: \(error)")
        }
        
        let taskFetchRequest = CDTask.fetchRequest()
        taskFetchRequest.fetchLimit = 1000
        do {
            let count = try viewContext.count(for: taskFetchRequest)
            print("📊 Task count: \(count)")
        } catch {
            print("❌ Error counting tasks: \(error)")
        }
    }
}
