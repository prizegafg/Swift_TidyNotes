//
//  TaskDetailRouter.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 04/05/25.
//

//
//  TaskDetailRouter.swift
//  TaskDetail/Router
//

import SwiftUI
import Combine

final class TaskDetailRouter {
    // Event yang bisa digunakan untuk memicu refresh pada task list
    var onTasksUpdated: (() -> Void)?
    
    // Factory method untuk task detail (mode edit)
    static func makeTaskDetailView(taskId: UUID) -> some View {
        let interactor = TaskDetailInteractor(taskRepository: InMemoryTaskRepository.shared)
        let router = TaskDetailRouter()
        let presenter = TaskDetailPresenter(taskId: taskId, interactor: interactor, router: router)
        return TaskDetailView(presenter: presenter)
    }
    
    // Factory method untuk add task (mode create)
    static func makeAddTaskView(onTasksUpdated: (() -> Void)? = nil) -> some View {
        let interactor = TaskDetailInteractor(taskRepository: InMemoryTaskRepository.shared)
        let router = TaskDetailRouter()
        let presenter = TaskDetailPresenter(interactor: interactor, router: router)
        router.onTasksUpdated = onTasksUpdated
        return NavigationStack {
            TaskDetailView(presenter: presenter)
        }
    }
    
    func dismissTaskDetail() {
        // Implementasi untuk menutup view
        // Menggunakan NotificationCenter atau Environment untuk dismiss presentedVC
    }
    
    func dismissAndRefreshTaskList() {
        // Panggil callback untuk refresh task list
        onTasksUpdated?()
        
        // Dismiss view
        dismissTaskDetail()
    }
    
    deinit {
        print("TaskDetailRouter deinit")
        // Clear closure to avoid retain cycles
        onTasksUpdated = nil
    }
}

