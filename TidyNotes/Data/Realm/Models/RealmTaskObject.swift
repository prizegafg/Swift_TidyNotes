//
//  RealmTaskObject.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 13/05/25.
//

import Foundation
import RealmSwift

final class RealmTaskObject: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var userId: String
    @Persisted var title: String = ""
    @Persisted var taskDescription: String = ""
    @Persisted var isPriority: Bool = false
    @Persisted var createdAt: Date = Date()
    @Persisted var dueDate: Date?
    @Persisted var isReminderOn: Bool
    @Persisted var reminderDate: Date?
    @Persisted var imagePath: String?
    @Persisted var statusRaw: String = TaskStatus.todo.rawValue

    var status: TaskStatus {
        get { TaskStatus(rawValue: statusRaw) ?? .todo }
        set { statusRaw = newValue.rawValue }
    }

    convenience init(entity: TaskEntity) {
        self.init()
        self.id = entity.id.uuidString
        self.title = entity.title
        self.userId = entity.userId
        self.taskDescription = entity.description
        self.isPriority = entity.isPriority
        self.createdAt = entity.createdAt
        self.dueDate = entity.dueDate
        self.isReminderOn = entity.isReminderOn
        self.reminderDate = entity.reminderDate
        self.imagePath = entity.imagePath
        self.status = entity.status
    }

    func toEntity() -> TaskEntity {
        return TaskEntity(
            id: UUID(uuidString: id) ?? UUID(),
            userId: userId,
            title: title,
            descriptionText: taskDescription,
            isPriority: isPriority,
            createdAt: createdAt,
            dueDate: dueDate,
            isReminderOn: isReminderOn,
            reminderDate: reminderDate,
            imagePath: imagePath,
            status: status
        )
    }
}
