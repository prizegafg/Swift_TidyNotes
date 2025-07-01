//
//  SettingModule.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 15/05/25.
//

import SwiftUI

enum SettingsModule {
    static func makeSettingsView() -> some View {
        let interactor = SettingsInteractor()
        let router = SettingsRouter()
        let presenter = SettingsPresenter(interactor: interactor, router: router)
        return SettingsView(presenter: presenter)
    }
}
