//
//  TaskListRouter.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 29/04/25.
//

import Foundation
import SwiftUI
import Combine

final class TaskListRouter {
    private weak var navigationController: UINavigationController?
    private weak var navigationState: TaskNavigationState?
    deinit { print("TaskListRouter deinit") }

    init(navigationController: UINavigationController? = nil, navigationState: TaskNavigationState? = nil) {
        self.navigationController = navigationController
        self.navigationState = navigationState
    }
    func navigateToAddTask(userId: String, onTasksUpdated: (() -> Void)? = nil) {
        navigationState?.showAddTask = true
    }
    func navigateToEditTask(task: TaskEntity, onTasksUpdated: (() -> Void)? = nil) {
        navigationState?.selectedTaskForEdit = task
        navigationState?.onTasksUpdatedForEdit = onTasksUpdated
        navigationState?.showEditTask = true
    }
    func navigateToTaskDetail(_ taskId: UUID) {
        navigationState?.showTaskDetail = true
    }
}

class TaskNavigationState: ObservableObject {
    @Published var showAddTask: Bool = false
    @Published var showEditTask: Bool = false
    @Published var showTaskDetail: Bool = false
    @Published var onTasksUpdatedForEdit: (() -> Void)? = nil
    @Published var selectedTaskForEdit: TaskEntity?
    deinit { print("TaskNavigationState deinit") }
}
