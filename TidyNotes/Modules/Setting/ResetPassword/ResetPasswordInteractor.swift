//
//  ResetPasswordInteractor.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 02/07/25.
//

import Foundation
import Combine
import FirebaseAuth

final class ResetPasswordInteractor {
    func sendResetPassword(email: String) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
