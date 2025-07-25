//
//  ProfileRouter.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 17/07/25.
//

import SwiftUI

final class ProfileRouter {
    func navigateBackToSettings() {
        RootNavigator.shared.replaceRoot(view: SettingsModule.makeSettingsView())
    }
}
