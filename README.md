# 📝 Tidy Notes
<p align="justify">
Tidy Notes is a lightweight and flexible task management app for iOS designed with simplicity and extensibility in mind. Whether you're tracking personal to-dos, project deadlines, or daily reminders, Tidy Notes provides a clean and intuitive interface to help you stay organized across all your Apple devices.
Built with SwiftUI, VIPER architecture, and Combine for reactive data handling, this app is structured for scalability and long-term maintainability. Upcoming features include notification reminders, cloud syncing via iCloud, and rich metadata similar to Notion’s block-based approach.
</p>

---

## ✨ Features

  - ✅ **Task CRUD** — Create, read, update, and delete tasks with ease.
  - 🖼️ **Attach Images** — Add photos to any task for better visual context.
  - 🛎️ **Deadline Reminders (Coming Soon)** — Get notified before your tasks are due.
  - ☁️ **iCloud Sync (Coming Soon)** — Access your tasks across devices via iCloud.
  - 🗂️ **Additional Properties (Planned)** — Add labels, tags, or completion checkboxes like in Notion.
  - 🔍 **Quick Search (Planned)** — Instantly filter and locate tasks.
  - 🧱 **Modular Architecture** — Built using VIPER for scalable module-by-module development.

---

## 📱 Tech Stack

  - **SwiftUI** — Declarative UI for Apple platforms.
  - **VIPER Architecture** — Clean separation of concerns and testable design.
  - **Combine** — Apple-native reactive programming framework.
  - **Core Data** — Persistent local storage with iCloud integration.
  - **iCloud** — CloudKit support for cross-device syncing (in progress).

---

## 📦 Installation & Setup

### Requirements

  - Xcode 15+
  - iOS 16.0+
  - macOS Ventura or newer
  - Apple Developer Account

--- 

### Getting Started

```bash
git clone https://github.com/your-username/tidynotes.git
cd tidynotes
```

---

## 🧠 Architecture Overview
  Each feature is encapsulated as a VIPER module, promoting reusability and separation of concerns. Communication between layers is handled using Combine publishers/subscribers.
    
    View ←→ Presenter ←→ Interactor ←→ Repository/Service
               ↑               ↓
             Router         Entity/Model

---

## 🌐 API & Future Backend Options
While currently offline-first with Core Data, the app is designed to be backend-ready. Potential free-tier services to enable remote storage or sync:

- **Supabase** — Firebase alternative with PostgreSQL backend
- **Appwrite** — Self-hosted or cloud backend-as-a-service
- **Firebase** — Push notifications, Firestore, and storage

---

## 📸 Screenshots
(Coming soon — task list, detail view, image attachments, etc.)

## 📄 License
This project is licensed under the MIT License — use it, fork it, improve it freely.

