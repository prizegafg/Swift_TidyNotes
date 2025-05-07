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

    func updateTaskNoteContent(task: TaskEntity, content: String) -> AnyPublisher<TaskEntity, Error> {
        var updatedTask = task
        updatedTask.description = content // misalnya kamu pakai 'description' sebagai catatan
        return taskRepository.updateTask(updatedTask)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}

