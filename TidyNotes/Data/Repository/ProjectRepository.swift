//
//  ProjectRepository.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 05/05/25.
//

import Foundation
import Combine

/// Protocol untuk repository project
protocol ProjectRepository {
    /// Mengambil daftar project
    func fetchProjects() -> AnyPublisher<[ProjectEntity], ProjectError>
    
    /// Menambah project baru
    func addProject(_ project: ProjectEntity) -> AnyPublisher<ProjectEntity, ProjectError>
    
    /// Mengupdate project yang sudah ada
    func updateProject(_ project: ProjectEntity) -> AnyPublisher<ProjectEntity, ProjectError>
    
    /// Menghapus project berdasarkan ID
    func deleteProject(id: UUID) -> AnyPublisher<Void, ProjectError>
    
    /// Mendapatkan project default
    func getDefaultProject() -> AnyPublisher<ProjectEntity, ProjectError>
}

/// Implementasi in-memory dari ProjectRepository
final class InMemoryProjectRepository: ProjectRepository {
    /// Shared instance untuk singleton pattern
    static let shared = InMemoryProjectRepository()
    
    /// Storage untuk menyimpan projects
    private var projects: [ProjectEntity]
    
    private init() {
        // Inisialisasi dengan default project
        projects = [
            ProjectEntity(
                name: "Personal",
                color: "blue",
                icon: "person",
                isDefault: true
            ),
            ProjectEntity(
                name: "Work",
                color: "red",
                icon: "briefcase"
            ),
            ProjectEntity(
                name: "Shopping",
                color: "green",
                icon: "cart"
            )
        ]
    }
    
    func fetchProjects() -> AnyPublisher<[ProjectEntity], ProjectError> {
        return Future<[ProjectEntity], ProjectError> { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
                promise(.success(self.projects))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func addProject(_ project: ProjectEntity) -> AnyPublisher<ProjectEntity, ProjectError> {
        return Future<ProjectEntity, ProjectError> { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
                var newProject = project
                
                // Pastikan hanya ada satu project default
                if newProject.isDefault {
                    for i in 0..<self.projects.count {
                        if self.projects[i].isDefault {
                            self.projects[i].isDefault = false
                        }
                    }
                }
                
                self.projects.append(newProject)
                promise(.success(newProject))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func updateProject(_ project: ProjectEntity) -> AnyPublisher<ProjectEntity, ProjectError> {
        return Future<ProjectEntity, ProjectError> { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
                if let index = self.projects.firstIndex(where: { $0.id == project.id }) {
                    var updatedProject = project
                    
                    // Pastikan hanya ada satu project default
                    if updatedProject.isDefault {
                        for i in 0..<self.projects.count {
                            if self.projects[i].id != project.id && self.projects[i].isDefault {
                                self.projects[i].isDefault = false
                            }
                        }
                    } else {
                        // Pastikan setidaknya satu project tetap default
                        if self.projects[index].isDefault {
                            let hasAnotherDefault = self.projects.contains(where: {
                                $0.id != project.id && $0.isDefault
                            })
                            
                            if !hasAnotherDefault {
                                updatedProject.isDefault = true
                            }
                        }
                    }
                    
                    self.projects[index] = updatedProject
                    promise(.success(updatedProject))
                } else {
                    promise(.failure(.notFound))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func deleteProject(id: UUID) -> AnyPublisher<Void, ProjectError> {
        return Future<Void, ProjectError> { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
                if let index = self.projects.firstIndex(where: { $0.id == id }) {
                    // Tidak boleh menghapus project default
                    if self.projects[index].isDefault {
                        promise(.failure(.cannotDeleteDefault))
                        return
                    }
                    
                    self.projects.remove(at: index)
                    promise(.success(()))
                } else {
                    promise(.failure(.notFound))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getDefaultProject() -> AnyPublisher<ProjectEntity, ProjectError> {
        return Future<ProjectEntity, ProjectError> { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
                if let defaultProject = self.projects.first(where: { $0.isDefault }) {
                    promise(.success(defaultProject))
                } else if let firstProject = self.projects.first {
                    // Jika tidak ada project default, jadikan project pertama sebagai default
                    var updatedProject = firstProject
                    updatedProject.isDefault = true
                    
                    if let index = self.projects.firstIndex(where: { $0.id == firstProject.id }) {
                        self.projects[index] = updatedProject
                    }
                    
                    promise(.success(updatedProject))
                } else {
                    // Jika tidak ada project sama sekali, buat project default baru
                    let defaultProject = ProjectEntity(
                        name: "Personal",
                        color: "blue",
                        icon: "person",
                        isDefault: true
                    )
                    
                    self.projects.append(defaultProject)
                    promise(.success(defaultProject))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
