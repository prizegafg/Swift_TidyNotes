//
//  InMemoryTaskRepository.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 29/04/25.
//

import Foundation
import Combine

final class InMemoryTaskRepository: TaskRepositoryProtocol {

    private var tasks: [Task] = [
        Task(id: UUID(), title: "Belajar SwiftUI", isCompleted: false, projectId: nil, createdAt: Date(), updatedAt: Date()),
        Task(id: UUID(), title: "Kerjakan UI Notion", isCompleted: true, projectId: nil, createdAt: Date(), updatedAt: Date())
    ]

    func getTasks(projectId: UUID?) -> AnyPublisher<[Task], Error> {
        let result = projectId == nil
            ? tasks
            : tasks.filter { $0.projectId == projectId }

        return Just(result)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func addTask(_ task: Task) -> AnyPublisher<Void, Error> {
        tasks.append(task)
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func updateTask(_ task: Task) -> AnyPublisher<Void, Error> {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        }
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func deleteTask(_ task: Task) -> AnyPublisher<Void, Error> {
        tasks.removeAll { $0.id == task.id }
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

