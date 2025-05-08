//
//  CoreDataTaskRepository.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 08/05/25.
//

import Foundation
import CoreData
import Combine


/// CoreData implementation of TaskRepository
final class CoreDataTaskRepository: TaskRepository {
    
    private let coreDataStack: CoreDataStack
    static let shared = CoreDataTaskRepository()
    
    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
    }
    
    func fetchTasks() -> AnyPublisher<[TaskEntity], TaskError> {
        return Future<[TaskEntity], TaskError> { [weak self] promise in
            guard let self = self else {
                promise(.failure(.unknown))
                return
            }
            
            self.coreDataStack.performBackgroundTask { context in
                let fetchRequest: NSFetchRequest<CDTask> = CDTask.fetchRequest()
                fetchRequest.sortDescriptors = [
                    NSSortDescriptor(keyPath: \CDTask.createdAt, ascending: false)
                ]
                
                do {
                    let cdTasks = try context.fetch(fetchRequest)
                    let tasks = cdTasks.compactMap { self.mapToTaskEntity($0) }
                    promise(.success(tasks))
                } catch {
                    print("❌ Error fetching tasks: \(error)")
                    promise(.failure(.networkError(error.localizedDescription)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchTaskById(_ id: UUID) -> AnyPublisher<TaskEntity, TaskError> {
        return Future<TaskEntity, TaskError> { [weak self] promise in
            guard let self = self else {
                promise(.failure(.unknown))
                return
            }
            
            self.coreDataStack.performBackgroundTask { context in
                let fetchRequest: NSFetchRequest<CDTask> = CDTask.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
                fetchRequest.fetchLimit = 1
                
                do {
                    let results = try context.fetch(fetchRequest)
                    
                    if let cdTask = results.first, let task = self.mapToTaskEntity(cdTask) {
                        promise(.success(task))
                    } else {
                        promise(.failure(.taskNotFound))
                    }
                } catch {
                    print("❌ Error fetching task by ID: \(error)")
                    promise(.failure(.networkError(error.localizedDescription)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func addTask(_ task: TaskEntity) -> AnyPublisher<TaskEntity, TaskError> {
        return Future<TaskEntity, TaskError> { [weak self] promise in
            guard let self = self else {
                promise(.failure(.unknown))
                return
            }
            
            self.coreDataStack.performBackgroundTask { context in
                let cdTask = CDTask(context: context)
                self.updateCDTask(cdTask, with: task)
                
                do {
                    try context.save()
                    promise(.success(task))
                } catch {
                    print("❌ Error adding task: \(error)")
                    promise(.failure(.saveFailed))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func updateTask(_ task: TaskEntity) -> AnyPublisher<TaskEntity, TaskError> {
        return Future<TaskEntity, TaskError> { [weak self] promise in
            guard let self = self else {
                promise(.failure(.unknown))
                return
            }
            
            self.coreDataStack.performBackgroundTask { context in
                let fetchRequest: NSFetchRequest<CDTask> = CDTask.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %@", task.id as CVarArg)
                fetchRequest.fetchLimit = 1
                
                do {
                    let results = try context.fetch(fetchRequest)
                    
                    if let cdTask = results.first {
                        self.updateCDTask(cdTask, with: task)
                        try context.save()
                        promise(.success(task))
                    } else {
                        promise(.failure(.taskNotFound))
                    }
                } catch {
                    print("❌ Error updating task: \(error)")
                    promise(.failure(.saveFailed))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func deleteTask(id: UUID) -> AnyPublisher<Void, TaskError> {
        return Future<Void, TaskError> { [weak self] promise in
            guard let self = self else {
                promise(.failure(.unknown))
                return
            }
            
            self.coreDataStack.performBackgroundTask { context in
                let fetchRequest: NSFetchRequest<CDTask> = CDTask.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
                fetchRequest.fetchLimit = 1
                
                do {
                    let results = try context.fetch(fetchRequest)
                    
                    if let cdTask = results.first {
                        context.delete(cdTask)
                        try context.save()
                        promise(.success(()))
                    } else {
                        promise(.failure(.taskNotFound))
                    }
                } catch {
                    print("❌ Error deleting task: \(error)")
                    promise(.failure(.deleteFailed))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Helper Methods
    
    private func updateCDTask(_ cdTask: CDTask, with task: TaskEntity) {
        cdTask.id = task.id
        cdTask.title = task.title
        cdTask.taskDescription = task.description
        cdTask.isPriority = task.isPriority
        cdTask.createdAt = task.createdAt
        cdTask.dueDate = task.dueDate
        cdTask.status = task.status.rawValue
    }
    
    private func mapToTaskEntity(_ cdTask: CDTask) -> TaskEntity? {
        guard let id = cdTask.id,
              let title = cdTask.title,
              let description = cdTask.taskDescription,
              let createdAt = cdTask.createdAt,
              let statusString = cdTask.status else {
            return nil
        }
        
        let status = TaskStatus(rawValue: statusString) ?? .todo
        
        return TaskEntity(
            id: id,
            title: title,
            description: description,
            isPriority: cdTask.isPriority,
            createdAt: createdAt,
            dueDate: cdTask.dueDate,
            status: status
        )
    }
}
