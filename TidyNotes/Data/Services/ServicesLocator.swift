//
//  ServicesLocator.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 08/05/25.
//

import Foundation

/// Service Locator pattern untuk mengakses repository
final class ServiceLocator {
    static let shared = ServiceLocator()
    
    private init() {
        // Default menggunakan Core Data repository
        registerTaskRepository(CoreDataTaskRepository())
        registerProjectRepository(CoreDataProjectRepository())
    }
    
    private var _taskRepository: TaskRepository = CoreDataTaskRepository()
    private var _projectRepository: ProjectRepository = CoreDataProjectRepository()
    
    var taskRepository: TaskRepository {
        return _taskRepository
    }
    
    var projectRepository: ProjectRepository {
        return _projectRepository
    }
    
    func registerTaskRepository(_ repository: TaskRepository) {
        _taskRepository = repository
    }
    
    func registerProjectRepository(_ repository: ProjectRepository) {
        _projectRepository = repository
    }
}

// TidyNotes/Application/AppSetup.swift

import Foundation
import UIKit

/// Class untuk setup aplikasi
final class AppSetup {
    static let shared = AppSetup()
    
    private init() {}
    
    /// Setup aplikasi saat pertama kali launch
    func setupApplication() {
        // Inisialisasi Core Data
        _ = CoreDataStack.shared
        
        // Migrasi data jika perlu
        migrateDataIfNeeded()
        
        // Setup repositori
        setupRepositories()
    }
    
    private func migrateDataIfNeeded() {
        let userDefaults = UserDefaults.standard
        let migrationKey = "hasCompletedCoreDataMigration"
        
        if !userDefaults.bool(forKey: migrationKey) {
//            DataMigrationManager.shared.migrateData {
//                UserDefaults.standard.set(true, forKey: migrationKey)
//                print("✅ Data migration completed")
//            }
        }
    }
    
    private func setupRepositories() {
        // Daftarkan repository ke service locator
        ServiceLocator.shared.registerTaskRepository(CoreDataTaskRepository())
        ServiceLocator.shared.registerProjectRepository(CoreDataProjectRepository())
    }
}

