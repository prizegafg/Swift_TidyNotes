//
//  TaskProjectRelationManager.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 08/05/25.
//

import Foundation
import CoreData
import Combine

/// Manager for handling relationships between tasks and projects
final class TaskProjectRelationManager {
    
    private let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
    }
    
    /// Associate a task with a project
    func assignTaskToProject(taskId: UUID, projectId: UUID) -> AnyPublisher<Void, TaskError> {
        return Future<Void, TaskError> { [weak self] promise in
            guard let self = self else {
                promise(.failure(.unknown))
                return
            }
            
            self.coreDataStack.performBackgroundTask { context in
                do {
                    // Fetch task
                    let taskFetchRequest: NSFetchRequest<CDTask> = CDTask.fetchRequest()
                    taskFetchRequest.predicate = NSPredicate(format: "id == %@", taskId as CVarArg)
                    
                    // Fetch project
                    let projectFetchRequest: NSFetchRequest<CDProject> = CDProject.fetchRequest()
                    projectFetchRequest.predicate = NSPredicate(format: "id == %@", projectId as CVarArg)
                    
                    let tasks = try context.fetch(taskFetchRequest)
                    let projects = try context.fetch(projectFetchRequest)
                    
                    guard let task = tasks.first else {
                        promise(.failure(.taskNotFound))
                        return
                    }
                    
                    guard let project = projects.first else {
                        promise(.failure(.networkError("Project not found")))
                        return
                    }
                    
                    // Assign project to task
                    task.project = project
                    
                    try context.save()
                    promise(.success(()))
                } catch {
                    print("❌ Error assigning task to project: \(error)")
                    promise(.failure(.saveFailed))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    /// Remove a task from its current project
    func removeTaskFromProject(taskId: UUID) -> AnyPublisher<Void, TaskError> {
        return Future<Void, TaskError> { [weak self] promise in
            guard let self = self else {
                promise(.failure(.unknown))
                return
            }
            
            self.coreDataStack.performBackgroundTask { context in
                do {
                    // Fetch task
                    let taskFetchRequest: NSFetchRequest<CDTask> = CDTask.fetchRequest()
                    taskFetchRequest.predicate = NSPredicate(format: "id == %@", taskId as CVarArg)
                    
                    let tasks = try context.fetch(taskFetchRequest)
                    
                    guard let task = tasks.first else {
                        promise(.failure(.taskNotFound))
                        return
                    }
                    
                    // Remove project association
                    task.project = nil
                    
                    try context.save()
                    promise(.success(()))
                } catch {
                    print("❌ Error removing task from project: \(error)")
                    promise(.failure(.saveFailed))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    /// Get all tasks for a specific project
    func fetchTasksForProject(projectId: UUID) -> AnyPublisher<[TaskEntity], TaskError> {
        return Future<[TaskEntity], TaskError> { [weak self] promise in
            guard let self = self else {
                promise(.failure(.unknown))
                return
            }
            
            self.coreDataStack.performBackgroundTask { context in
                do {
                    // Fetch tasks with the specified project
                    let taskFetchRequest: NSFetchRequest<CDTask> = CDTask.fetchRequest()
                    taskFetchRequest.predicate = NSPredicate(format: "project.id == %@", projectId as CVarArg)
                    taskFetchRequest.sortDescriptors = [
                        NSSortDescriptor(keyPath: \CDTask.createdAt, ascending: false)
                    ]
                    
                    let cdTasks = try context.fetch(taskFetchRequest)
                    
                    // Map CD tasks to task entities
                    let tasks = cdTasks.compactMap { cdTask -> TaskEntity? in
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
                    
                    promise(.success(tasks))
                } catch {
                    print("❌ Error fetching tasks for project: \(error)")
                    promise(.failure(.networkError(error.localizedDescription)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    /// Get project for a specific task
    func fetchProjectForTask(taskId: UUID) -> AnyPublisher<ProjectEntity?, ProjectError> {
        return Future<ProjectEntity?, ProjectError> { [weak self] promise in
            guard let self = self else {
                promise(.failure(.fetchFailed))
                return
            }
            
            self.coreDataStack.performBackgroundTask { context in
                do {
                    // Fetch task
                    let taskFetchRequest: NSFetchRequest<CDTask> = CDTask.fetchRequest()
                    taskFetchRequest.predicate = NSPredicate(format: "id == %@", taskId as CVarArg)
                    
                    let tasks = try context.fetch(taskFetchRequest)
                    
                    guard let task = tasks.first, let cdProject = task.project else {
                        // No project associated with this task
                        promise(.success(nil))
                        return
                    }
                    
                    // Map to project entity
                    guard let id = cdProject.id,
                          let name = cdProject.name,
                          let color = cdProject.color else {
                        promise(.failure(.invalidProject))
                        return
                    }
                    
                    let project = ProjectEntity(
                        id: id,
                        name: name,
                        color: color,
                        icon: cdProject.icon,
                        isDefault: cdProject.isDefault
                    )
                    
                    promise(.success(project))
                } catch {
                    print("❌ Error fetching project for task: \(error)")
                    promise(.failure(.fetchFailed))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
