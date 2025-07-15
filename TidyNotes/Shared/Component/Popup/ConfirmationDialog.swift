//
//  ConfirmationDialog.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 08/05/25.
//

import SwiftUI

struct ConfirmationDialog: View {
    let title: String
    let message: String
    let confirmText: String
    let cancelText: String
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            HStack(spacing: 20) {
                Button(action: {
                    onCancel()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text(cancelText)
                        .frame(minWidth: 80)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                }
                .buttonStyle(.bordered)
                
                Button(action: {
                    onConfirm()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text(confirmText)
                        .frame(minWidth: 80)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(radius: 8)
        )
        .padding(24)
    }
}

struct ConfirmationDialogContainer: ViewModifier {
    @Binding var isPresented: Bool
    let title: String
    let message: String
    let confirmText: String
    let cancelText: String
    let onConfirm: () -> Void
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                ConfirmationDialog(
                    title: title,
                    message: message,
                    confirmText: confirmText,
                    cancelText: cancelText,
                    onConfirm: onConfirm,
                    onCancel: { isPresented = false }
                )
                .interactiveDismissDisabled()
                .background(BackgroundClearView())
            }
    }
}

struct BackgroundClearView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

extension View {
    func confirmationDialog(
        isPresented: Binding<Bool>,
        title: String,
        message: String,
        confirmText: String = "Yes",
        cancelText: String = "No",
        onConfirm: @escaping () -> Void
    ) -> some View {
        self.modifier(
            ConfirmationDialogContainer(
                isPresented: isPresented,
                title: title,
                message: message,
                confirmText: confirmText,
                cancelText: cancelText,
                onConfirm: onConfirm
            )
        )
    }
}

struct ConfirmationDialog_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmationDialog(
            title: "Confirmation",
            message: "Are you sure want to delete this task?",
            confirmText: "Yes",
            cancelText: "No",
            onConfirm: {},
            onCancel: {}
        )
    }
}
