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
    private let repository: TaskRepositoryProtocol
    
    // Tambahkan deinit untuk debugging memory leak
    deinit {
        print("TaskListInteractor deinit")
    }
    
    
    init(repository: TaskRepositoryProtocol) {
        self.repository = repository
    }

    func fetchTasks() -> AnyPublisher<[TaskEntity], Error> {
        repository.fetchAllTasks()
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }

    func deleteTask(id: UUID) -> AnyPublisher<Void, Error> {
            repository.fetchTask(by: id)
                .compactMap { $0 }
                .handleEvents(receiveOutput: { task in
                    self.repository.deleteTask(task)
                })
                .map { _ in () }
                .mapError { $0 as Error }
                .eraseToAnyPublisher()
        }

    func setTaskAsPriority(id: UUID) -> AnyPublisher<Void, Error> {
        repository.fetchTask(by: id)
            .compactMap { $0 }
            .flatMap { selectedTask in
                self.repository.fetchAllTasks()
                    .map { $0.filter { $0.isPriority } }
                    .flatMap { priorityTasks -> AnyPublisher<Void, Never> in
                        let resetAll = priorityTasks.map { task in
                            var updated = task
                            updated.isPriority = false
                            self.repository.saveTask(updated)
                            return Just(()).eraseToAnyPublisher()
                        }
                        return resetAll.isEmpty
                        ? Just(()).eraseToAnyPublisher()
                        : Publishers.MergeMany(resetAll).collect().map { _ in () }.eraseToAnyPublisher()
                    }
                    .handleEvents(receiveOutput: {
                        var updated = selectedTask
                        updated.isPriority = true
                        self.repository.saveTask(updated)
                    })
            }
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
    
}
