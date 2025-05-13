//
//  RealmProjectObject.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 13/05/25.
//

import Foundation
import RealmSwift

final class RealmProjectObject: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var name: String = ""
    @Persisted var color: String = "blue"
    @Persisted var icon: String?
    @Persisted var isDefault: Bool = false

    convenience init(entity: ProjectEntity) {
        self.init()
        self.id = entity.id.uuidString
        self.name = entity.name
        self.color = entity.color
        self.icon = entity.icon
        self.isDefault = entity.isDefault
    }

    func toEntity() -> ProjectEntity {
        return ProjectEntity(
            id: UUID(uuidString: id) ?? UUID(),
            name: name,
            color: color,
            icon: icon,
            isDefault: isDefault
        )
    }
}
