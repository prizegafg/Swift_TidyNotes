//
//  ServiceLocator.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 13/05/25.
//

import Foundation

final class ServiceLocator {
    static let shared = ServiceLocator()
    private init() {
        registerTaskRepository(TaskRepository())
        registerProjectRepository(ProjectRepository())
    }

    private var _taskRepository: TaskRepositoryProtocol = TaskRepository()
    private var _projectRepository: ProjectRepositoryProtocol = ProjectRepository()

    var taskRepository: TaskRepositoryProtocol {
        _taskRepository
    }

    var projectRepository: ProjectRepositoryProtocol {
        _projectRepository
    }

    func registerTaskRepository(_ repository: TaskRepositoryProtocol) {
        _taskRepository = repository
    }

    func registerProjectRepository(_ repository: ProjectRepositoryProtocol) {
        _projectRepository = repository
    }
}
