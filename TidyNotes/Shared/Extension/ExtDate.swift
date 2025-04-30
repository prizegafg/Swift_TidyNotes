//
//  ExtDate.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 30/04/25.
//

import SwiftUI

extension Date {
    var formattedString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
}
