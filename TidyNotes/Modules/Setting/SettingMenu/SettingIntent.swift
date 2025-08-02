//
//  SettingIntent.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 15/05/25.
//

import SwiftUI
import Combine
import PhotosUI
import LocalAuthentication

final class SettingsPresenter: ObservableObject {
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var image: UIImage? = nil
    @Published var selectedItem: PhotosPickerItem? = nil {
        didSet {
            loadImage()
        }
    }
    
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var language: String = LanguageManager.shared.currentLanguage
    @Published var theme: ThemeMode = ThemeManager.shared.selectedThemeMode
    @Published var faceIDEnabled: Bool = UserDefaults.standard.isFaceIDEnabled
    @Published var showLogoutDialog = false
    @Published var showLanguageDropdown: Bool = false
    @Published var showThemeDropdown: Bool = false
    @Published var isResetPasswordActive = false
    
    private let interactor: SettingsInteractor
    private let router: SettingsRouter
    private var cancellables = Set<AnyCancellable>()
    
    var languageOptions: [String] {
        LanguageManager.shared.supportedLanguages.map { $0.name.localizedDescription }
    }
    
    var selectedLanguageLocalized: String {
        // Ambil display name dari code, lalu localize
        if let original = LanguageManager.shared.supportedLanguages.first(where: { $0.code == language }) {
            return original.name.localizedDescription
        }
        // fallback: tampilkan bahasa pertama
        return LanguageManager.shared.supportedLanguages.first?.name.localizedDescription ?? ""
    }
    
    var themeOptions: [String] {
        ThemeMode.allCases.map { $0.rawValue }
    }
    
    init(interactor: SettingsInteractor, router: SettingsRouter) {
        self.interactor = interactor
        self.router = router
        
        let key = "app_language"
        if let saved = UserDefaults.standard.string(forKey: key) {
            language = saved
        } else {
            let systemLang = Locale.current.languageCode ?? "en"
            language = systemLang // "en" or "id"
        }
        loadInitialData()
    }
    
    func loadInitialData() {
        let user = interactor.getCurrentUserProfile()
        username = user.name
        email = user.email
        if let savedImage = interactor.loadSavedImage() {
            image = savedImage
        }
    }
    
    func onEditProfileTapped() {
        router.navigateToProfile()
    }
    
    
    func onLanguageTapped() {
        showLanguageDropdown.toggle()
    }
    
    func onThemeTapped() {
        showThemeDropdown.toggle()
    }
    
    func selectLanguage(_ localizedName: String) {
        if let original = LanguageManager.shared.supportedLanguages.first(where: { $0.name.localizedDescription == localizedName }) {
            LanguageManager.shared.setLanguage(original.code)
            language = original.code
        }
        showLanguageDropdown = false
    }
    
    func selectTheme(_ name: String) {
        if let mode = ThemeMode(rawValue: name) {
            theme = mode
            ThemeManager.shared.setTheme(mode)
        }
        showThemeDropdown = false
    }
    
    func onPasswordTapped() {
        isResetPasswordActive = true
    }
    
    func onFaceIDToggled(_ enabled: Bool) {
        if enabled {
            guard BiometricAuthHelper.shared.isBiometricAvailable() else {
                showAlert(message: "Device does not support Face ID / Touch ID.".localizedDescription)
                faceIDEnabled = false
                UserDefaults.standard.isFaceIDEnabled = false
                return
            }
            BiometricAuthHelper.shared.authenticateUser { [weak self] success, errorMsg in
                if success {
                    self?.faceIDEnabled = true
                    UserDefaults.standard.isFaceIDEnabled = true
                } else {
                    self?.faceIDEnabled = false
                    UserDefaults.standard.isFaceIDEnabled = false
                    if let msg = errorMsg {
                        self?.showAlert(message: msg)
                    }
                }
            }
        } else {
            faceIDEnabled = false
            UserDefaults.standard.isFaceIDEnabled = false
        }
    }
    
    func onLogoutTapped() {
        showLogoutDialog = true
    }
    
    func logout() {
        interactor.logout { [weak self] error in
            if let error = error {
                self?.showAlert(message: error.localizedDescription)
            } else {
                TaskService.shared.clearLocalTasks()
                self?.router.navigateToLogin()
            }
        }
    }
    
    private func loadImage() {
        guard let item = selectedItem else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                await MainActor.run {
                    self.image = uiImage
                }
            }
        }
    }
    
    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
}
