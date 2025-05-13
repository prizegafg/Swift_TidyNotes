//
//  ProjectRepository.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 13/05/25.
//

import Foundation
import Combine

protocol ProjectRepositoryProtocol {
    func fetchAllProjects() -> AnyPublisher<[ProjectEntity], Never>
    func fetchProject(by id: UUID) -> AnyPublisher<ProjectEntity?, Never>
    func saveProject(_ project: ProjectEntity)
    func deleteProject(_ project: ProjectEntity)
    func deleteAllProjects()
}

final class ProjectRepository: ProjectRepositoryProtocol {

    private let realmManager: RealmManager

    init(realmManager: RealmManager = .shared) {
        self.realmManager = realmManager
    }

    func fetchAllProjects() -> AnyPublisher<[ProjectEntity], Never> {
        let projects = realmManager.fetchAllProjects()
        return Just(projects)
            .eraseToAnyPublisher()
    }

    func fetchProject(by id: UUID) -> AnyPublisher<ProjectEntity?, Never> {
        let project = realmManager.fetchProject(by: id)
        return Just(project)
            .eraseToAnyPublisher()
    }

    func saveProject(_ project: ProjectEntity) {
        realmManager.addOrUpdateProject(project)
    }

    func deleteProject(_ project: ProjectEntity) {
        realmManager.deleteProject(project)
    }

    func deleteAllProjects() {
        realmManager.deleteAllProjects()
    }
}
