//
//  SettingRouter.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 15/05/25.
//

import SwiftUI

final class SettingsRouter {
    func navigateToLogin() {
        let window = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }

        window?.rootViewController = UIHostingController(rootView: LoginModule.makeLoginView())
        window?.makeKeyAndVisible()
    }
    
    func navigateToProfile() {
        RootNavigator.shared.replaceRoot(view: ProfileModule.makeProfileView())
    }
    
    func navigateToResetPassword() {
        RootNavigator.shared.replaceRoot(view: ResetPasswordModule.makeResetPasswordView())
    }
}
