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
    
    var localizedDescription: String {
        _ = LanguageManager.shared.currentLanguage
        let lang = LanguageManager.shared.currentLanguage
        let tableName = "Localizable"
        guard let path = Bundle.main.path(forResource: lang, ofType: "lproj"),
              let bundle = Bundle(path: path)
        else { return self }
        return NSLocalizedString(self, tableName: tableName, bundle: bundle, value: self, comment: "")
    }
}
