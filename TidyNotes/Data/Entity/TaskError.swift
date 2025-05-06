//
//  TaskError.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 05/05/25.
//

import Foundation


enum TaskError: Error, LocalizedError {
    case taskNotFound
    case saveFailed
    case deleteFailed
    case networkError(String)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .taskNotFound:
            return "Task tidak ditemukan"
        case .saveFailed:
            return "Gagal menyimpan task"
        case .deleteFailed:
            return "Gagal menghapus task"
        case .networkError(let message):
            return "Network error: \(message)"
        case .unknown:
            return "Terjadi kesalahan yang tidak diketahui"
        }
    }
}
