//
//  ExtString.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 30/04/25.
//

import SwiftUI

extension String {
    var trimmed: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
