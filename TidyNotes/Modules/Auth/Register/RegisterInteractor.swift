//
//  RegisterInteractor.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 15/05/25.
//

import Foundation
import Combine
import RealmSwift

final class RegisterInteractor {
    private let app: App

    init(app: App = App(id: "your-realm-app-id")) {
        self.app = app
    }

    func register(email: String, password: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            self.app.emailPasswordAuth.registerUser(email: email, password: password) { error in
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
