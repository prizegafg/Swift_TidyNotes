//
//  TaskDetailInteractor.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 04/05/25.
//

import Foundation
import Combine

final class TaskDetailInteractor {
    private let repository: TaskRepositoryProtocol
    
    init(repository: TaskRepositoryProtocol = ServiceLocator.shared.taskRepository) {
        self.repository = repository
    }
    
    func fetchTask(by id: UUID) -> AnyPublisher<TaskEntity?, Error> {
        repository.fetchTask(by: id)
    }
    
    func saveTask(_ task: TaskEntity) -> AnyPublisher<Void, Error> {
        repository.saveTask(task)
    }
    
    func createTask(_ task: TaskEntity) -> AnyPublisher<Void, Error> {
        repository.saveTask(task)
            .handleEvents(receiveOutput: { _ in
                TaskService.shared.syncTasksToFirestore(for: task.userId)
            })
            .eraseToAnyPublisher()
    }
    
    func refreshLocalTasksFromCloud(userId: String) -> AnyPublisher<Void, Error> {
        Future { promise in
            TaskService.shared.fetchTasksFromFirestoreAndReplaceRealm(for: userId) { success in
                if success {
                    promise(.success(()))
                } else {
                    promise(.failure(AppError.databaseWriteFailed))
                }
            }
        }.eraseToAnyPublisher()
    }
}

