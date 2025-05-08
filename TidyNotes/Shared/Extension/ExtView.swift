//
//  ExtView.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 08/05/25.
//

import SwiftUICore
import UIKit

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
