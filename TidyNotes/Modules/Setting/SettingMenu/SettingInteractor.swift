//
//  SettingInteractor.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 15/05/25.
//

import Foundation
import UIKit
import FirebaseAuth

final class SettingsInteractor {
    private let app = SessionManager.shared

    func getCurrentUserProfile() -> (name: String, email: String) {
        let user = app.currentUser
        return (user?.username ?? "", user?.email ?? "")
    }

    func saveUserProfile(name: String, email: String, image: UIImage?) {
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

    func logout(completion: @escaping (Error?) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(nil)
        } catch {
            completion(error)
        }
    }

    private func getImageSavePath() -> URL {
        let filename = "user_profile_photo.jpg"
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)
    }
}
