//
//  InProgressDialog.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 03/08/25.
//

import SwiftUI

struct InProgressDialog: View {
    var message: String = "This feature is in development and will be availabe soon."
    var onDismiss: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .frame(width: 48, height: 48)
                .foregroundColor(.yellow)
                .shadow(radius: 4)
            Text("Feature in Development")
                .font(.headline)
                .foregroundColor(.primary)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button(action: { onDismiss?() }) {
                Text("Undestood")
                    .font(.body)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .padding(.top, 8)
        }
        .padding(28)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 10)
        )
        .padding(32)
        .transition(.scale.combined(with: .opacity))
    }
}
