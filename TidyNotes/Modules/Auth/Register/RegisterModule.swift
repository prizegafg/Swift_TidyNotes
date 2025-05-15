//
//  RegisterModule.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 15/05/25.
//

import SwiftUI

enum RegisterModule {
    static func makeRegisterView() -> some View {
        let interactor = RegisterInteractor()
        let router = RegisterRouter()
        let presenter = RegisterPresenter(interactor: interactor, router: router)
        return RegisterView(presenter: presenter)
    }
}
