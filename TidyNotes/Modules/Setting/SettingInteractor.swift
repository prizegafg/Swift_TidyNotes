//
//  SettingInteractor.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 15/05/25.
//

import Foundation
import UIKit
import RealmSwift

final class SettingsInteractor {
    private let app = SessionManager.shared.realmApp

    func getCurrentUserProfile() -> (name: String, email: String) {
        let user = app.currentUser
        return (user?.profile.name ?? "", user?.profile.email ?? "")
    }

    func saveUserProfile(name: String, email: String, image: UIImage?) {
        // Simpan nama atau email ke server (optional - lewat MongoDB)
        // Simpan gambar ke local
        if let image = image {
            if let data = image.jpegData(compressionQuality: 0.8) {
                let url = getImageSavePath()
                try? data.write(to: url)
            }
        }
    }

    func loadSavedImage() -> UIImage? {
        let url = getImageSavePath()
        return UIImage(contentsOfFile: url.path)
    }

    func resetPassword(completion: @escaping (Bool, String?) -> Void) {
        guard let email = app.currentUser?.profile.email else {
            completion(false, "Email tidak ditemukan.")
            return
        }

        app.emailPasswordAuth.sendResetPasswordEmail(email) { error in
            if let error = error {
                completion(false, error.localizedDescription)
            } else {
                completion(true, nil)
            }
        }
    }

    func logout() {
//        try? app.currentUser?.logOut()
        app.currentUser?.logOut { error in
            if let error = error {
                print("Logout error: \(error.localizedDescription)")
            } else {
                print("Logout berhasil.")
            }
        }
    }

    private func getImageSavePath() -> URL {
        let filename = "user_profile_photo.jpg"
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)
    }
}
