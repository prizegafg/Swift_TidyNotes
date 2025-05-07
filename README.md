📝 Tidy Notes
Tidy Notes adalah aplikasi manajemen tugas yang dirancang khusus untuk pengguna iOS, dengan tampilan sederhana namun fungsional. Aplikasi ini memudahkan kamu mengatur pekerjaan harian, mengelola deadline, dan mencatat ide-ide penting, dengan struktur yang fleksibel seperti Notion namun tetap ringan dan responsif.

✨ Fitur Utama
  ✅ CRUD Task — Buat, lihat, ubah, dan hapus task dengan mudah.
  🖼️ Tambahkan Gambar — Lampirkan gambar ke tiap task untuk referensi visual.
  🛎️ Reminder & Notifikasi (Coming Soon) — Dapatkan notifikasi sebelum deadline penting.
  ☁️ Cloud Sync via iCloud (Coming Soon) — Simpan dan akses data di seluruh perangkat Apple kamu.
  🗂️ Property Tambahan (Planned) — Tambahkan label, checkbox, atau status seperti di Notion.
  🔍 Pencarian Cepat (Planned) — Cari task berdasarkan judul atau properti lainnya.

📱 Teknologi yang Digunakan
  SwiftUI — Tampilan modern dan reaktif.
  VIPER Architecture — Modular, scalable, dan testable.
  Combine — Reactive programming untuk data binding dan event-driven updates.
  Core Data — Penyimpanan lokal dengan integrasi ke iCloud.
  iCloud — Sinkronisasi lintas perangkat (on progress).

🏗️ Instalasi & Setup
  Persyaratan
    Xcode 15+
    iOS 16.0+
    macOS Ventura (untuk pengembangan iCloud)

  Akun Apple Developer (gratis cukup untuk iCloud testing)

🌐 API dan Backend (Opsional)
  Untuk versi mendatang, Tidy Notes berencana mendukung API eksternal. Beberapa opsi gratis yang sedang dipertimbangkan untuk backend dan sync tambahan:
    Supabase — Open source Firebase alternative
    Appwrite — Backend server self-hosted/cloud
    Firebase Free Tier — Cocok untuk push notification dan storage

📦 Struktur Arsitektur (VIPER + Combine)
  Proyek ini mengadopsi arsitektur VIPER untuk setiap fitur (modul), dengan Combine sebagai media komunikasi antar layer. Contoh:
    View ←→ Presenter ←→ Interactor ←→ Repository/Service
               ↑               ↓
             Router         Entity/Model

📸 Screenshot
(Akan ditambahkan nanti untuk tampilan task list, form, dll)


🤝 Kontribusi
  Masih dalam pengembangan awal, namun jika kamu tertarik berkontribusi:
  Gunakan SwiftLint (planned) untuk standar kode
  Pull Request sangat diterima!

📄 Lisensi
MIT License — bebas digunakan, diubah, dan dikembangkan ulang.

