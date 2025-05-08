//
//  CoreDataManager.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 08/05/25.
//

import Foundation
import CoreData
import Combine

/// Central manager for Core Data operations in the app
final class CoreDataManager {
    
    /// Shared instance of CoreDataManager
    static let shared = CoreDataManager()
    
    /// Core Data stack
    private let coreDataStack = CoreDataStack.shared
    
    /// Task repository
    private(set) lazy var taskRepository: TaskRepository = CoreDataTaskRepository(coreDataStack: coreDataStack)
    
    /// Project repository
    private(set) lazy var projectRepository: ProjectRepository = CoreDataProjectRepository(coreDataStack: coreDataStack)
    
    /// Relation manager
    private(set) lazy var relationManager = TaskProjectRelationManager(coreDataStack: coreDataStack)
    
    /// Migration manager
    private(set) lazy var migrationManager = DataMigrationManager(coreDataStack: coreDataStack)
    
    /// Private initializer to enforce singleton pattern
    private init() {
        setupIfNeeded()
    }
    
    /// Setup initial data if needed
    private func setupIfNeeded() {
        migrationManager.performInitialSetupIfNeeded {
            print("✅ CoreDataManager setup completed")
        }
    }
    
    /// Reset all data in Core Data
    func resetAllData(completion: @escaping (Bool) -> Void) {
        let context = coreDataStack.viewContext
        
        // Delete all projects (which will cascade delete all tasks)
        let projectFetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "CDProject")
        let projectDeleteRequest = NSBatchDeleteRequest(fetchRequest: projectFetchRequest)
        
        // Delete all tasks
        let taskFetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "CDTask")
        let taskDeleteRequest = NSBatchDeleteRequest(fetchRequest: taskFetchRequest)
        
        do {
            try context.execute(taskDeleteRequest)
            try context.execute(projectDeleteRequest)
            try context.save()
            
            // After resetting, create initial data
            migrationManager.performInitialSetupIfNeeded {
                completion(true)
            }
        } catch {
            print("❌ Error resetting Core Data: \(error)")
            completion(false)
        }
    }
    
    /// Switch between repository types
    func switchRepositoryType(to type: RepositoryType, completion: @escaping (Bool) -> Void) {
        // If switching to CoreData from in-memory, migrate data
        if type == .coreData && RepositoryFactory.shared.currentType == .inMemory {
            migrationManager.migrateFromInMemoryToCoreData { success in
                if success {
                    RepositoryFactory.shared.setRepositoryType(type)
                }
                completion(success)
            }
        } else {
            // Just switch the type
            RepositoryFactory.shared.setRepositoryType(type)
            completion(true)
        }
    }
    
    /// Export all data as JSON
    func exportDataAsJSON() -> AnyPublisher<Data?, Error> {
        return Publishers.Zip(
            projectRepository.fetchProjects().mapError { $0 as Error },
            taskRepository.fetchTasks().mapError { $0 as Error }
        )
        .tryMap { projects, tasks -> Data in
            let exportData = ExportData(projects: projects, tasks: tasks)
            
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            
            return try encoder.encode(exportData)
        }
        .eraseToAnyPublisher()
    }
    
    /// Import data from JSON
    func importDataFromJSON(_ data: Data) -> AnyPublisher<Bool, Error> {
        return Just(data)
            .tryMap { data -> ExportData in
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return try decoder.decode(ExportData.self, from: data)
            }
            .flatMap { exportData -> AnyPublisher<Bool, Error> in
                // First reset all data
                return self.resetAllDataPublisher()
                    .flatMap { _ -> AnyPublisher<Bool, Error> in
                        // Then import projects
                        return self.importProjects(exportData.projects)
                            .flatMap { _ -> AnyPublisher<Bool, Error> in
                                // Then import tasks
                                return self.importTasks(exportData.tasks)
                            }
                    }
            }
            .eraseToAnyPublisher()
    }
    
    // Helper methods for import/export
    
    private func resetAllDataPublisher() -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { promise in
            self.resetAllData { success in
                if success {
                    promise(.success(true))
                } else {
                    promise(.failure(NSError(domain: "CoreDataManager", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Failed to reset data"])))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func importProjects(_ projects: [ProjectEntity]) -> AnyPublisher<Bool, Error> {
        let projectImports = projects.map { project in
            return projectRepository.addProject(project)
                .mapError { $0 as Error }
                .map { _ in true }
                .eraseToAnyPublisher()
        }
        
        if projectImports.isEmpty {
            return Just(true).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        
        return Publishers.MergeMany(projectImports)
            .collect()
            .map { results in results.allSatisfy { $0 } }
            .eraseToAnyPublisher()
    }
    
    private func importTasks(_ tasks: [TaskEntity]) -> AnyPublisher<Bool, Error> {
        let taskImports = tasks.map { task in
            return taskRepository.addTask(task)
                .mapError { $0 as Error }
                .map { _ in true }
                .eraseToAnyPublisher()
        }
        
        if taskImports.isEmpty {
            return Just(true).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        
        return Publishers.MergeMany(taskImports)
            .collect()
            .map { results in results.allSatisfy { $0 } }
            .eraseToAnyPublisher()
    }
}

// Data structure for export/import
struct ExportData: Codable {
    let projects: [ProjectEntity]
    let tasks: [TaskEntity]
}

