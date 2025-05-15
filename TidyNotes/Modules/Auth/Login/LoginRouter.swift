//
//  LoginRouter.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 15/05/25.
//

import SwiftUI

final class LoginRouter {
    func navigateToTaskList() {
        // Ganti ini sesuai modul kamu
        let window = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }

        window?.rootViewController = UIHostingController(rootView: TaskListModule.makeTaskListView())
        window?.makeKeyAndVisible()
    }

    func navigateToRegister() {
        // Placeholder – nanti dihubungkan ke register view
        print("Navigate to Register (TODO)")
    }
}
