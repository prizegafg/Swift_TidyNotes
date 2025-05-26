//
//  LoginInteractor.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 15/05/25.
//

import Foundation
import Combine
import RealmSwift

final class LoginInteractor {
    private let app: App

    init(app: App = App(id: "tidynotesapp-fjyavvn")) {
        self.app = app
    }

    func login(email: String, password: String) -> AnyPublisher<Void, Error> {
        let credentials = Credentials.emailPassword(email: email, password: password)

        return Future<Void, Error> { promise in
            self.app.login(credentials: credentials) { result in
                switch result {
                case .failure(let error):
                    promise(.failure(error))
                case .success:
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
