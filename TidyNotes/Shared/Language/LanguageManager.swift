//
//  LanguageManager.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 16/07/25.
//

import Foundation
import SwiftUI

final class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    private let languageKey = "app_language"
    @Published var currentLanguage: String

    let supportedLanguages: [(name: String, code: String)] = [
        ("English", "en"),
        ("Indonesia", "id")
    ]

    private init() {
        if let saved = UserDefaults.standard.string(forKey: languageKey) {
            currentLanguage = saved
        } else {
            let systemLang = Locale.current.language.languageCode?.identifier ?? "en"
            currentLanguage = supportedLanguages.map { $0.code }.contains(systemLang) ? systemLang : "en"
            UserDefaults.standard.set(currentLanguage, forKey: languageKey)
        }
    }

    func setLanguage(_ code: String) {
        guard currentLanguage != code else { return }
        currentLanguage = code
        UserDefaults.standard.set(code, forKey: languageKey)
    }

    func displayName(for code: String) -> String {
        supportedLanguages.first(where: { $0.code == code })?.name ?? "English"
    }

    func localizedString(forKey key: String) -> String {
        let tableName = "Localizable"
        guard
            let path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj"),
            let bundle = Bundle(path: path)
        else { return key }
        return NSLocalizedString(key, tableName: tableName, bundle: bundle, value: key, comment: "")
    }
}
