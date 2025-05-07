//
//  TaskDetailInteractor.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 04/05/25.
//

import Foundation
import Combine

final class TaskDetailInteractor {
    private let taskRepository: TaskRepository
    
    init(taskRepository: TaskRepository = InMemoryTaskRepository.shared) {
        self.taskRepository = taskRepository
    }
    
    func fetchTask(taskId: UUID) -> AnyPublisher<TaskEntity, Error> {
        return taskRepository.fetchTaskById(taskId)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
    
    func updateTask(task: TaskEntity) -> AnyPublisher<TaskEntity, Error> {
        return taskRepository.updateTask(task)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
    
    func createTask(title: String, description: String, isPriority: Bool, dueDate: Date?, status: TaskStatus) -> AnyPublisher<TaskEntity, Error> {
        let newTask = TaskEntity(
            id: UUID(),
            title: title,
            description: description,
            isPriority: isPriority,
            createdAt: Date(),
            dueDate: dueDate,
            status: status
        )
        
        return taskRepository.addTask(newTask)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}

