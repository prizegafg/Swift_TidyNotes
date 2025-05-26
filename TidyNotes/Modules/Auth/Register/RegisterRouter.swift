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
        // Belum real navigasi — bisa diatur nanti kalau pakai NavigationStack
        let window = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
        
        window?.rootViewController = UIHostingController(rootView: LoginModule.makeLoginView())
        window?.makeKeyAndVisible()
        

    }
}
