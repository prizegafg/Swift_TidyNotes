//
//  TaskListPresenter.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 29/04/25.
//

import Foundation
import SwiftUI
import Combine

final class TaskListIntent: ObservableObject {
    // Published ke View
    @Published var tasks: [Task] = []
//    @Published var errorMessage: String?
    @Published var errorMessage: ErrorMessage?
    
    
    
    let interactor: TaskListInteractorProtocol

    init(interactor: TaskListInteractorProtocol) {
        self.interactor = interactor
        (interactor as? TaskListInteractor)?.setPresenter(self)
    }

    func onAppear(projectId: UUID?) {
        interactor.fetchTasks(for: projectId)
    }

    func toggleCompletion(_ task: Task) {
        interactor.toggleTaskCompletion(task)
    }

    func delete(_ task: Task) {
        interactor.deleteTask(task)
    }

    func addTask(title: String, projectId: UUID?) {
        interactor.addTask(title: title, to: projectId)
    }
}

extension TaskListIntent: TaskListPresenterProtocol {
    func presentTasks(_ tasks: [Task]) {
        DispatchQueue.main.async {
            self.tasks = tasks
        }
    }

    func presentError(_ message: String) {
//        DispatchQueue.main.async {
//            self.errorMessage = message
//        }
        DispatchQueue.main.async {
            self.errorMessage = ErrorMessage(message: message)
        }
    }
}
