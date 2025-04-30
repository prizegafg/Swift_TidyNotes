//
//  TaskListRouter.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 29/04/25.
//

import Foundation
import SwiftUI

/// Router untuk navigasi dari TaskList ke layar lain
final class TaskListRouter {
    /// Navigasi ke detail task
    func navigateToTaskDetail(task: TaskEntity) {
        // Placeholder implementation
        // Di implementasi nyata, ini akan melakukan navigasi ke TaskDetail module
        print("Navigate to task detail: \(task.title)")
    }
    
    /// Navigasi ke layar tambah task
    func navigateToAddTask() {
        // Placeholder implementation
        // Di implementasi nyata, ini akan melakukan navigasi ke AddTask module
        print("Navigate to add task")
    }
    
    /// Membuat view untuk TaskList
    static func makeTaskListView() -> some View {
        let interactor = TaskListInteractor()
        let router = TaskListRouter()
        let intent = TaskListIntent(interactor: interactor, router: router)
        return TaskListView(intent: intent)
    }
}


/// Modul untuk TaskList, bertindak sebagai factory untuk TaskList Screen
enum TaskListModule {
    /// Membuat view TaskList dengan semua dependencies yang diperlukan
    static func makeTaskListView() -> some View {
        let repository = InMemoryTaskRepository.shared
        let interactor = TaskListInteractor(repository: repository)
        let router = TaskListRouter()
        let intent = TaskListIntent(interactor: interactor, router: router)
        return TaskListView(intent: intent)
    }
}
