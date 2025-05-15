//
//  LoginModule.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 15/05/25.
//

import SwiftUI

enum LoginModule {
    static func makeLoginView() -> some View {
        let interactor = LoginInteractor()
        let router = LoginRouter()
        let presenter = LoginPresenter(interactor: interactor, router: router)
        return LoginView(presenter: presenter)
    }
}
