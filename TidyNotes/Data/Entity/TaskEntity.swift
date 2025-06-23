//
//  TaskEntity.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 07/05/25.
//

import Foundation
import RealmSwift

enum TaskStatus: String, PersistableEnum, Codable, CaseIterable {
    case todo, inProgress, done
}

final class TaskEntity: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: UUID
    @Persisted var userId: String
    @Persisted var title: String
    @Persisted var descriptionText: String
    @Persisted var isPriority: Bool
    @Persisted var createdAt: Date
    @Persisted var dueDate: Date?
    @Persisted var isReminderOn: Bool
    @Persisted var reminderDate: Date?
    @Persisted var imagePath: String?
    @Persisted var status: TaskStatus

    convenience init(
        id: UUID = UUID(),
        userId: String,
        title: String,
        descriptionText: String,
        isPriority: Bool = false,
        createdAt: Date = Date(),
        dueDate: Date? = nil,
        isReminderOn: Bool = false,
        reminderDate: Date? = nil,
        imagePath: String? = nil,
        status: TaskStatus = .todo
    ) {
        self.init()
        self.id = id
        self.userId = userId
        self.title = title
        self.descriptionText = descriptionText
        self.isPriority = isPriority
        self.createdAt = createdAt
        self.dueDate = dueDate
        self.isReminderOn = isReminderOn
        self.reminderDate = reminderDate
        self.imagePath = imagePath
        self.status = status
    }
}
