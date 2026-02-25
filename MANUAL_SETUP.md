# 🚀 Setup Manual Project TOPSIS AHASS

## 📋 Overview
Dokumentasi ini berisi langkah-langkah manual yang harus Anda lakukan untuk membuat project TOPSIS AHASS berfungsi dengan Firebase.

---

## 🔥 Langkah 1: Install FlutterFire CLI (Jika Belum)

### 1.1 Cek apakah FlutterFire CLI sudah terinstall
```bash
flutterfire --version
```

### 1.2 Jika belum terinstall, jalankan command berikut:
```bash
dart pub global activate flutterfire_cli
```

### 1.3 Verifikasi instalasi:
```bash
flutterfire --version
```

---

## 🔥 Langkah 2: Buat Project Firebase Baru

### 2.1 Login ke Firebase
```bash
firebase login
```
Akan membuka browser untuk login ke akun Google Anda.

### 2.2 Buat Project Firebase via CLI
Pilih salah satu cara berikut:

**Opsi A: Via Firebase Console (Recommended untuk beginner)**
1. Buka https://console.firebase.google.com/
2. Klik "Add project" atau "Create a project"
3. Masukkan nama project: `topsis-ahass`
4. Klik "Continue" dan ikuti instruksi

**Opsi B: Via Firebase CLI**
```bash
firebase projects:create --display-name="TOPSIS AHASS" --project-id=topsis-ahass
```

---

## 🔥 Langkah 3: Setup Firebase di Project Flutter

### 3.1 Navigate ke Project Folder
```bash
cd C:\Flutter\FlutterProjects\Flutter-Topsis-Ahass
```

### 3.2 Jalankan FlutterFire Configure
```bash
flutterfire configure --project=topsis-ahass
```

Command ini akan:
- Otomatis membuat `firebase_options.dart` dengan konfigurasi project
- Menambahkan konfigurasi untuk Android, iOS, Web, Windows, dll.

### 3.3 Pilih platform yang ingin dikonfigurasi
Saat ditanya, pilih semua platform yang Anda butuhkan:
- ✅ Android
- ✅ iOS (jika Anda pakai Mac dan ingin build iOS)
- ✅ Web
- ✅ Windows

---

## 🔥 Langkah 4: Enable Firestore Database di Firebase Console

### 4.1 Buka Firebase Console
1. Buka https://console.firebase.google.com/
2. Pilih project `topsis-ahass`

### 4.2 Create Firestore Database
1. Di menu sidebar kiri, klik **Build** → **Firestore Database**
2. Klik **Create Database**
3. Pilih location (recommended: `asia-southeast2` untuk Indonesia)
4. Pilih mode: **Start in Test Mode** (untuk development)
5. Klik **Enable**

---

## 🔥 Langkah 5: Setup Firestore Indexes

### 5.1 Create Index untuk username field
Firebase membutuhkan index untuk melakukan query dengan `.where()`.

**Via Firebase Console:**
1. Firebase Console → Firestore → **Indexes** tab
2. Klik **Create Index**
3. Collection: `users`
4. Fields: Tambahkan field `username` (Ascending)
5. Klik **Create**

**Via Firebase CLI:**
Jika Anda sudah install Firebase CLI dan sudah login:

1. Buat file `firestore.indexes.json` di root project:
```json
{
  "indexes": [
    {
      "collectionGroup": "users",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "username",
          "order": "ASCENDING"
        }
      ]
    }
  ],
  "fieldOverrides": []
}
```

2. Deploy indexes:
```bash
firebase deploy --only firestore:indexes
```

---

## 🔥 Langkah 6: Buat Data Users di Firestore

### 6.1 Buka Firestore Data Editor
1. Firebase Console → Firestore → **Data** tab
2. Klik **Start collection**
3. Collection ID: `users`

### 6.2 Tambahkan User Kepala Bengkel (Admin)
Klik **Add document**, masukkan data:

| Field | Type | Value |
|-------|------|-------|
| username | string | `admin` |
| password | string | `admin123` |
| role | string | `admin` |
| isActive | boolean | `true` |
| createdAt | timestamp | *(auto-generate atau isi dengan timestamp)* |

