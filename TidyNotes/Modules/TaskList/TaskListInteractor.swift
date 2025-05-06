//
//  TaskListInteractor.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 29/04/25.
//

// File: TaskListInteractor.swift
import Foundation
import Combine

/// Protocol Interactor untuk Task dalam arsitektur VIPER
protocol TaskListInteractorProtocol {
    func fetchAllTasks(completion: @escaping (Result<[TaskEntity], Error>) -> Void)
    func deleteTask(id: UUID, completion: @escaping (Result<Void, Error>) -> Void)
    func setTaskAsPriority(id: UUID, completion: @escaping (Result<Void, Error>) -> Void)
    
    // Tambahan method dengan Combine
    func fetchTasks() -> AnyPublisher<[TaskEntity], TaskError>
    func toggleTaskCompletion(task: TaskEntity) -> AnyPublisher<TaskEntity, TaskError>
    func addTask(_ task: TaskEntity) -> AnyPublisher<TaskEntity, TaskError>
    func deleteTask(id: UUID) -> AnyPublisher<Void, TaskError>
}

/// Implementasi Interactor untuk TaskList
final class TaskListInteractor: TaskListInteractorProtocol {
    private let repository: TaskRepository
    private var cancellables = Set<AnyCancellable>()
    
    /// Initializer dengan dependency injection
    init(repository: TaskRepository = InMemoryTaskRepository.shared) {
        self.repository = repository
    }
    
    // MARK: - Combine Based Methods
    
    func fetchTasks() -> AnyPublisher<[TaskEntity], TaskError> {
        return repository.fetchTasks()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func toggleTaskCompletion(task: TaskEntity) -> AnyPublisher<TaskEntity, TaskError> {
        var updatedTask = task
        updatedTask.status = updatedTask.status == .done ? .todo : .done
        
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
    
    // MARK: - Callback Based Methods
    
    func fetchAllTasks(completion: @escaping (Result<[TaskEntity], Error>) -> Void) {
        fetchTasks()
            .sink(
                receiveCompletion: { result in
                    if case .failure(let error) = result {
                        completion(.failure(error))
                    }
                },
                receiveValue: { tasks in
                    completion(.success(tasks))
                }
            )
            .store(in: &cancellables)
    }
    
    func deleteTask(id: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        deleteTask(id: id)
            .sink(
                receiveCompletion: { result in
                    switch result {
                    case .finished:
                        completion(.success(()))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }
    
    func setTaskAsPriority(id: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        repository.fetchTaskById(id)
            .flatMap { task -> AnyPublisher<[TaskEntity], TaskError> in
                // Dulu ambil semua task yang priority
                return self.repository.fetchTasks()
                    .map { tasks in
                        tasks.filter { $0.isPriority }
                    }
                    .eraseToAnyPublisher()
            }
            .flatMap { priorityTasks -> AnyPublisher<Void, TaskError> in
                // Reset semua task priority
                let resetPublishers = priorityTasks.map { task in
                    var updatedTask = task
                    updatedTask.isPriority = false
                    return self.repository.updateTask(updatedTask)
                        .map { _ in () }
                        .eraseToAnyPublisher()
                }
                
                if resetPublishers.isEmpty {
                    return Just(())
                        .setFailureType(to: TaskError.self)
                        .eraseToAnyPublisher()
                }
                
                return Publishers.MergeMany(resetPublishers)
                    .collect()
                    .map { _ in () }
                    .eraseToAnyPublisher()
            }
            .flatMap { _ -> AnyPublisher<TaskEntity, TaskError> in
                // Set task yang dipilih sebagai priority
                return self.repository.fetchTaskById(id)
                    .flatMap { task -> AnyPublisher<TaskEntity, TaskError> in
                        var updatedTask = task
                        updatedTask.isPriority = true
                        return self.repository.updateTask(updatedTask)
                    }
                    .eraseToAnyPublisher()
            }
            .sink(
                receiveCompletion: { result in
                    switch result {
                    case .finished:
                        completion(.success(()))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }
}
