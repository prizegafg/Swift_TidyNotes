//
//  TaskModel.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 30/07/25.
//

import Foundation

struct TaskModel: Identifiable, Equatable {
    var id: UUID
    var userId: String
    var title: String
    var descriptionText: String
    var isPriority: Bool
    var createdAt: Date
    var dueDate: Date?
    var isReminderOn: Bool
    var reminderDate: Date?
    var imagePath: String?
    var status: TaskStatus
    
    init(entity: TaskEntity) {
        self.id = entity.id
        self.userId = entity.userId
        self.title = entity.title
        self.descriptionText = entity.descriptionText
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
            id: id,
            userId: userId,
            title: title,
            descriptionText: descriptionText,
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
