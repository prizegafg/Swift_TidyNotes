//
//  ProjectMO+Extension.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 08/05/25.
//

import Foundation
import CoreData

extension ProjectMO {
        
    func toEntity() -> ProjectEntity {
        return ProjectEntity(
            id: id ?? UUID(),
            name: name ?? "",
            color: color ?? "blue",
            icon: icon,
            isDefault: isDefault
        )
    }
    
    static func fromEntity(_ entity: ProjectEntity, in context: NSManagedObjectContext) -> ProjectMO {
        let projectMO = ProjectMO(context: context)
        projectMO.id = entity.id
        projectMO.name = entity.name
        projectMO.color = entity.color
        projectMO.icon = entity.icon
        projectMO.isDefault = entity.isDefault
        return projectMO
    }
}
    
