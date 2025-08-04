//
//  AppAlertMessage.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 04/08/25.
//

import Foundation

enum AppAlertMessage {
    // Generic
    static let unknownError = "Unknown error occurred".localizedDescription
    static let fieldEmpty = "Field Cannot be Empty".localizedDescription
    static let featureInProgress = "This feature is in progress".localizedDescription
    static let success = "Success!".localizedDescription
    static let failed = "Failed".localizedDescription

    // Auth
    static let userNotFound = "User Not Found".localizedDescription
    static let invalidEmail = "Invalid Email".localizedDescription
    static let wrongPassword = "Wrong Password".localizedDescription
    static let logoutConfirm = "Are you sure you want to logout?".localizedDescription

    // Profile
    static let profileUpdated = "Profile updated successfully".localizedDescription

    // Face ID
    static let faceIDNotSupported = "Device does not support Face ID / Touch ID.".localizedDescription
    static let faceIDFailed = "Face ID authentication failed.".localizedDescription

}
