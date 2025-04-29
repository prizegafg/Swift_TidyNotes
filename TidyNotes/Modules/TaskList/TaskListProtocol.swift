//
//  TaskListProtocol.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 29/04/25.
//

import Foundation

protocol TaskListInteractorProtocol {
    func fetchTasks(for projectId: UUID?)
    func toggleTaskCompletion(_ task: Task)
    func deleteTask(_ task: Task)
    func addTask(title: String, to projectId: UUID?)
}

protocol TaskListPresenterProtocol: AnyObject {
    func presentTasks(_ tasks: [Task])
    func presentError(_ message: String)
}

protocol TaskListViewProtocol: AnyObject {
    func displayTasks(_ tasks: [Task])
    func showError(_ message: String)
}

protocol TaskListRouterProtocol {
    func navigateToTaskDetail(task: Task)
    func navigateToCreateTask()
}
