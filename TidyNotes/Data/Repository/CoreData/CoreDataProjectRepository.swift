//
//  CoreDataProjectRepository.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 08/05/25.
//

import Foundation
import CoreData
import Combine

/// CoreData implementation of ProjectRepository
final class CoreDataProjectRepository: ProjectRepository {
    
    private let coreDataStack: CoreDataStack
    static let shared = CoreDataProjectRepository()
    
    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
    }
    
    func fetchProjects() -> AnyPublisher<[ProjectEntity], ProjectError> {
        return Future<[ProjectEntity], ProjectError> { [weak self] promise in
            guard let self = self else {
                promise(.failure(.fetchFailed))
                return
            }
            
            self.coreDataStack.performBackgroundTask { context in
                let fetchRequest: NSFetchRequest<CDProject> = CDProject.fetchRequest()
                fetchRequest.sortDescriptors = [
                    NSSortDescriptor(keyPath: \CDProject.isDefault, ascending: false),
                    NSSortDescriptor(keyPath: \CDProject.name, ascending: true)
                ]
                
                do {
                    let cdProjects = try context.fetch(fetchRequest)
                    let projects = cdProjects.compactMap { self.mapToProjectEntity($0) }
                    
                    // Ensure at least one default project exists
                    if !projects.contains(where: { $0.isDefault }) && !projects.isEmpty {
                        // Make the first project default if none is marked as default
                        if let firstProject = projects.first, let cdProject = cdProjects.first {
                            cdProject.isDefault = true
                            try context.save()
                            
                            // Re-fetch with updated default status
                            let updatedCDProjects = try context.fetch(fetchRequest)
                            let updatedProjects = updatedCDProjects.compactMap { self.mapToProjectEntity($0) }
                            promise(.success(updatedProjects))
                            return
                        }
                    }
                    
                    promise(.success(projects))
                } catch {
                    print("❌ Error fetching projects: \(error)")
                    promise(.failure(.fetchFailed))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func addProject(_ project: ProjectEntity) -> AnyPublisher<ProjectEntity, ProjectError> {
        return Future<ProjectEntity, ProjectError> { [weak self] promise in
            guard let self = self else {
                promise(.failure(.createFailed))
                return
            }
            
            self.coreDataStack.performBackgroundTask { context in
                // If this project is marked as default, unmark any existing default project
                if project.isDefault {
                    self.updateExistingDefaultProjects(in: context)
                }
                
                let cdProject = CDProject(context: context)
                self.updateCDProject(cdProject, with: project)
                
                do {
                    try context.save()
                    promise(.success(project))
                } catch {
                    print("❌ Error adding project: \(error)")
                    promise(.failure(.createFailed))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func updateProject(_ project: ProjectEntity) -> AnyPublisher<ProjectEntity, ProjectError> {
        return Future<ProjectEntity, ProjectError> { [weak self] promise in
            guard let self = self else {
                promise(.failure(.updateFailed))
                return
            }
            
            self.coreDataStack.performBackgroundTask { context in
                let fetchRequest: NSFetchRequest<CDProject> = CDProject.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %@", project.id as CVarArg)
                fetchRequest.fetchLimit = 1
                
                do {
                    let results = try context.fetch(fetchRequest)
                    
                    if let cdProject = results.first {
                        // Handle default project status updates
                        if project.isDefault {
                            self.updateExistingDefaultProjects(in: context, exceptID: project.id)
                        } else if cdProject.isDefault {
                            // If this was previously default, we need to ensure another project becomes default
                            let hasAnotherDefault = try self.makeAnotherProjectDefault(in: context, exceptID: project.id)
                            
                            // If there's no other project that can be default, keep this one as default
                            if !hasAnotherDefault {
                                var updatedProject = project
                                updatedProject.isDefault = true
                                self.updateCDProject(cdProject, with: updatedProject)
                                try context.save()
                                promise(.success(updatedProject))
                                return
                            }
                        }
                        
                        self.updateCDProject(cdProject, with: project)
                        try context.save()
                        promise(.success(project))
                    } else {
                        promise(.failure(.notFound))
                    }
                } catch {
                    print("❌ Error updating project: \(error)")
                    promise(.failure(.updateFailed))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func deleteProject(id: UUID) -> AnyPublisher<Void, ProjectError> {
        return Future<Void, ProjectError> { [weak self] promise in
            guard let self = self else {
                promise(.failure(.deleteFailed))
                return
            }
            
            self.coreDataStack.performBackgroundTask { context in
                let fetchRequest: NSFetchRequest<CDProject> = CDProject.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
                fetchRequest.fetchLimit = 1
                
                do {
                    let results = try context.fetch(fetchRequest)
                    
                    if let cdProject = results.first {
                        // Cannot delete default project
                        if cdProject.isDefault {
                            promise(.failure(.cannotDeleteDefault))
                            return
                        }
                        
                        // TODO: Handle associated tasks if needed
                        
                        context.delete(cdProject)
                        try context.save()
                        promise(.success(()))
                    } else {
                        promise(.failure(.notFound))
                    }
                } catch {
                    print("❌ Error deleting project: \(error)")
                    promise(.failure(.deleteFailed))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getDefaultProject() -> AnyPublisher<ProjectEntity, ProjectError> {
        return Future<ProjectEntity, ProjectError> { [weak self] promise in
            guard let self = self else {
                promise(.failure(.fetchFailed))
                return
            }
            
            self.coreDataStack.performBackgroundTask { context in
                do {
                    // Try to find existing default project
                    let fetchRequest: NSFetchRequest<CDProject> = CDProject.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "isDefault == %@", NSNumber(value: true))
                    fetchRequest.fetchLimit = 1
                    
                    let results = try context.fetch(fetchRequest)
                    
                    if let defaultProject = results.first, let project = self.mapToProjectEntity(defaultProject) {
                        promise(.success(project))
                        return
                    }
                    
                    // If no default project, try to make first one default
                    let allProjectsRequest: NSFetchRequest<CDProject> = CDProject.fetchRequest()
                    allProjectsRequest.fetchLimit = 1
                    
                    let allProjects = try context.fetch(allProjectsRequest)
                    
                    if let firstProject = allProjects.first {
                        firstProject.isDefault = true
                        try context.save()
                        
                        if let project = self.mapToProjectEntity(firstProject) {
                            promise(.success(project))
                            return
                        }
                    }
                    
                    // If no projects at all, create a default one
                    let defaultProject = ProjectEntity(
                        name: "Personal",
                        color: "blue",
                        icon: "person",
                        isDefault: true
                    )
                    
                    let cdProject = CDProject(context: context)
                    self.updateCDProject(cdProject, with: defaultProject)
                    try context.save()
                    
                    promise(.success(defaultProject))
                } catch {
                    print("❌ Error getting default project: \(error)")
                    promise(.failure(.fetchFailed))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Helper Methods
    
    private func updateExistingDefaultProjects(in context: NSManagedObjectContext, exceptID: UUID? = nil) {
        let fetchRequest: NSFetchRequest<CDProject> = CDProject.fetchRequest()
        
        if let exceptID = exceptID {
            fetchRequest.predicate = NSPredicate(format: "isDefault == %@ AND id != %@",
                                               NSNumber(value: true), exceptID as CVarArg)
        } else {
            fetchRequest.predicate = NSPredicate(format: "isDefault == %@", NSNumber(value: true))
        }
        
        do {
            let defaultProjects = try context.fetch(fetchRequest)
            
            for project in defaultProjects {
                project.isDefault = false
            }
        } catch {
            print("❌ Error updating existing default projects: \(error)")
        }
    }
    
    private func makeAnotherProjectDefault(in context: NSManagedObjectContext, exceptID: UUID) throws -> Bool {
        let fetchRequest: NSFetchRequest<CDProject> = CDProject.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id != %@", exceptID as CVarArg)
        
        let projects = try context.fetch(fetchRequest)
        
        if let firstProject = projects.first {
            firstProject.isDefault = true
            return true
        }
        
        return false
    }
    
    private func updateCDProject(_ cdProject: CDProject, with project: ProjectEntity) {
        cdProject.id = project.id
        cdProject.name = project.name
        cdProject.color = project.color
        cdProject.icon = project.icon
        cdProject.isDefault = project.isDefault
    }
    
    private func mapToProjectEntity(_ cdProject: CDProject) -> ProjectEntity? {
        guard let id = cdProject.id,
              let name = cdProject.name,
              let color = cdProject.color else {
            return nil
        }
        
        return ProjectEntity(
            id: id,
            name: name,
            color: color,
            icon: cdProject.icon,
            isDefault: cdProject.isDefault
        )
    }
}
