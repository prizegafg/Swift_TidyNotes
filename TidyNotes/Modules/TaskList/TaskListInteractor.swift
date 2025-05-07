//
//  TaskListInteractor.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 29/04/25.
//

// File: TaskListInteractor.swift
import Foundation
import Combine

final class TaskListInteractor {
    private let repository: TaskRepository

    init(repository: TaskRepository = InMemoryTaskRepository.shared) {
        self.repository = repository
    }

    func fetchTasks() -> AnyPublisher<[TaskEntity], Error> {
        repository.fetchTasks()
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }

    func deleteTask(id: UUID) -> AnyPublisher<Void, Error> {
        repository.deleteTask(id: id)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }

    func setTaskAsPriority(id: UUID) -> AnyPublisher<Void, Error> {
        repository.fetchTaskById(id)
            .flatMap { selectedTask in
                self.repository.fetchTasks()
                    .map { $0.filter { $0.isPriority } }
                    .flatMap { priorityTasks -> AnyPublisher<Void, TaskError> in
                        let resetAll = priorityTasks.map { task in
                            var updated = task
                            updated.isPriority = false
                            return self.repository.updateTask(updated).map { _ in () }
                        }
                        return resetAll.isEmpty
                            ? Just(()).setFailureType(to: TaskError.self).eraseToAnyPublisher()
                            : Publishers.MergeMany(resetAll).collect().map { _ in () }.eraseToAnyPublisher()
                    }
                    .flatMap {
                        var updated = selectedTask
                        updated.isPriority = true
                        return self.repository.updateTask(updated).map { _ in () }
                    }
            }
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}