**Auto-generate Document ID** atau custom ID terserah Anda.

### 6.3 Tambahkan User Staff Bengkel
Kembali ke collection `users`, klik **Add document**:

| Field | Type | Value |
|-------|------|-------|
| username | string | `staff` |
| password | string | `staff123` |
| role | string | `staff` |
| isActive | boolean | `true` |
| createdAt | timestamp | *(auto-generate atau isi dengan timestamp)* |

**Catatan:**
- Password dalam format plain text untuk development. Untuk production, harus di-hash.
- Field `role` harus bernilai `admin` atau `staff` (lowercase)
- `isActive: true` untuk mengaktifkan akun

---

## 🔥 Langkah 7: Setup Firestore Security Rules

### 7.1 Buka Firestore Rules
1. Firebase Console → Firestore → **Rules** tab
2. Ganti rules default dengan:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Rules untuk development - BACA SEMUA, TULIS SEMUA
    // Waspada: Ini hanya untuk development!
    match /{document=**} {
      allow read, write: if request.time < timestamp.date(2025, 12, 31);
    }
  }
}
```

3. Klik **Publish**

### 7.2 Rules untuk Production (Opsional - Nanti)
Untuk production, gunakan rules yang lebih secure:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Hanya authenticated user yang bisa read
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null; // atau lebih strict
    }

    // Rules untuk collections lainnya
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## 🔥 Langkah 8: Setup Logo dan Assets (Opsional)

### 8.1 Siapkan Logo AHASS
1. Siapkan logo AHASS dalam format `.jpg` atau `.png`
2. Ganti nama file menjadi `logo_ahass.jpg`
3. Letakkan di folder: `assets/images/`

### 8.2 Pastikan assets sudah ada di pubspec.yaml
Cek file `pubspec.yaml` dan pastikan ada:
```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/images/
```

Jika belum ada, tambahkan section tersebut.

### 8.3 Siapkan Illustration Assets (Opsional)
Untuk tampilan yang lebih menarik, siapkan gambar berikut:
- `hero_topsis.png` - Gambar untuk hero section
- `illustration_topsis.png` - Gambar ilustrasi TOPSIS
- `background.jpg` - Gambar background untuk halaman login

Letakkan semua di folder `assets/images/`.

**Note:** Jika tidak ada gambar, app akan menampilkan fallback icon jadi tetap jalan.

---

## 🔥 Langkah 9: Install Dependencies

### 9.1 Get Dependencies
```bash
flutter pub get
```

### 9.2 Cek apakah ada dependencies yang bermasalah
```bash
flutter doctor
```

Pastikan semua dependencies terinstall dengan benar.

---

## 🔥 Langkah 10: Build dan Run Aplikasi

### 10.1 Untuk Android
```bash
flutter run
```

Atau untuk specific device:
```bash
flutter devices
flutter run -d <device-id>
```

### 10.2 Untuk Windows
```bash
flutter run -d windows
```

### 10.3 Untuk Web
```bash
flutter run -d chrome
```

---

## 🧪 Langkah 11: Testing Login

### Test Login sebagai Admin (Kepala Bengkel)
1. Buka aplikasi
2. Masukkan:
   - Username: `admin`
   - Password: `admin123`
3. Klik "SIGN IN"
4. ✅ Harus redirect ke `adminDashboard`
5. Dashboard akan menampilkan menu "Kelola User" dan "Riwayat"

### Test Login sebagai Staff
1. Logout jika sudah login
2. Masukkan:
   - Username: `staff`
   - Password: `staff123`
3. Klik "SIGN IN"
4. ✅ Harus redirect ke home page
5. Tidak akan melihat menu "Kelola User"
6. Hanya bisa akses fitur staff (Mulai Analisis, Hitung Cepat, Upload Excel)

### Test Session Management
1. Login dengan akun manapun
2. Tutup aplikasi sepenuhnya
3. Buka aplikasi lagi
4. ✅ Harus tetap login (session masih valid selama 24 jam)

### Test Session Expired
1. Login
2. Edit local storage (gunakan DevTools browser atau tool lain)
   - Ubah nilai `login_timestamp` ke timestamp yang lebih dari 24 jam yang lalu
3. Refresh aplikasi atau coba akses protected route
4. ✅ Harus redirect ke halaman login dengan pesan "Session Expired"

---

## 🔧 Troubleshooting

### Masalah: "Firebase has not been initialized"
**Solusi:**
- Pastikan baris `await Firebase.initializeApp(...)` tidak di-comment di `main.dart`
- Pastikan `firebase_options.dart` sudah tergenerate dan terimport dengan benar

### Masalah: "Permission denied" saat login
**Solusi:**
- Cek Firestore security rules di Firebase Console
- Pastikan rules mengizinkan read/write untuk development
- Deploy ulang rules jika perlu

### Masalah: "Username tidak ditemukan" padahal sudah ada
**Solusi:**
- Pastikan Firestore index sudah dibuat untuk field `username`
- Cek nama field di Firestore, harus persis: `username`, `password`, `role`, `isActive`
- Pastikan case-sensitivity: `admin` vs `Admin` (beda)

### Masalah: "Akun tidak aktif" saat login
**Solusi:**
- Cek field `isActive` di Firestore untuk user tersebut
- Pastikan bernilai `true` (boolean, bukan string "true")

### Masalah: Login tidak redirect ke halaman yang benar
**Solusi:**
- Cek field `role` di Firestore
- Pastikan bernilai `admin` atau `staff` (lowercase)
- Restart aplikasi setelah mengubah role di Firestore

### Masalah: Tampilan kosong/blank
**Solusi:**
- Cek console error di DevTools (F12 untuk web)
- Pastikan semua assets sudah ada di folder yang benar
- Cek apakah ada error di log Flutter

---

## 📚 Struktur Data Firestore

### Collection: `users`
```
users
  ├── document_id_1: {
  │     "username": "admin",
  │     "password": "admin123",
  │     "role": "admin",
  │     "isActive": true,
  │     "createdAt": <timestamp>
  │   }
  └── document_id_2: {
        "username": "staff",
        "password": "staff123",
        "role": "staff",
        "isActive": true,
        "createdAt": <timestamp>
      }
