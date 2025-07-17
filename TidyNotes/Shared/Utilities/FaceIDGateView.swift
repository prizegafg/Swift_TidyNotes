//
//  FaceIDGateView.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 17/07/25.
//

import SwiftUI

struct FaceIDGateView: View {
    var onSuccess: () -> Void
    var onFail: (String?) -> Void
    @State private var tried = false
    var body: some View {
        VStack(spacing: 24) {
            ProgressView("Authenticating with Face ID...".localizedDescription)
                .onAppear {
                    guard !tried else { return }
                    tried = true
                    BiometricAuthHelper.shared.authenticateUser { success, error in
                        if success { onSuccess() }
                        else { onFail(error) }
                    }
                }
        }
    }
}
