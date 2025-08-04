# 📝 Tidy Notes
<p align="justify">
Tidy Notes is a lightweight and flexible task management app for iOS designed with simplicity and extensibility in mind. Whether you're tracking personal to-dos, project deadlines, or daily reminders, Tidy Notes provides a clean and intuitive interface to help you stay organized across all your Apple devices.
Built with SwiftUI, VIPER architecture, and Combine for reactive data handling, this app is structured for scalability and long-term maintainability. Upcoming features include notification reminders, cloud syncing via iCloud, and rich metadata similar to Notion’s block-based approach.
</p>

---

## ✨ Features

  - ✅ **Task CRUD** — Create, edit, delete, and view detailed tasks.
  - 🔐 **Multi-User Login** — Supports register/login and secure user sessions.
  - 👤 **Profile Management** — Edit profile & upload profile photos.
  - 🏷️ **Priority & Sorting** — Auto-sort by priority and most recent tasks.
  - 🔎 **Search** — Instant filtering by title or description.
  - 📷 **Attach Images** — Add photos to tasks and user profiles (Soon).
  - 🛡️ **Face ID / Touch ID** — Enhanced security with biometric authentication.
  - 🎨 **App Theme** — Light/dark mode toggling from settings.
  - 🌐 **Localization** — Multi-language UI support.
  - 🛎️ **Reminders** — Task notifications and reminders.
  - ☁️ **Cloud Sync** — Automatic data sync to the cloud.
  - ⚡ **Offline First** — All features work seamlessly without internet.

---

## 📱 Tech Stack

  - **SwiftUI** — Modern, declarative UI for iOS.
  - **VIPER** — Modular architecture (View, Presenter, Interactor, Router, Model).
  - **Combine** — Native Apple reactive data flow.
  - **Realm** — Fast, lightweight local database.
  - **Firebase Auth** — User authentication (optional/replaceable).
  - **Firebase Firestore** — Tasks and user data are stored and synced using Firestore, enabling access across devices (optional/replaceable).
  - **Supabase/MongoDB** — Planned for cloud image & data sync.
  - **Face ID / Touch ID** — Integrated with LocalAuthentication.

---

## 📦 Installation & Setup

### Requirements

  - Xcode 15+
  - iOS 16.1+
  - macOS Ventura or newer
  - Apple Developer Account

--- 

### Getting Started

```bash
git clone https://github.com/prizegafg/swift_TidyNotes.git
cd TidyNotes
```

---

## 🧠 Architecture Overview
  Each feature is encapsulated as a VIPER module, promoting reusability and separation of concerns. Communication between layers is handled using Combine publishers/subscribers.
    
    View ←→ Presenter ←→ Interactor ←→ Repository/Service
               ↑               ↓
             Router         Entity/Model

---

## 🌐 API & Backend

Tidy Notes is designed as an offline-first app, but is fully ready for cloud and backend integration.  
The main API and backend options include:

- **Firebase Auth & Firestore**  
  User authentication and **cloud storage for tasks, notes, and user profiles**.  
  - **Auth:** Secure login and multi-user management.
  - **Firestore:** All tasks, notes, and profile info are stored in Firestore collections, allowing instant backup and real-time cross-device sync.
  - **How it works:** Tasks and user data are saved both locally (Realm) and synced to Firestore in the background.  
    Changes made on any device are automatically reflected everywhere after sync.

- **Supabase** *(planned)*  
  Alternative to Firebase, with PostgreSQL backend.  
  Used for image storage and task data sync in future updates.

 
---

## 📸 Screenshots
(Coming soon — task list, detail view, image attachments, etc.)

## 📄 License
This project is licensed under the MIT License — use it, fork it, improve it freely.

