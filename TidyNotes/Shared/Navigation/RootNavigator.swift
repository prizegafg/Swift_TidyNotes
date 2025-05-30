//
//  RootNavigator.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 27/05/25.
//

import SwiftUI
import UIKit

final class RootNavigator {
    static let shared = RootNavigator()

    private init() {}

    func replaceRoot<V: View>(view: V) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }

        window.rootViewController = UIHostingController(rootView: view)
        window.makeKeyAndVisible()
    }

    func dismissToRoot() {
        replaceRoot(view: LoginModule.makeLoginView())
    }
}
