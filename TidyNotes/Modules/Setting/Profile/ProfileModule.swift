//
//  ProfileModule.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 17/07/25.
//

import SwiftUI

enum ProfileModule {
    static func makeProfileView() -> some View {
        let interactor = ProfileInteractor()
        let router = ProfileRouter()
        let presenter = ProfilePresenter(interactor: interactor, router: router)
        return ProfileView(presenter: presenter)
    }
}
