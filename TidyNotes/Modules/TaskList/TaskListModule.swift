//
//  TaskListModule.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 08/05/25.
//

import SwiftUI
import UIKit

enum TaskListModule {
    static func makeTaskListView() -> some View {
        let navigationState = TaskNavigationState()
        let repository = ServiceLocator.shared.taskRepository
        let interactor = TaskListInteractor(repository: repository)
        let router = TaskListRouter(navigationState: navigationState)
        let userId = SessionManager.shared.currentUser?.id ?? ""
        let presenter = TaskListPresenter(interactor: interactor, router: router, userId: userId)
        return TaskListContainerView(presenter: presenter, navigationState: navigationState)
    }
    
    static func makeTaskListView(navigationController: UINavigationController) -> UIViewController {
        let navigationState = TaskNavigationState()
        let repository = ServiceLocator.shared.taskRepository
        let interactor = TaskListInteractor(repository: repository)
        let router = TaskListRouter(navigationController: navigationController)
        let userId = SessionManager.shared.currentUser?.id ?? ""
        let presenter = TaskListPresenter(interactor: interactor, router: router, userId: userId)
        let taskListView = TaskListView(presenter: presenter, navigationState: navigationState)
        return UIHostingController(rootView: taskListView)
    }
}

enum TaskAddEditModule {
    static func makeEditTaskView(task: TaskEntity) -> some View {
        VStack {
            Text("Edit Task: \(task.title)")
            Text("Description: \(task.description)")
            Text("Status: \(task.status.rawValue)")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Edit Task")
    }
}