```

### Collections Tambahan (untuk fitur TOPSIS)
Nanti saat implementasi fitur TOPSIS, akan ada:
- `items` - Daftar sparepart AHASS
- `kriteria` - Kriteria penilaian TOPSIS
- `analisis` - Hasil perhitungan TOPSIS
- `history` - Riwayat analisis

---

## ✅ Checklist Akhir

Setelah setup selesai, pastikan:

- [ ] FlutterFire CLI sudah terinstall
- [ ] Project Firebase `topsis-ahass` sudah dibuat
- [ ] `firebase_options.dart` sudah tergenerate
- [ ] Firestore Database sudah dibuat
- [ ] Collection `users` sudah dibuat dengan 2 dokumen (admin & staff)
- [ ] Firestore index untuk `username` sudah dibuat
- [ ] Firestore security rules sudah di-publish
- [ ] `flutter pub get` sudah dijalankan
- [ ] Aplikasi bisa di-build dan di-run
- [ ] Login admin berhasil → redirect ke adminDashboard
- [ ] Login staff berhasil → redirect ke home
- [ ] Session management berfungsi (24 jam expiry)

---

## 🎯 Next Steps

Setelah setup selesai dan berhasil login:

1. Implementasi algoritma TOPSIS di module `topsis`
2. Buat collection Firestore untuk data sparepart dan kriteria
3. Implementasi fitur upload Excel
4. Implementasi fitur history/riwayat
5. Implementasi fitur user management (untuk admin)
6. Implementasi fitur quick calculation
7. Testing end-to-end

---

## 📞 Bantuan

Jika mengalami masalah:
1. Cek logs di Flutter DevTools
2. Cek Firebase Console untuk error logs
3. Pastikan semua langkah di atas sudah dilakukan dengan benar
4. Hubungi developer atau cek dokumentasi Firebase: https://firebase.google.com/docs

---

**Selamat menggunakan TOPSIS AHASS! 🎉**
