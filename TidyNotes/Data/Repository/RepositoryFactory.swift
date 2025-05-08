//
//  RepositoryFactory.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 08/05/25.
//

import Foundation

/// Repository type for choosing between in-memory or persistent storage
enum RepositoryType {
    case inMemory
    case coreData
}

/// Factory for creating repositories
final class RepositoryFactory {
    
    /// Shared instance for repository factory
    static let shared = RepositoryFactory()
    
    /// Current repository type
    private(set) var currentType: RepositoryType = .coreData
    
    /// Create task repository based on current type
    func makeTaskRepository() -> TaskRepository {
        switch currentType {
        case .inMemory:
            return InMemoryTaskRepository.shared
        case .coreData:
            return CoreDataTaskRepository()
        }
    }
    
    /// Create project repository based on current type
    func makeProjectRepository() -> ProjectRepository {
        switch currentType {
        case .inMemory:
            return InMemoryProjectRepository.shared
        case .coreData:
            return CoreDataProjectRepository()
        }
    }
    
    /// Set repository type
    func setRepositoryType(_ type: RepositoryType) {
        self.currentType = type
        print("🔄 Repository type changed to: \(type)")
    }
    
    private init() {
        // Private initializer to enforce singleton pattern
        #if DEBUG
        // Use in-memory repositories for previews and testing
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            self.currentType = .inMemory
        }
        #endif
    }
}
