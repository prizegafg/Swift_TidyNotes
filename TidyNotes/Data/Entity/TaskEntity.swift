//
//  TaskEntity.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 07/05/25.
//

import Foundation

/// Entity untuk Task dalam arsitektur VIPER
struct TaskEntity: Identifiable, Equatable, Codable {
    let id: UUID
    var title: String
    var description: String
    var isPriority: Bool
    let createdAt: Date
    var dueDate: Date?  // Optional due date
    var isReminderOn: Bool
    var reminderDate: Date?
    var status: TaskStatus
    
    static func == (lhs: TaskEntity, rhs: TaskEntity) -> Bool {
        return lhs.id == rhs.id
    }
}

/// Status task
enum TaskStatus: String, Codable {
    case todo = "To Do"
    case inProgress = "In Progress"
    case done = "Done"
}

