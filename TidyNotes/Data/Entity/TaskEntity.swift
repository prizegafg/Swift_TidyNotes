//
//  TaskEntity.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 30/04/25.
//

import Foundation

/// Model yang merepresentasikan task dalam aplikasi
struct TaskEntity: Identifiable, Equatable, Hashable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    var dueDate: Date?
    var tag: TaskTag?
    
    init(
        id: UUID = UUID(),
        title: String,
        isCompleted: Bool = false,
        dueDate: Date? = nil,
        tag: TaskTag? = nil
    ) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.dueDate = dueDate
        self.tag = tag
    }
}

/// Enum yang merepresentasikan tag/kategori dari task
enum TaskTag: String, CaseIterable, Identifiable, Hashable {
    case work
    case personal
    case shopping
    case health
    case finance
    case other
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .work: return "Work"
        case .personal: return "Personal"
        case .shopping: return "Shopping"
        case .health: return "Health"
        case .finance: return "Finance"
        case .other: return "Other"
        }
    }
    
    var color: String {
        switch self {
        case .work: return "blue"
        case .personal: return "green"
        case .shopping: return "orange"
        case .health: return "red"
        case .finance: return "purple"
        case .other: return "gray"
        }
    }
}

/// Enum error untuk error handling terkait tasks
enum TaskError: Error, Equatable {
    case fetchFailed
    case createFailed
    case updateFailed
    case deleteFailed
    case invalidTask
    case notFound
    
    var localizedDescription: String {
        switch self {
        case .fetchFailed: return "Failed to fetch tasks"
        case .createFailed: return "Failed to create task"
        case .updateFailed: return "Failed to update task"
        case .deleteFailed: return "Failed to delete task"
        case .invalidTask: return "Invalid task data"
        case .notFound: return "Task not found"
        }
    }
}
