//
//  ResetPasswordRouter.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 02/07/25.
//

import Foundation
import SwiftUI

final class ResetPasswordRouter {
    func navigateToLogin() {
        RootNavigator.shared.replaceRoot(view: LoginModule.makeLoginView())
    }
}
