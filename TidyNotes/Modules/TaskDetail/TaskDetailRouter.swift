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
    var onTasksUpdated: (() -> Void)?

    static func makeTaskDetailView(taskId: UUID) -> some View {
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
        return TaskDetailView(presenter: presenter)
    }

    static func makeAddTaskView(userId: String, onTasksUpdated: (() -> Void)? = nil) -> some View {
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
        return NavigationStack { TaskDetailView(presenter: presenter) }
    }

    func dismissTaskDetail() {}
    func dismissAndRefreshTaskList() {
        onTasksUpdated?()
        dismissTaskDetail()
    }
}
