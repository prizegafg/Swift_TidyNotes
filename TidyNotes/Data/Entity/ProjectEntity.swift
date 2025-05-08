//
//  ProjectEntity.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 05/05/25.
//

import Foundation
import SwiftUI

/// Model yang merepresentasikan project dalam aplikasi
struct ProjectEntity: Identifiable, Equatable, Hashable, Codable {
    let id: UUID
    var name: String
    var color: String
    var icon: String?
    var isDefault: Bool
    
    init(
        id: UUID = UUID(),
        name: String,
        color: String = "blue",
        icon: String? = nil,
        isDefault: Bool = false
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.icon = icon
        self.isDefault = isDefault
    }
    
    /// Warna UI yang digunakan untuk menampilkan project
    var uiColor: Color {
        switch color {
        case "red": return .red
        case "orange": return .orange
        case "yellow": return .yellow
        case "green": return .green
        case "blue": return .blue
        case "purple": return .purple
        case "pink": return .pink
        default: return .blue
        }
    }
}

/// Enum error untuk error handling terkait projects
enum ProjectError: Error, Equatable {
    case fetchFailed
    case createFailed
    case updateFailed
    case deleteFailed
    case invalidProject
    case notFound
    case cannotDeleteDefault
    
    var localizedDescription: String {
        switch self {
        case .fetchFailed: return "Failed to fetch projects"
        case .createFailed: return "Failed to create project"
        case .updateFailed: return "Failed to update project"
        case .deleteFailed: return "Failed to delete project"
        case .invalidProject: return "Invalid project data"
        case .notFound: return "Project not found"
        case .cannotDeleteDefault: return "Cannot delete default project"
        }
    }
}
