//
//  RegisterRouter.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 15/05/25.
//

import Foundation
import SwiftUI

final class RegisterRouter {
    func navigateToLogin() {
        RootNavigator.shared.replaceRoot(view: LoginModule.makeLoginView())

    }
}
