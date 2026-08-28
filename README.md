# 🗺️ MEMOtrip — Smart Travel Planner & Memory Keeper with IoT Monitoring

MEMOtrip adalah aplikasi perencana perjalanan pintar dan penyimpan memori perjalanan yang terintegrasi dengan pemantauan IoT secara real-time dan prakiraan cuaca dari BMKG. Aplikasi ini dirancang khusus untuk memandu wisatawan saat menjelajahi berbagai destinasi wisata menarik (seperti di area Makassar), merencanakan rencana perjalanan (itinerary) secara cerdas, menyimpan kenangan liburan secara terorganisir, serta memantau kondisi lingkungan secara real-time dari sensor IoT di lokasi wisata.

Aplikasi ini dibangun menggunakan framework **Flutter** dengan pendekatan **Clean Architecture** (Data, Domain, Presentation) dan manajemen state **Riverpod**.

---

## 📌 Daftar Isi
1. [Deskripsi Proyek (Untuk Orang Awam)](#-deskripsi-proyek-untuk-orang-awam)
   - [Tujuan Aplikasi](#tujuan-aplikasi)
   - [Fitur Utama](#fitur-utama)
2. [Spesifikasi Teknis & Arsitektur (Untuk Developer)](#%EF%B8%8F-spesifikasi-teknis--arsitektur-untuk-developer)
   - [Struktur Folder & Clean Architecture](#struktur-folder--clean-architecture)
   - [Aliran Data & Diagram Arsitektur](#aliran-data--diagram-arsitektur)
   - [Manajemen State (Riverpod)](#manajemen-state-riverpod)
   - [Layanan & Integrasi Pihak Ketiga](#layanan--integrasi-pihak-ketiga)
3. [Panduan Instalasi & Memulai Pengembangan](#-panduan-instalasi--memulai-pengembangan)
   - [Prasyarat](#prasyarat)
   - [Langkah Instalasi](#langkah-instalasi)
   - [Menjalankan Aplikasi](#menjalankan-aplikasi)
   - [Pengujian (Testing)](#pengujian-testing)
4. [Panduan Kontribusi & Best Practices](#%EF%B8%8F-panduan-kontribusi--best-practices)

---

## 👥 Deskripsi Proyek (Untuk Orang Awam)

### Tujuan Aplikasi
Bagi sebagian besar pelancong, merencanakan liburan terkadang menyulitkan karena harus mencari informasi cuaca setempat, memantau kepadatan di destinasi target agar tidak terjebak keramaian yang berlebihan, serta mengorganisir jadwal perjalanan agar liburan tetap efisien. MEMOtrip hadir untuk memecahkan masalah ini dengan menyediakan satu platform terpadu untuk:
- Merencanakan rute/jadwal perjalanan wisata.
- Mengetahui cuaca terkini secara akurat langsung dari BMKG.
- Memantau keramaian dan kondisi cuaca mikro di lokasi tujuan menggunakan sensor IoT.
- Mengabadikan foto kenangan liburan yang dikategorikan secara rapi.

### Fitur Utama
* **Dashboard Adaptif (Condition A / B)**:
  * **Kondisi A (Cuaca Lokal)**: Menampilkan prakiraan cuaca lokal berdasarkan lokasi geografis pengguna (diintegrasikan secara real-time dengan BMKG).
  * **Kondisi B (IoT Mode)**: Memantau data telemetri IoT (Suhu, Kelembaban, Tekanan Udara) dari sensor BME280 dan foto kondisi keramaian terkini dari kamera ESP32-CAM di destinasi tertentu (contoh: Pantai Losari, CPI Makassar, Masjid 99 Kubah).
* **Early Warning System (EWS)**: Fitur keamanan otomatis yang mendeteksi jika suhu di lokasi wisata melebihi 35°C, lalu mengubah tampilan antarmuka menjadi peringatan merah agar wisatawan bersiap dengan pelindung panas atau menghindari area terbuka tersebut.
* **Smart Travel Planner**: Membantu pengguna merancang rencana liburan (itinerary), menambahkan destinasi, menjadwalkan tanggal dan jam kunjungan, serta menulis catatan khusus untuk setiap perhentian perjalanan.
* **Memory Keeper Gallery**: Galeri digital untuk mengunggah foto liburan, menuliskan cerita perjalanan, memilih kategori, dan memberikan peringkat (rating). Data disimpan secara aman di cloud Firebase.
* **360-Degree Panorama VR View**: Memungkinkan pengguna melihat pemandangan panorama 360 derajat dari destinasi wisata secara imersif (virtual reality) sebelum mereka berkunjung secara fisik.
* **Fitur Khusus Admin**: Panel kontrol admin untuk mengelola pengguna, menyetujui/memoderasi ulasan komunitas, melihat grafik analitik destinasi yang sedang tren, dan memantau status perangkat sensor IoT.

---

## 🛠️ Spesifikasi Teknis & Arsitektur (Untuk Developer)

MEMOtrip dirancang menggunakan prinsip **Clean Architecture** untuk memastikan kode dapat diuji secara terpisah (testable), mudah dirawat (maintainable), dan mudah dikembangkan oleh developer baru.

### Struktur Folder & Clean Architecture

Kode sumber di dalam folder `lib/` dibagi menjadi beberapa bagian utama:

```
lib/
├── app/                  # Konfigurasi aplikasi utama (Themes, Routing, Auth Gate)
│   ├── app.dart          # Root widget MaterialApp dan shell utama (AppShell)
│   ├── auth_gate.dart    # Pintu gerbang autentikasi dengan splash screen animasi
│   ├── routes.dart       # Pengaturan navigasi named routes & route guarding
│   └── theme.dart        # Konfigurasi sistem tema terang (light theme)
│
├── core/                 # Komponen yang dibagikan dan digunakan di seluruh fitur (Shared)
│   ├── constants/        # Warna, spacing, string, dan tipografi aplikasi
│   ├── enums/            # Koleksi enum global (misalnya status lokasi izin)
│   ├── providers/        # Provider global seperti penentuan hak akses role (Admin/User)
│   ├── services/         # Integrasi API/SDK (Auth, BMKG Weather, Location, IoT, Notification)
│   ├── utils/            # Helper format tanggal, transisi halaman, dll.
│   └── widgets/          # Komponen UI global (BMKG Weather Card, Sensor Card, Custom Gauge, dll.)
│
└── features/             # Modul fungsional berdasarkan fitur bisnis aplikasi
    ├── admin/            # Presentasi Panel Admin (Moderasi, Analytics, Device Control, Users)
    ├── auth/             # Login, Register, Input Shake Feedback, integrasi Social Auth
    ├── dashboard/        # Beranda dengan dashboard adaptif cuaca/IoT Makassar
    ├── destination/      # Jelajah destinasi, pencarian, detail, 360° VR View
    ├── profile/          # Profil pengguna, Riwayat Kunjungan, Bookmark, Memory Keeper Gallery
    └── schedule/         # Planner itinerary cerdas (CRUD jadwal & item jadwal perjalanan)
```

Setiap fitur dalam `features/` (kecuali admin) dibagi menjadi 3 lapisan (layers):
1. **Data Layer**: Mengurus sumber data (data sources), baik lokal maupun remote (Firestore, Firebase Storage), data transfer objects (models), dan implementasi repository.
2. **Domain Layer**: Berisi logika bisnis inti yang independen dari UI. Terdiri atas Entities (objek bisnis dasar seperti `Destination`, `Schedule`, `TravelMemory`) dan Repositories interface.
3. **Presentation Layer**: Mengurus tampilan UI (pages & widgets) dan manajemen state (providers/notifiers menggunakan Riverpod).

---

### Aliran Data & Diagram Arsitektur

Berikut adalah visualisasi arsitektur dan aliran data pada aplikasi MEMOtrip:

```mermaid
graph TD
    subgraph Presentation Layer [Presentation Layer UI & State]
        UI[Flutter Widgets / Pages]
        Notifier[Riverpod StateNotifiers / StateProviders]
    end

    subgraph Domain Layer [Domain Layer Business Logic]
        Entity[Domain Entities]
    end

    subgraph Data Layer [Data Layer Data & Services]
        RepoImpl[Repository Implementations]
        Service[Core Services / External SDKs]
    end

    subgraph External Sources [External Infrastructure]
        Firebase[Firebase Auth, Firestore, Storage]
        BMKG[BMKG Weather XML/JSON API]
        IoT[BME280 & ESP32-CAM Simulations]
    end

    %% Flow connections
    UI -->|Membaca State & Memicu Aksi| Notifier
    Notifier -->|Memperbarui State| UI
    Notifier -->|Menggunakan/Mendapatkan| Entity
    Notifier -->|Memanggil fungsi| RepoImpl
    RepoImpl -->|Bergantung pada| Service
    Service -->|Komunikasi network/data| External Sources
    RepoImpl -->|Mengonversi Model ke| Entity
```

---

### Manajemen State (Riverpod)

Aplikasi ini menggunakan **Riverpod** untuk manajemen state yang andal dan aman dari bug siklus hidup widget. Contohnya, pada Dashboard:
* `dashboardProvider`: Menggunakan `StateNotifierProvider` untuk mengelola `DashboardState`.
* `DashboardState`: Kelas imutabel yang menampung status pemuatan cuaca, data cuaca dari BMKG, ID lokasi IoT terpilih, data sensor IoT, foto keramaian, status keaktifan sensor, tingkat latensi, dan status penyegaran data.
* Metode di `DashboardNotifier`:
  * `initWeather()`: Memperoleh lokasi perangkat dari `LocationService` lalu memanggil `BmkgWeatherService.fetchWeather()` untuk mendapatkan info cuaca lokal secara dinamis.
  * `refreshIoTData()`: Mensimulasikan delay network 2 detik (menampilkan loading shimmer) lalu memuat pembacaan sensor IoT dinamis.
  * `selectLocation(String? id)`: Mengalihkan tampilan dari **Kondisi A (Prakiraan Cuaca)** ke **Kondisi B (IoT destinasi)**.

---

### Layanan & Integrasi Pihak Ketiga

1. **Autentikasi & Penyimpanan Cloud (Firebase)**:
   * **Firebase Auth**: Mengelola akun pengguna (registrasi, masuk, atur ulang sandi) dan membatasi akses Admin dengan Route Guarding.
   * **Cloud Firestore**: Menyimpan data dinamis seperti informasi destinasi wisata Makassar, review ulasan dari komunitas, memori perjalanan pengguna, serta jadwal perjalanan (itineraries).
   * **Firebase Storage**: Menyimpan foto memori perjalanan yang diunggah pengguna.
2. **Cuaca Real-time (BMKG)**:
   * Diintegrasikan melalui `BmkgWeatherService` yang secara dinamis mengambil data cuaca dari BMKG Indonesia berdasarkan koordinat latitude dan longitude perangkat pengguna.
3. **Simulasi Sensor IoT (ESP32 / BME280)**:
   * `MockIoTService` menyajikan simulator data sensor suhu (28°C - 36°C), kelembapan udara (60% - 90%), tekanan atmosfer (1008 hPa - 1012 hPa), serta data visual keramaian (Crowd Estimation) berupa URL gambar terkurasi dengan klasifikasi kepadatan (Sepi, Sedang, Ramai).
   * **Early Warning System (EWS)** mendeteksi bahaya suhu panas tinggi (> 35°C) untuk keamanan pengguna di lapangan.
4. **Virtual Reality / 360° Panorama**:
   * Menggunakan package `panorama_viewer` yang memungkinkan pengguna memutar gambar 360 derajat secara horizontal maupun vertikal untuk sensasi virtual reality.

---

## 🚀 Panduan Instalasi & Memulai Pengembangan

### Prasyarat
Sebelum memulai, pastikan perangkat Anda telah terinstal tools berikut:
* **Flutter SDK** (versi `>= 3.4.0 < 4.0.0`)
* **Dart SDK**
* **Git**
* Akun dan Project **Firebase** yang sudah aktif.
* **Android Studio** atau **VS Code** dengan ekstensi Flutter/Dart terinstal.

### Langkah Instalasi

1. **Clone Repositori**:
   ```bash
   git clone https://github.com/MuhAlifAnhar/MEMOtrip.git
   cd memotrip
   ```

2. **Dapatkan Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Konfigurasi Firebase**:
   Aplikasi ini memerlukan file kredensial Firebase untuk berjalan. Jalankan perintah `flutterfire configure` menggunakan Firebase CLI untuk menghasilkan file `lib/firebase_options.dart` secara otomatis, atau salin file konfigurasi Firebase Anda ke masing-masing folder platform (Android: `google-services.json`, iOS: `GoogleService-Info.plist`).

4. **Persiapan Aset & Font**:
   Pastikan aset gambar logo dan font Inter sudah tersedia di folder `assets/images/`, `assets/icons/`, dan `assets/fonts/Inter/`.

---

### Menjalankan Aplikasi

* **Menjalankan pada Emulator / Perangkat Asli**:
  Pastikan emulator Android/iOS Anda aktif atau perangkat asli terhubung melalui USB debugging, kemudian jalankan:
  ```bash
  flutter run
  ```
* **Menjalankan pada Web**:
  ```bash
  flutter run -d chrome
  ```

---

### Pengujian (Testing)

Untuk memvalidasi bahwa tidak ada kode yang rusak (broken) setelah Anda melakukan modifikasi, jalankan unit testing dan widget testing menggunakan perintah:
```bash
flutter test
```

---

## 🤝 Panduan Kontribusi & Best Practices

Jika Anda adalah developer baru yang bergabung dalam pengembangan MEMOtrip, mohon perhatikan pedoman berikut:

1. **Patuhi Clean Architecture**:
   * Jangan menulis logika bisnis (seperti panggilan API langsung) di dalam file widget. Selalu gunakan `Provider` atau `Notifier` untuk mengelola state dan memanggil fungsi service.
   * Entitas (`domain/entities`) harus tetap murni tanpa dependensi ke framework Flutter atau Firebase.
2. **Gunakan Linter**:
   * Proyek ini menggunakan aturan linter yang didefinisikan dalam `analysis_options.yaml`. Pastikan tidak ada peringatan (warnings) sebelum melakukan commit kode.
3. **Optimasi Performa Gambar & Memori**:
   * Gunakan widget `AppNetworkImage` (yang membungkus `cached_network_image`) untuk memuat gambar dari internet agar terdapat caching dan transisi shimmer yang mulus saat memuat data.
4. **Peringatan Penting tentang Key / Focus State**:
   * Saat mendesain form input (`TextFormField`), pastikan Anda **tidak mendefinisikan ulang** `TextEditingController` atau memanggil instansiasi `Key` baru di dalam metode `build()` karena akan memicu re-render tak berujung yang menyebabkan kehilangan fokus input (focus loss). Selalu instansiasi controller di `initState` dan hancurkan di `dispose`.

---

Semoga dokumentasi ini mempermudah Anda dalam memahami dan mengembangkan **MEMOtrip**! Selamat berkontribusi! 🚀
