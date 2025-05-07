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
    static func makeTaskDetailView(taskId: UUID) -> some View {
        let interactor = TaskDetailInteractor(taskRepository: InMemoryTaskRepository.shared)
        let router = TaskDetailRouter()
        let presenter = TaskDetailPresenter(taskId: taskId, interactor: interactor, router: router)
        return TaskDetailView(presenter: presenter)
    }

    func dismissTaskDetail() {
        // Optional: kalau pakai SwiftUI native, biasanya dismiss pakai @Environment(\.dismiss)
    }
}

