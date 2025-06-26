//
//  TaskListInteractor.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 29/04/25.
//

import Foundation
import Combine

final class TaskListInteractor {
    private let repository: TaskRepositoryProtocol

    init(repository: TaskRepositoryProtocol = ServiceLocator.shared.taskRepository) {
        self.repository = repository
    }

    func fetchAllTasks(for userId: String) -> AnyPublisher<[TaskEntity], Error> {
        repository.fetchTasks(userId: userId)
    }

    func deleteTask(_ id: UUID) -> AnyPublisher<Void, Error> {
        repository.deleteTask(id)
    }

    func saveTask(_ task: TaskEntity) -> AnyPublisher<Void, Error> {
        repository.saveTask(task)
    }

    func setTaskAsPriority(_ task: TaskEntity) -> AnyPublisher<Void, Error> {
        var newTask = task
        newTask.isPriority = true
        return repository.saveTask(newTask)
    }
}
