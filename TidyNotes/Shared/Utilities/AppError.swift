//
//  AppError.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 26/06/25.
//

import Foundation

enum AppError: Error, LocalizedError {
    // General
    case invalidUUID
    case notFound
    case unknown
    case invalidInput
    case unauthorized
    case networkError(String)
    case custom(message: String)
    
    // Realm/Database
    case realmError(String)
    case databaseWriteFailed
    case databaseReadFailed
    
    // Auth
    case userNotLoggedIn
    case invalidCredentials
    case userAlreadyExists
    

    var errorDescription: String? {
        switch self {
        case .invalidUUID:
            return "ID tidak valid."
        case .notFound:
            return "Data tidak ditemukan."
        case .unknown:
            return "Terjadi kesalahan yang tidak diketahui."
        case .invalidInput:
            return "Input tidak valid."
        case .unauthorized:
            return "Akses tidak diizinkan."
        case .networkError(let msg):
            return "Network error: \(msg)"
        case .custom(let message):
            return message
        case .realmError(let msg):
            return "Database error: \(msg)"
        case .databaseWriteFailed:
            return "Gagal menulis ke database."
        case .databaseReadFailed:
            return "Gagal membaca dari database."
        case .userNotLoggedIn:
            return "User belum login."
        case .invalidCredentials:
            return "Email atau password salah."
        case .userAlreadyExists:
            return "User sudah terdaftar."
        }
    }
}
