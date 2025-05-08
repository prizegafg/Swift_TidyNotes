//
//  DataMigrator.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 08/05/25.
//

import Foundation
import Combine
import CoreData

// Class untuk melakukan migrasi data dari InMemory ke CoreData jika diperlukan
class DataMigrator {
    static let shared = DataMigrator()
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    // Cek apakah ini adalah pertama kali aplikasi dijalankan setelah update
    func needsMigration() -> Bool {
        // Cek dari UserDefaults apakah migrasi sudah dilakukan
        return !UserDefaults.standard.bool(forKey: "coredataMigrationCompleted")
    }
    
    // Migrasi data dari InMemory repository ke CoreData
    func migrateIfNeeded() {
        if needsMigration() {
            migrateData()
        }
    }
    
    private func migrateData() {
        // Jika ada data in-memory yang perlu dimigrasi, lakukan disini
        // Dalam kasus ini, tidak benar-benar perlu karena data default
        // sudah dibuat di repository CoreData
        
        UserDefaults.standard.set(true, forKey: "coredataMigrationCompleted")
    }
    
    // Jika perlu migrasi secara manual
    func forceDataMigration() {
        migrateProjects()
        migrateTasks()
    }
    
    private func migrateProjects() {
        // Buat instance InMemoryProjectRepository dan CoreDataProjectRepository
        let inMemoryRepo = InMemoryProjectRepository.shared
        let coreDataRepo = CoreDataProjectRepository.shared
        
        inMemoryRepo.fetchProjects()
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    print("Failed to fetch projects from in-memory repository")
                }
            }, receiveValue: { projects in
                for project in projects {
                    // Skip jika default project karena sudah dibuat oleh CoreData repo
                    if !project.isDefault {
                        coreDataRepo.addProject(project)
                            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
                            .store(in: &self.cancellables)
                    }
                }
            })
            .store(in: &cancellables)
    }
    
    private func migrateTasks() {
        // Buat instance InMemoryTaskRepository dan CoreDataTaskRepository
        let inMemoryRepo = InMemoryTaskRepository.shared
        let coreDataRepo = CoreDataTaskRepository.shared
        
        inMemoryRepo.fetchTasks()
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    print("Failed to fetch tasks from in-memory repository")
                }
            }, receiveValue: { tasks in
                for task in tasks {
                    coreDataRepo.addTask(task)
                        .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
                        .store(in: &self.cancellables)
                }
            })
            .store(in: &cancellables)
    }
}
