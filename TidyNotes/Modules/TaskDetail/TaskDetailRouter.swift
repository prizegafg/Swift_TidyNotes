//
//  TaskDetailRouter.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 04/05/25.
//

import SwiftUI
import Combine

final class TaskDetailRouter {
    var onTasksUpdated: (() -> Void)?
    var onDismiss: (() -> Void)?

    static func makeTaskDetailView(taskId: UUID,
                                   onTasksUpdated: (() -> Void)? = nil,
                                   onDismiss: (() -> Void)? = nil
    ) -> some View {
        let interactor = TaskDetailInteractor(repository: ServiceLocator.shared.taskRepository)
        let router = TaskDetailRouter()
        let dummyTask = TaskEntity( 
            id: taskId, userId: "", title: "", descriptionText: "")
        let presenter = TaskDetailPresenter(
            task: dummyTask,
            interactor: interactor,
            router: router,
            mode: .edit
        )
        
        router.onTasksUpdated = onTasksUpdated
        router.onDismiss = onDismiss
        return TaskDetailView(presenter: presenter)
    }

    static func makeAddTaskView(userId: String,
                                onTasksUpdated: (() -> Void)? = nil,
                                onDismiss: (() -> Void)? = nil
    ) -> some View {
        let interactor = TaskDetailInteractor(repository: ServiceLocator.shared.taskRepository)
        let router = TaskDetailRouter()
        let newTask = TaskEntity(userId: userId, title: "", descriptionText: "")
        let presenter = TaskDetailPresenter(
            task: newTask,
            interactor: interactor,
            router: router,
            mode: .create
        )
        router.onTasksUpdated = onTasksUpdated
        router.onDismiss = onDismiss
        return NavigationStack { TaskDetailView(presenter: presenter) }
    }

    func dismissAndRefreshTaskList() {
        onTasksUpdated?()
        onDismiss?()
    }
}
