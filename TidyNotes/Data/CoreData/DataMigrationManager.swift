//
//  DataMigrationManager.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 08/05/25.
//

import Foundation
import Combine

/// Manager for migrating data between repository types
final class DataMigrationManager {
    
    private var cancellables = Set<AnyCancellable>()
    private let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
    }
    
    /// Migrate data from in-memory repositories to CoreData
    func migrateFromInMemoryToCoreData(completion: @escaping (Bool) -> Void) {
        // Step 1: Get all in-memory data
        let inMemoryTaskRepo = InMemoryTaskRepository.shared
        let inMemoryProjectRepo = InMemoryProjectRepository.shared
        
        // Step 2: Create CoreData repositories
        let coreDataTaskRepo = CoreDataTaskRepository(coreDataStack: coreDataStack)
        let coreDataProjectRepo = CoreDataProjectRepository(coreDataStack: coreDataStack)
        
        // Step 3: Fetch all projects and tasks from in-memory
        inMemoryProjectRepo.fetchProjects()
            .flatMap { projects -> AnyPublisher<[ProjectEntity], ProjectError> in
                // Migrate each project to CoreData
                if projects.isEmpty {
                    return Just([]).setFailureType(to: ProjectError.self).eraseToAnyPublisher()
                }
                
                return self.migrateProjects(projects, to: coreDataProjectRepo)
                    .map { _ in projects }
                    .eraseToAnyPublisher()
            }
            .flatMap { _ in
                // Now fetch and migrate tasks
                return inMemoryTaskRepo.fetchTasks()
            }
            .flatMap { tasks -> AnyPublisher<[TaskEntity], TaskError> in
                // Migrate each task to CoreData
                if tasks.isEmpty {
                    return Just([]).setFailureType(to: TaskError.self).eraseToAnyPublisher()
                }
                
                return self.migrateTasks(tasks, to: coreDataTaskRepo)
                    .map { _ in tasks }
                    .eraseToAnyPublisher()
            }
            .sink(
                receiveCompletion: { result in
                    switch result {
                    case .finished:
                        print("✅ Migration completed successfully")
                        completion(true)
                    case .failure(let error):
                        print("❌ Migration failed: \(error)")
                        completion(false)
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }
    
    // Helper method to migrate projects in sequence
    private func migrateProjects(_ projects: [ProjectEntity], to repository: ProjectRepository) -> AnyPublisher<Void, ProjectError> {
        return projects.publisher
            .flatMap { project -> AnyPublisher<Void, ProjectError> in
                return repository.addProject(project)
                    .map { _ in () }
                    .eraseToAnyPublisher()
            }
            .collect()
            .map { _ in () }
            .eraseToAnyPublisher()
    }
    
    // Helper method to migrate tasks in sequence
    private func migrateTasks(_ tasks: [TaskEntity], to repository: TaskRepository) -> AnyPublisher<Void, TaskError> {
        return tasks.publisher
            .flatMap { task -> AnyPublisher<Void, TaskError> in
                return repository.addTask(task)
                    .map { _ in () }
                    .eraseToAnyPublisher()
            }
            .collect()
            .map { _ in () }
            .eraseToAnyPublisher()
    }
    
    /// Test if CoreData is empty
    func isCoreDataEmpty(completion: @escaping (Bool) -> Void) {
        let coreDataProjectRepo = CoreDataProjectRepository(coreDataStack: coreDataStack)
        
        coreDataProjectRepo.fetchProjects()
            .sink(
                receiveCompletion: { result in
                    if case .failure = result {
                        completion(true) // Assume empty if error
                    }
                },
                receiveValue: { projects in
                    completion(projects.isEmpty)
                }
            )
            .store(in: &cancellables)
    }
    
    /// Run initial data setup if needed
    func performInitialSetupIfNeeded(completion: @escaping () -> Void) {
        isCoreDataEmpty { isEmpty in
            if isEmpty {
                // CoreData is empty, check if we have in-memory data to migrate
                let inMemoryProjectRepo = InMemoryProjectRepository.shared
                
                inMemoryProjectRepo.fetchProjects()
                    .sink(
                        receiveCompletion: { _ in },
                        receiveValue: { projects in
                            if !projects.isEmpty {
                                // We have in-memory data, migrate it
                                self.migrateFromInMemoryToCoreData { _ in
                                    completion()
                                }
                            } else {
                                // No data anywhere, create initial data in CoreData
                                self.createInitialData {
                                    completion()
                                }
                            }
                        }
                    )
                    .store(in: &self.cancellables)
            } else {
                // CoreData already has data
                completion()
            }
        }
    }
    
    /// Create initial data in CoreData
    private func createInitialData(completion: @escaping () -> Void) {
        let coreDataProjectRepo = CoreDataProjectRepository(coreDataStack: coreDataStack)
        let coreDataTaskRepo = CoreDataTaskRepository(coreDataStack: coreDataStack)
        
        // Create default projects
        let personalProject = ProjectEntity(
            name: "Personal",
            color: "blue",
            icon: "person",
            isDefault: true
        )
        
        let workProject = ProjectEntity(
            name: "Work",
            color: "red",
            icon: "briefcase"
        )
        
        let shoppingProject = ProjectEntity(
            name: "Shopping",
            color: "green",
            icon: "cart"
        )
        
        // Create a sample task
        let sampleTask = TaskEntity(
            id: UUID(),
            title: "Task Default",
            description: "Ini adalah task default",
            isPriority: true,
            createdAt: Date(),
            dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()),
            status: .todo
        )
        
        // Add projects first
        coreDataProjectRepo.addProject(personalProject)
            .flatMap { _ in coreDataProjectRepo.addProject(workProject) }
            .flatMap { _ in coreDataProjectRepo.addProject(shoppingProject) }
            .flatMap { _ in coreDataTaskRepo.addTask(sampleTask) }
            .sink(
                receiveCompletion: { result in
                    switch result {
                    case .finished:
                        print("✅ Initial data created successfully")
                        completion()
                    case .failure(let error):
                        print("❌ Failed to create initial data: \(error)")
                        completion()
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }
}
