# Nama Aplikasi Booth-Art - Flutter Application

<div align="center">
<url>
  <img src="https://lms.global.ac.id/lms/pluginfile.php/1/theme_klass/footerlogo/1745232397/logo-global-institute-stroke.png" alt="Institut Teknologi dan Bisnis Bina Sarana Global" width="200"/>
  </div>
<div align="center">
Institut Teknologi dan Bisnis Bina Sarana Global <br>
FAKULTAS TEKNOLOGI INFORMASI & KOMUNIKASI 
<br>
https://global.ac.id/
  </div>

  ##  Project UAS
  - Mata Kuliah : Aplikasi Mobile
  - Kelas : TI SE M & SH 23 
  - Semester : GANJIL 
  - Tahun Akademik: 2025 - 2026 
  
  

## About The Project

Booth-Art adalah aplikasi mobile modern yang dikembangkan menggunakan Flutter untuk membantu orang-orang berkreasi dengan gaya foto dengan beberapa frame yang menarik, menyediakan antarmuka yang intuitif, fitur sinkronisasi cloud menggunakan firebase authentication , firebase store, google cloud, supabase storage dan Firebase Cloud Messaging.

### Key Features

- **Modern UI/UX Design** - Antarmuka yang clean dan user-friendly.
- **Frame creative** - Menyediakan beberapa freame free untuk berkreasi dengan foto dari galeri 
                       atau di ambil langsung dari kamera.
- **Sign-Google** - Memberikan kenyamanan dan ke aman an untuk user yg menggunakan aplikasi.
- **Push Notifications** - Menggunakan local notification & firbase cloud untuk menangani notifikasi
                           yang interaktive.
- **Cloud Sync** - Sinkronisasi otomatis dengan Firebase
- **Thema modern** - Ui yg menarik untuk aplikasi mudah di gunakan untuk user awam

## Screenshots

<div align="center">
  <img src="assets/screenshots/splash_screen.jpeg" alt="Splash Screen1" width="200"/>
  <img src="assets/screenshots/splash_screen2.jpeg" alt="Splash Screen2" width="200"/>
  <img src="assets/screenshots/splash_screen3.jpeg" alt="Splash Screen3" width="200"/>
  <img src="assets/screenshots/splash_screen4.jpeg" alt="Splash Screen4" width="200"/>
  <img src="assets/screenshots/splash_screen5.jpeg" alt="Splash Screen5" width="200"/>
  <img src="assets/screenshots/register.jpeg" alt="Register" width="200"/>
  <img src="assets/screenshots/login_auth_mail.jpeg" alt="Login" width="200"/>
  <img src="assets/screenshots/login_auth_google.jpeg" alt="Login_Google" width="200"/>
  <img src="assets/screenshots/lottie_screen.jpeg" alt="Lottie" width="200"/>
</div>

<div align="center">
  <img src="assets/screenshots/home_page_karya.jpeg" alt="Home_karya" width="200"/>
  <img src="assets/screenshots/home_page_post.jpeg" alt="Home_postingan" width="200"/>
  <img src="assets/screenshots/explore.jpeg" alt="Explore" width="200"/>
  <img src="assets/screenshots/detail_postingan.jpeg" alt="Detail_postingan" width="200"/>
  <img src="assets/screenshots/following.jpeg" alt="Following" width="200"/>
  <img src="assets/screenshots/profile_detail.jpeg" alt="Profile_detail" width="200"/>
  <img src="assets/screenshots/info.jpeg" alt="Info" width="200"/>
  <img src="assets/screenshots/info_dev.jpeg" alt="Info_Dev" width="200"/>
  <img src="assets/screenshots/profile_page.jpeg" alt="Profile" width="200"/>
  <img src="assets/screenshots/settings_profile.jpeg" alt="Profile_settings" width="200"/>
  <img src="assets/screenshots/list_mengikuti.jpeg" alt="following" width="200"/>
  <img src="assets/screenshots/list_pengikut.jpeg" alt="followers" width="200"/>
</div>

<div align="center">
  <img src="assets/screenshots/classic2.jpeg" alt="Frame 2" width="200"/>
  <img src="assets/screenshots/classic4.jpeg" alt="Frame 4" width="200"/>
  <img src="assets/screenshots/vintage.jpeg" alt="Vintage" width="200"/>
  <img src="assets/screenshots/Camera.jpeg" alt="Opsi Camera" width="200"/>
  <img src="assets/screenshots/take_foto.jpeg" alt="Photo" width="200"/>
  <img src="assets/screenshots/crop_foto.jpeg" alt="Crop Photo" width="200"/>
  <img src="assets/screenshots/opsi_edit.jpeg" alt="Edit photo" width="200"/>
  <img src="assets/screenshots/next_frame.jpeg" alt="Next Frame" width="200"/>
</div>

## Demo Video

Lihat video demo aplikasi kami untuk melihat semua fitur dalam aksi!

