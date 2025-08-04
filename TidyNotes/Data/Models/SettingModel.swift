//
//  SettingModel.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 04/08/25.
//

import SwiftUI
import PhotosUI

struct ProfileSectionModel: Equatable {
    var username: String
    var email: String
    var image: UIImage?
}
struct PreferencesSectionModel: Equatable {
    var language: String
    var theme: ThemeMode
}
struct AccountSectionModel: Equatable {
    var faceIDEnabled: Bool
}
struct SettingsModel: Equatable {
    var profile: ProfileSectionModel
    var preferences: PreferencesSectionModel
    var account: AccountSectionModel
}
