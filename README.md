# Wargaku — Aplikasi Manajemen RT

Aplikasi mobile berbasis Flutter untuk meningkatkan keamanan dan koordinasi warga di tingkat RT. Fitur utama adalah **Panic Button** — tombol darurat yang mengirim notifikasi sirine ke seluruh warga se-RT dalam waktu < 3 detik, bahkan menembus mode DND (Do Not Disturb).

## Tech Stack

| Layer | Teknologi |
|-------|-----------|
| Frontend | Flutter SDK ^3.9.0 |
| Backend | Firebase Cloud Functions v2 (Node.js) |
| Database | Cloud Firestore |
| Auth | Firebase Authentication (Phone + Password) |
| Push Notification | FCM High-Priority + Awesome Notifications |
| Storage | Firebase Storage (avatar) |
| Platform | Android (Min API 26 / Oreo) |

## Struktur Project

```
warga_jatiasih/
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── services/
│   │   │   ├── auth_service.dart
│   │   │   ├── panic_service.dart
│   │   │   └── notification_service.dart
│   │   └── theme/
│   │       ├── app_theme.dart
│   │       └── app_colors.dart
│   └── features/
│       ├── auth/
│       │   └── login_screen.dart
│       ├── home/
│       │   └── dashboard_screen.dart
│       ├── emergency/
│       │   ├── sos_countdown_screen.dart
│       │   ├── alarm_received_screen.dart
│       │   ├── siren_broadcast_screen.dart
│       │   └── battery_permission_sheet.dart
│       ├── log/
│       │   └── log_screen.dart
│       ├── admin/
│       │   ├── admin_screen.dart
│       │   └── admin_add_user_screen.dart
│       └── navigation/
│           └── main_shell.dart
├── firebase/
│   ├── firebase.json
│   ├── firestore.rules
│   └── functions/
│       ├── index.js
│       ├── seed_admin.js
│       └── package.json
├── android/
├── test/
└── pubspec.yaml
```

## Fitur

### 1. Panic Button (Emergency Alert)
- Tekan tombol → konfirmasi countdown 3 detik → kirim alert
- Notifikasi FCM High-Priority ke semua warga se-RT
- Sirine override DND (mode senyap/getar tetap berbunyi)
- GPS location tracking (dengan fallback jika tidak tersedia)
- Rate limiting: 1 alert / 60 detik per user

### 2. Admin Panel
- Akses khusus role `ADMIN` (Ketua RT / Pengurus)
- Pendaftaran warga baru (Kepala Keluarga & Anggota Keluarga)
- Daftar warga dalam tree view (KK → Anggota)
- Resolve panic alert + broadcast notifikasi "Situasi Aman"

### 3. Role & Hierarki Keluarga

| Role | Sub-Role | Akses |
|------|----------|-------|
| ADMIN | — | Full access (kelola warga, resolve alert, config) |
| WARGA | KEPALA_KELUARGA | Panic button, lihat info RT |
| WARGA | ANGGOTA_KELUARGA | Panic button, lihat info RT |

## Setup & Instalasi

### Prerequisites
- Flutter SDK ^3.9.0
- Android Studio / VS Code
- Firebase project (Blaze plan untuk Cloud Functions)
- Node.js (untuk Cloud Functions)

### 1. Clone & Install Dependencies

```bash
git clone <repository-url>
cd warga_jatiasih
flutter pub get
```

### 2. Firebase Setup

```bash
# Install Firebase CLI
npm install -g firebase-tools
firebase login

# Deploy Cloud Functions
cd firebase
npm install --prefix functions
firebase deploy --only functions

# Deploy Firestore Rules
firebase deploy --only firestore:rules
```

### 3. Seed Admin Account

```bash
cd firebase/functions
node seed_admin.js
```

### 4. Run App

```bash
flutter run
```

## Arsitektur

```
┌─────────────────────────────────┐
│         Flutter Client           │
│  UI → Features → Core Services  │
└──────────────┬──────────────────┘
               │
               ▼
┌─────────────────────────────────┐
│       Firebase Backend           │
│  Auth │ Firestore │ Functions   │
│  FCM  │ Storage                 │
└─────────────────────────────────┘
```

### Flow Panic Button
```
Warga tekan → Firestore write (panic_logs)
  → Cloud Function trigger
    → Query fcm_tokens warga se-RT
      → sendEachForMulticast (High-Priority)
        → Device terima → Sirine DND Override
```

## Database Schema

### `/users/{userId}`
```json
{
  "name": "string",
  "phone_number": "+62xxx",
  "house_number": "B-12",
  "rt_id": "RT_SETIABUDI_005",
  "role": "ADMIN | WARGA",
  "family_role": "KEPALA_KELUARGA | ANGGOTA_KELUARGA",
  "family_id": "FAM_B12_001",
  "status": "VERIFIED | PENDING",
  "fcm_tokens": [{ "token": "...", "device_id": "...", "updated_at": "..." }],
  "last_panic_at": "timestamp | null",
  "avatar_url": "url | null"
}
```

### `/panic_logs/{panicId}`
```json
{
  "user_id": "string",
  "user_name": "string",
  "house_number": "string",
  "rt_id": "string",
  "location": { "latitude": 0.0, "longitude": 0.0, "source": "GPS | LAST_KNOWN | UNAVAILABLE" },
  "timestamp": "ISO8601",
  "status": "ACTIVE | RESOLVED",
  "resolved_by": "userId | null",
  "resolved_at": "timestamp | null"
}
```

## Dokumentasi

| File | Deskripsi |
|------|-----------|
| [PRD_WARGAKU_v1.2.md](PRD_WARGAKU_v1.2.md) | Product Requirement Document (lengkap) |
| [PMO_SPRINT_BACKLOG_WARGAKU.md](PMO_SPRINT_BACKLOG_WARGAKU.md) | Sprint Backlog & WBS |
| [REVIEW_TASKS.md](REVIEW_TASKS.md) | PMO Review Findings |

## License

Private — Internal RT Project
