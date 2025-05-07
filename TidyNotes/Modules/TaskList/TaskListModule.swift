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
        let repository = InMemoryTaskRepository.shared
        let interactor = TaskListInteractor(repository: repository)
        let router = TaskListRouter(navigationState: navigationState)
        let presenter = TaskListPresenter(interactor: interactor, router: router)
        return TaskListContainerView(presenter: presenter, navigationState: navigationState)
    }
    
    static func makeTaskListView(navigationController: UINavigationController) -> UIViewController {
        let repository = InMemoryTaskRepository.shared
        let interactor = TaskListInteractor(repository: repository)
        let router = TaskListRouter(navigationController: navigationController)
        let presenter = TaskListPresenter(interactor: interactor, router: router)
        let taskListView = TaskListView(presenter: presenter)
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
