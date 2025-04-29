//
//  Entity.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 29/04/25.
//

import Foundation

struct Task: Identifiable, Equatable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    var projectId: UUID?
    var createdAt: Date
    var updatedAt: Date

    // Optional untuk versi berikutnya (v0.2+)
    var description: String?
    var dueDate: Date?
    var tags: [String]?
}

struct Project: Identifiable, Equatable {
    let id: UUID
    var name: String
    var colorHex: String? // Untuk UI badge warna
    var createdAt: Date
    var updatedAt: Date
}

struct ErrorMessage: Identifiable {
    let id = UUID()
    let message: String
}

