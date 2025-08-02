//
//  LoginRouter.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 15/05/25.
//

import SwiftUI

final class LoginRouter {
    func navigateToTaskList() {
        RootNavigator.shared.replaceRoot(view: TaskListModule.makeTaskListView())
    }

    func navigateToRegister() {
        RootNavigator.shared.replaceRoot(view: RegisterModule.makeRegisterView())
    }
    
}
