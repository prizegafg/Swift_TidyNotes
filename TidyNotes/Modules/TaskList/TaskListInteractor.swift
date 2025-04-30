//
//  TaskListInteractor.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 29/04/25.
//

import Foundation
import Combine

/// Protocol untuk interactor dari TaskList
protocol TaskListInteractorProtocol {
    /// Mengambil daftar task dari repository
    func fetchTasks() -> AnyPublisher<[TaskEntity], TaskError>
    
    /// Menandai task sebagai selesai/belum selesai
    func toggleTaskCompletion(task: TaskEntity) -> AnyPublisher<TaskEntity, TaskError>
    
    /// Menambahkan task baru
    func addTask(_ task: TaskEntity) -> AnyPublisher<TaskEntity, TaskError>
    
    /// Menghapus task
    func deleteTask(id: UUID) -> AnyPublisher<Void, TaskError>
}

/// Implementasi dari TaskListInteractor
final class TaskListInteractor: TaskListInteractorProtocol {
    private let repository: TaskRepository
    private var cancellables = Set<AnyCancellable>()
    
    /// Initializer dengan dependency injection
    init(repository: TaskRepository = InMemoryTaskRepository.shared) {
        self.repository = repository
    }
    
    func fetchTasks() -> AnyPublisher<[TaskEntity], TaskError> {
        return repository.fetchTasks()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func toggleTaskCompletion(task: TaskEntity) -> AnyPublisher<TaskEntity, TaskError> {
        var updatedTask = task
        updatedTask.isCompleted.toggle()
        
        return repository.updateTask(updatedTask)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func addTask(_ task: TaskEntity) -> AnyPublisher<TaskEntity, TaskError> {
        return repository.addTask(task)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func deleteTask(id: UUID) -> AnyPublisher<Void, TaskError> {
        return repository.deleteTask(id: id)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
