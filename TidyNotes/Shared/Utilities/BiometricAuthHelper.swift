//
//  BiometricAuthHelper.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 17/07/25.
//

import Foundation
import LocalAuthentication

final class BiometricAuthHelper {
    static let shared = BiometricAuthHelper()
    private init() {}

    func isBiometricAvailable() -> Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    func authenticateUser(reason: String = "Authenticate with Face ID to login", completion: @escaping (Bool, String?) -> Void) {
        let context = LAContext()
        context.localizedCancelTitle = "Cancel"
        var authError: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                DispatchQueue.main.async {
                    completion(success, error?.localizedDescription)
                }
            }
        } else {
            DispatchQueue.main.async {
                completion(false, authError?.localizedDescription)
            }
        }
    }
}
