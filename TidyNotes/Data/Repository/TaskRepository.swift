//
//  TaskRepository.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 05/05/25.
//

import Foundation
import Combine


protocol TaskRepository {
    func fetchTasks() -> AnyPublisher<[TaskEntity], TaskError>
    func fetchTaskById(_ id: UUID) -> AnyPublisher<TaskEntity, TaskError>
    func addTask(_ task: TaskEntity) -> AnyPublisher<TaskEntity, TaskError>
    func updateTask(_ task: TaskEntity) -> AnyPublisher<TaskEntity, TaskError>
    func deleteTask(id: UUID) -> AnyPublisher<Void, TaskError>
}

// MARK: - In-Memory Repository Implementation
/// Implementasi repository task yang menyimpan data di memory

/// Implementasi repository task yang menyimpan data di memory
final class InMemoryTaskRepository: TaskRepository {
    static let shared = InMemoryTaskRepository()
    
    private var tasks: [TaskEntity] = []
    private let tasksSubject = CurrentValueSubject<[TaskEntity], TaskError>([])
    
    private init() {
        // Inisialisasi dengan beberapa task dummy
        let defaultTask = TaskEntity(
            id: UUID(),
            title: "Task Default",
            description: "Ini adalah task default",
            isPriority: true,
            createdAt: Date(),
            dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()),
            status: .todo
        )
        
        tasks = [defaultTask]
        tasksSubject.send(tasks)
    }
    
    func fetchTasks() -> AnyPublisher<[TaskEntity], TaskError> {
        return tasksSubject
            .eraseToAnyPublisher()
    }
    
    func fetchTaskById(_ id: UUID) -> AnyPublisher<TaskEntity, TaskError> {
        guard let task = tasks.first(where: { $0.id == id }) else {
            return Fail(error: TaskError.taskNotFound)
                .eraseToAnyPublisher()
        }
        
        return Just(task)
            .setFailureType(to: TaskError.self)
            .eraseToAnyPublisher()
    }
    
    func addTask(_ task: TaskEntity) -> AnyPublisher<TaskEntity, TaskError> {
        tasks.append(task)
        tasksSubject.send(tasks)
        
        return Just(task)
            .setFailureType(to: TaskError.self)
            .eraseToAnyPublisher()
    }
    
    func updateTask(_ task: TaskEntity) -> AnyPublisher<TaskEntity, TaskError> {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            tasksSubject.send(tasks)
            
            return Just(task)
                .setFailureType(to: TaskError.self)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: TaskError.taskNotFound)
                .eraseToAnyPublisher()
        }
    }
    
    func deleteTask(id: UUID) -> AnyPublisher<Void, TaskError> {
        if let index = tasks.firstIndex(where: { $0.id == id }) {
            tasks.remove(at: index)
            tasksSubject.send(tasks)
            
            return Just(())
                .setFailureType(to: TaskError.self)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: TaskError.taskNotFound)
                .eraseToAnyPublisher()
        }
    }
}
