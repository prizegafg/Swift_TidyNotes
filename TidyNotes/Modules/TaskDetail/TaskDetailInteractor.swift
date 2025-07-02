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
                TaskSyncService.shared.syncTasksToFirestore(for: task.userId)
            })
            .eraseToAnyPublisher()
    }
}

