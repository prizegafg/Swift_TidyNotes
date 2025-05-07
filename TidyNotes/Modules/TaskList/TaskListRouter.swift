//
//  TaskListRouter.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 29/04/25.
//

import Foundation
import SwiftUI
import Combine

/// Protocol Router untuk Task dalam arsitektur VIPER
final class TaskListRouter {
    private weak var navigationController: UINavigationController?
    private var navigationState: TaskNavigationState?

    init(navigationController: UINavigationController? = nil, navigationState: TaskNavigationState? = nil) {
        self.navigationController = navigationController
        self.navigationState = navigationState
    }

    func navigateToAddTask() {
        navigationState?.showAddTask = true
    }

    func navigateToEditTask(_ task: TaskEntity) {
        navigationState?.selectedTaskForEdit = task
        navigationState?.showEditTask = true
    }
}


/// State untuk navigasi SwiftUI
class TaskNavigationState: ObservableObject {
    @Published var showAddTask: Bool = false
    @Published var showEditTask: Bool = false
    @Published var selectedTaskForEdit: TaskEntity?
}

/// Modul untuk TaskList, bertindak sebagai factory untuk TaskList Screen
enum TaskListModule {
    /// Membuat view TaskList dengan semua dependencies yang diperlukan
    static func makeTaskListView() -> some View {
        let navigationState = TaskNavigationState()
        let repository = InMemoryTaskRepository.shared
        let interactor = TaskListInteractor(repository: repository)
        let router = TaskListRouter(navigationState: navigationState)
        let presenter = TaskListPresenter(interactor: interactor, router: router)
        
        return TaskListContainerView(presenter: presenter, navigationState: navigationState)
    }
    
    /// Membuat view TaskList dengan UINavigationController untuk UIKit integration
    static func makeTaskListView(navigationController: UINavigationController) -> UIViewController {
        let repository = InMemoryTaskRepository.shared
        let interactor = TaskListInteractor(repository: repository)
        let router = TaskListRouter(navigationController: navigationController)
        let presenter = TaskListPresenter(interactor: interactor, router: router)
        
        let taskListView = TaskListView(presenter: presenter)
        return UIHostingController(rootView: taskListView)
    }
}

/// Container view yang mengelola navigasi SwiftUI
struct TaskListContainerView: View {
    @ObservedObject var presenter: TaskListPresenter
    @ObservedObject var navigationState: TaskNavigationState
    
    var body: some View {
        NavigationView {
            TaskListView(presenter: presenter)
                .sheet(isPresented: $navigationState.showAddTask) {
                    TaskAddEditModule.makeAddTaskView()
                }
                .sheet(isPresented: $navigationState.showEditTask) {
                    if let task = navigationState.selectedTaskForEdit {
                        TaskAddEditModule.makeEditTaskView(task: task)
                    }
                }
        }
    }
}

/// Placeholder modul untuk create/edit Task
enum TaskAddEditModule {
    static func makeAddTaskView() -> some View {
        Text("Add Task View")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Add Task")
    }
    
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
