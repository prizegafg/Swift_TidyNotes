//
//  ExtUserDefault.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 17/07/25.
//

import Foundation

extension UserDefaults {
    var isFaceIDEnabled: Bool {
        get { bool(forKey: "faceid_enabled") }
        set { set(newValue, forKey: "faceid_enabled") }
    }
}