**[Watch Full Demo on YouTube](https://youtube.com/watch?v=dQw4w9WgXcQ)**

Alternative link: **[Google Drive Demo](https://drive.google.com/file/d/1234567890/view)**

## Download APK

Download versi terbaru aplikasi Notes App:

### Latest Release v1.0.0
- [**Download APK (64.2MB)**](https://github.com/yourusername/notes-app/releases/download/v1.0.0/notes-app-v1.0.0.apk)


**Minimum Requirements:**
- Android 6.0 (API level 23) or higher
- ~20MB free storage space

## Built With

- **[Flutter](https://flutter.dev/)** - UI Framework
- **[Dart](https://dart.dev/)** - Programming Language
- **[Firebase](https://firebase.google.com/)** - Backend & Authentication
- **[Supabase](https://supabase.com/)** - Storage Database
- **[Provider](https://pub.dev/packages/provider)** - State Management


## Getting Started

### Prerequisites

Pastikan Anda sudah menginstall:
- Flutter SDK (3.16.0 or higher)
- Dart SDK (3.2.0 or higher)
- Android Studio / VS Code
- Git

### Installation

1. Clone repository
```bash
git clone https://github.com/muhamadayeshaaulia/project_kelompok.git
cd project_kelompok
```

2. Install dependencies
```bash
flutter pub get
```

3. Setup Firebase
```bash
# Download google-services.json dari Firebase Console
# Place in android/app/
cp path/to/google-services.json android/app/
```
4. Setup Supabase
```bash
# Untuk membuat file .env
# cp .env .env.example
# isi dari .env 
# 1. buka supabase
# 2. masuk ke project mu/buat project baru
# 3. setelah masuk dashboard cari menu project settings
# 4. cari DATA API di situ cari URL untuk supabase mu
# 5. buka API keys masih di dalam project settings
# 6. setelah buka API keys cari menu Legacy anon, service_role API keys
# 7. cari anon public key supabase mu dan salin tempelkan di .env
SUPABASE_URL=LINK_SUPABASE_URL_KAMU
SUPABASE_ANON_KEY=ISI_DENGAN_ANON_KEY_SUPABASE_DISINI
cp .env .env.example
```

5. Service Account
```bash
# Akun layanan Firebase Anda dapat digunakan untuk mengautentikasi beberapa fitur Firebase, seperti Database, Penyimpanan, dan Autentikasi, secara terprogram melalui SDK Admin terpadu
# buka firebase
# login/buat project
# setelah masuk project dashboard cari icon gir dan klik project settings
# setelah di project settings cari service account
# scroll kebawah dan klik generate new private key
# TODO: untuk menangani firebase cloud messaging
# hasil download an di taro di assets/json

cd project_kelompok
mkdir -p assets/json

// jangan lupa di pubspec.yaml
// flutter:
  assets:
    - assets/json/
```

6. Run aplikasi
```bash
flutter run
```

### Build APK

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# Split APK by ABI
flutter build apk --split-per-abi
```

## 📁 Project Structure

```
lib/
├── main.dart               # Entry point
├──  firebase_option.dart      
├── screens/                  # UI Screens
│      ├── login.dart
│      ├── register.dart
│      ├── camera_page.dart
│      ├── explor.dart
│      ├── home_page.dart
│      ├── following_page.dart
│      ├── info_page.dart
│      ├── splash_screen.dart
│      ├── splash_screen1.dart
│      ├── splash_screen2.dart
│      ├── splash_screen3.dart
│      ├── splash_screen4.dart
│      ├── splash_screen5.dart
│      ├── profile_page.dart
│      ├── terms_conditions_page.dart
│      ├── privacy_policy_page.dart
│      └── member_card.dart
├── widgats/                            # Reusable widgets
│   └── custom_buttom_nav.dart          # agar button tinggal di panggil, 
│                                         bottomNavigationBar: const CustomButtomNav(currentIndex: 
│                                          index) di setiap page yg ingin di gunakan
├── services/                           # Business logic
│   ├── auth_service.dart
│   ├── notification_service.dart
│   └── notification_service.dart
├── template/                           # UI template untuk membuat beberapa frame untuk foto
│    ├── photoboothpage.dart
│    ├── photoboothpage2.dart
│    └── template_vintage.dart  
│
├── detail/                             # UI untuk detail postingan profile dan setting profil dan 
│     │                                    user following list
│     ├── postingan.dart
│     ├── ProfilDetail.dart
│     └── user_list_page.dart  
└── member/                             # UI yg berbeda-beda untuk detail profile developer
    ├── profil_ayesha.dart
    ├── profil_arifin.dart
    ├── profil_ilham.dart
    └── profil_rozak.dart                  
```

## Authentication Flow

```
1. Splash Screen (Auto-login check)
   ↓
2. Login Screen / Register Screen / Login Auth Google
   ↓
3. Home Screen (Dashboard)
   ↓
4. Profile & Settings
```

## 🗄️ Database Schema

### Notes Table
```json
{
  {
  "collection": "users",
  "fields": {
    "alamat": "string",
    "email": "string",
    "fcmToken": "string",
    "jenis_kelamin": "string",
    "kelas": "string",
    "keterangan": "string",
    "nama": "string",
    "nama_lengkap": "string",
    "nim": "string",
    "no_hp": "string",
    "photo_url": "string",
    "role": "string",
    "search_keywords": "array<string>",
    "sosmed_link": "string",
    "uid": "string"
  },
  "subcollections": {
    "followers": {
      "documentId": "uid_pengikut",
      "fields": {
        "uid": "string",
        "timestamp": "timestamp (opsional)"
      }
    },
    "following": {
      "documentId": "uid_diikuti",
      "fields": {
        "uid": "string",
        "timestamp": "timestamp (opsional)"
      }
    }
  }
},
  "posts": {
    "{post_id}": {
      "uid": "string (owner uid)",
      "nama": "string",
      "post_image": "string (URL)",
      "user_image": "string (URL)",
      "template_type": "string",
      "views": "number",
      "timestamp": "Date",

      "comments": {
        "{comment_id}": {
          "uid": "string",
          "username": "string",
          "user_image": "string",
          "text": "string",
          "timestamp": "Date"
        }
      },
      "likes": {
        "{uid}": true
      }
    }
  }
}

```
# structure firebase
```
users
 └── {uid}
      ├── (fields...)
      └── followers (SUBCOLLECTION)
      └── following (SUBCOLLECTION)

posts
 └── {postId}
      ├── (fields...)
      ├── comments (subcollection)
      │     └── {commentId}
      └── likes (subcollection)
            └── {likeUid}

```

# structure supabase storage
```
storage
└── buckets
    └── photos (PUBLIC)
        ├── profile
        │   └── {user_id}
        │       └── profile.png
        │
        └── uploads
            └── {user_id}
                ├── C2_strip_1767463595287.png
                ├── C2_strip_17678569329.png
                ├── vintage_strip_1767463868.png

```


## 📝 API Documentation

### Authentication Endpoints
- `POST /api/auth/register` - Register user baru
- `POST /api/auth/login` - Login user
- `POST /api/auth/logout` - Logout user
- `GET /api/auth/verify` - Verify token

### Development Workflow

1. Fork repository
2. Create feature branch (`git checkout -b feature/splash_screen`)
3. Commit changes (`git commit -m "menambahkan splash_screen"`)
4. Push to branch (`git push origin feature/splash_screen`)
5. Open Pull Request

## Team Members & Contributions

### Development Team

| Name | Role | Contributions |
|------|------|---------------|
| **Muhamad Ayesha Aulia** | Project Lead & Full stack dev in Solved project | - Authentication system<br>- Firebase integration<br>- API development<br>- UI Fiture Home,post,detail pots,list_user,profile_detail, profile_page,splash1,lottie, screen, button nav implementation <br>- Notification system<br>- Push notifications (FCM)<br>- Google Auth Sign-in <br>-Solved Problem Project tim|
| **Muhamad Ilham Maulana** | Full stack dev | - UI Design<br>- Home,post,detail pots,list_user,profile_detail,camera_page_frame4_template screen implementation<br>- Profile screen<br>- Frame template |
| **Muhammad Abdul Rozak** | Frontend Developer | - Auth login,logout <br>- login,splash_screen3,home button nav add, frame_template_vintage screen |
| **Muhammad Arifin** | Frontend Developer | - Info,follow, profile,screen4 screen


## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.



## Acknowledgments

Terima kasih kepada komunitas dan layanan berikut yang membantu dalam pengembangan aplikasi ini:

### 🛠 Framework & Layanan Backend
- Flutter — framework utama aplikasi
- Firebase — backend services (Auth, Firestore, Messaging, Notifications)
- Supabase — database & authentication
- Google APIs — integrasi layanan Google

### 🎨 UI & Animations
- Lottie — animasi JSON
- FontAwesome — ikon tambahan
- Cupertino Icons — ikon iOS

### 📸 Media & Storage
- Image Picker — mengambil gambar
- Image Cropper — crop gambar
- Screenshot — capture widget
- Camera — kamera device
- Camera Windows — support kamera Windows
- Gal — penyimpanan gallery
- Share Plus — share ke sosmed
- Path Provider — akses direktori
- Path — utilitas path

### 🌐 Networking & Utils
- HTTP — jaringan REST API
- Intl — formatting tanggal & angka
- URL Launcher — buka link eksternal
- Permission Handler — izin aplikasi
- Flutter Dotenv — dukungan file `.env`

### 📦 Komunitas & Resource
- Flutter Community — dokumentasi & package
- Flaticon — sumber icon aplikasi
- Unsplash — placeholder images


<div align="center">
  <p>Made with by 716 Production Team</p>
  <p>© 2026 Booth-Art. All rights reserved.</p>
</div>