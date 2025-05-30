//
//  TaskDetailInteractor.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 04/05/25.
//

import Foundation
import Combine

final class TaskDetailInteractor {
    private let repository: TaskRepository
    
    deinit {
        print("TaskDetailInteractor deinit")
    }
    
    init(repository: TaskRepositoryProtocol = ServiceLocator.shared.taskRepository) {
        self.repository = repository as! TaskRepository
    }
    
    func fetchTask(by id: UUID) -> AnyPublisher<TaskEntity?, Error> {
        repository.fetchTask(by: id)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
    
    func updateTask(_ task: TaskEntity) -> AnyPublisher<Void, Error> {
        Just(task)
            .handleEvents(receiveOutput: { self.repository.saveTask($0) })
            .map { _ in () }
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func createTask(title: String,
                    description: String,
                    isPriority: Bool,
                    dueDate: Date?,
                    isReminderON: Bool,
                    reminderDate: Date?,
                    imagePath: String,
                    status: TaskStatus) -> AnyPublisher<TaskEntity, Error> {
        let currentUserId = SessionManager.shared.currentUser?.id ?? "unknown"
        let newTask = TaskEntity(
            id: UUID(),
            userId: currentUserId,
            title: title,
            description: description,
            isPriority: isPriority,
            createdAt: Date(),
            dueDate: dueDate,
            isReminderOn: isReminderON,
            reminderDate: reminderDate,
            status: status
        )

        return Just(newTask)
            .handleEvents(receiveOutput: { self.repository.saveTask($0) })
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

