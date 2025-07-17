//
//  ResetPasswordModule.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 02/07/25.
//

import SwiftUI

enum ResetPasswordModule {
    static func makeResetPasswordView() -> some View {
        let interactor = ResetPasswordInteractor()
        let router = ResetPasswordRouter()
        let presenter = ResetPasswordPresenter(interactor: interactor, router: router)
        return ResetPasswordView(presenter: presenter)
    }
}
