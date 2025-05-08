//
//  TaskMo+Extension.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 08/05/25.
//

import Foundation
import CoreData

extension TaskMO {
    
    func toEntity() -> TaskEntity {
        return TaskEntity(
            id: id ?? UUID(),
            title: title ?? "",
            description: taskDescription ?? "",
            isPriority: isPriority,
            createdAt: createdAt ?? Date(),
            dueDate: dueDate,
            status: TaskStatus(rawValue: statusRaw ?? TaskStatus.todo.rawValue) ?? .todo
        )
    }
    
    static func fromEntity(_ entity: TaskEntity, in context: NSManagedObjectContext, projectId: UUID? = nil) -> TaskMO {
            let taskMO = TaskMO(context: context)
            taskMO.id = entity.id
            taskMO.title = entity.title
            taskMO.taskDescription = entity.description
            taskMO.isPriority = entity.isPriority
            taskMO.createdAt = entity.createdAt
            taskMO.dueDate = entity.dueDate
            taskMO.statusRaw = entity.status.rawValue
            
            // Set relationship to project if provided
            if let projectId = projectId {
                let fetchRequest: NSFetchRequest<ProjectMO> = ProjectMO.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %@", projectId as CVarArg)
                fetchRequest.fetchLimit = 1
                
                do {
                    let results = try context.fetch(fetchRequest)
                    if let projectMO = results.first {
                        taskMO.project = projectMO
                    }
                } catch {
                    print("Error fetching project: \(error)")
                }
            }
            
            return taskMO
        }
}

