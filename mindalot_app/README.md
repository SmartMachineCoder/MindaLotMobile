# MindALot — Flutter POC

Mental Health & Wellness Mobile Application  
Built by MIGS for Zenit / Jagrati Education

---

## What's in this POC

| Feature | Status |
|---------|--------|
| Splash screen with breathing animation | ✅ |
| 3-slide onboarding | ✅ |
| Welcome screen with hidden counsellor triple-tap | ✅ |
| Login screen (username + password, cloud background) | ✅ |
| Register screen (anonymous alias) | ✅ |
| Home screen with mood selector | ✅ |
| Mood-responsive theme (5 moods × colour + background) | ✅ |
| Mood lock timer + lock banner | ✅ |
| Animated mood backgrounds (custom painter) | ✅ |
| Audio service (plays mood music, mute toggle) | ✅ |
| User chat screen with 5-min free timer | ✅ |
| Crisis helpline screen on session cutoff | ✅ |
| Counsellor login (hidden — triple-tap logo) | ✅ |
| Counsellor dashboard (waiting + active sessions) | ✅ |
| Counsellor chat screen (accept, reply, delete, end) | ✅ |
| Firebase Firestore for real-time chat | ✅ (needs config) |
| Firebase Auth for counsellor login | ✅ (needs config) |
| Push notifications (FCM) | 🔜 Next sprint |
| Call booking screen | 🔜 Next sprint |
| Knowledge Hub | 🔜 Next sprint |
| Subscription / Payment (Razorpay, BillDesk) | 🔜 Next sprint |

---

## Project Structure

```
lib/
├── main.dart                          ← App entry, providers, routes
├── firebase_options.dart              ← Firebase config (replace with real values)
├── core/
│   ├── models/
│   │   ├── mood.dart                  ← MoodType enum, MoodConfig, MoodData
│   │   └── message.dart               ← ChatMessage, ChatSession models
│   ├── services/
│   │   ├── mood_provider.dart         ← Mood state + lock logic (ChangeNotifier)
│   │   ├── audio_service.dart         ← Mood music playback (singleton)
│   │   ├── chat_service.dart          ← Firestore chat CRUD
│   │   ├── auth_service.dart          ← Firebase Auth + alias storage
│   │   └── counsellor_provider.dart   ← Counsellor state (ChangeNotifier)
│   └── theme/
│       └── app_theme.dart             ← ThemeData + mood-adaptive theme
├── features/
│   ├── splash/
│   │   ├── splash_screen.dart         ← Breathing blob animation
│   │   ├── onboarding_screen.dart     ← 3-slide onboarding
│   │   └── welcome_screen.dart        ← Entry screen + triple-tap hidden login
│   ├── auth/
│   │   ├── login_screen.dart          ← Username/password login
│   │   └── register_screen.dart       ← Alias registration (anonymous)
│   ├── home/
│   │   ├── home_screen.dart           ← Main home screen
│   │   └── widgets/
│   │       ├── mood_background.dart   ← Animated mood background painter
│   │       ├── mood_selector.dart     ← 5 emoji mood buttons
│   │       └── mood_lock_banner.dart  ← Active mood + countdown
│   ├── chat/
│   │   └── user_chat_screen.dart      ← User chat + freemium timer + crisis box
│   └── counsellor/
│       ├── counsellor_login_screen.dart   ← Hidden counsellor login
│       ├── counsellor_dashboard.dart      ← Waiting + active sessions
│       └── counsellor_chat_screen.dart    ← Counsellor chat UI
assets/
├── animations/   ← Lottie JSON files (see animations/README.md)
├── audio/        ← MP3 mood files (see audio/README.md)
└── images/       ← Emoji and mascot images
```

---

## Step 1 — Install Flutter

1. Download Flutter SDK: https://docs.flutter.dev/get-started/install/windows
2. Extract to `C:\src\flutter`
3. Add `C:\src\flutter\bin` to your PATH
4. Run: `flutter doctor` — fix any issues shown

---

## Step 2 — Set Up Firebase

1. Go to https://console.firebase.google.com
2. Create project: **mindalot**
3. Enable these services:
   - **Authentication** → Email/Password provider (for counsellors)
   - **Firestore Database** → Start in test mode
   - **Storage** → Start in test mode (for mood assets)
4. Add Android app: package `com.migs.mindalot`
5. Add iOS app: bundle ID `com.migs.mindalot`
6. Install FlutterFire CLI:
   ```
   dart pub global activate flutterfire_cli
   ```
7. Run in the project folder:
   ```
   flutterfire configure
   ```
   This auto-generates `lib/firebase_options.dart` with your real credentials.

---

## Step 3 — Add a Test Counsellor

In Firebase Console → Firestore, create:

**Collection: `counsellors`**
```
Document ID: (auto or use Firebase Auth UID)
Fields:
  name: "Test Counsellor"
  email: "counsellor@mindalot.com"
  role: "counsellor"
```

In Firebase Console → Authentication → Add user:
- Email: `counsellor@mindalot.com`  
- Password: `test1234`

---

## Step 4 — Add Firestore Security Rules (Test Mode)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;  // POC only — tighten before production
    }
  }
}
```

---

## Step 5 — Add Mood Assets

- Place Lottie JSON files in `assets/animations/` (see README in that folder)
- Place MP3 audio files in `assets/audio/` (see README in that folder)

---

## Step 6 — Run the App

```bash
cd "Mobile Apps/MindALot/mindalot_app"
flutter pub get
flutter run
```

For a specific device:
```bash
flutter devices          # list connected devices
flutter run -d <device>  # run on specific device
```

---

## How the Hidden Counsellor Login Works

1. On the **Welcome screen** or **Login screen**, tap the **logo/cloud mascot 3 times quickly**
2. The counsellor login page appears (no visible button or link)
3. Login with counsellor credentials
4. Redirected to Counsellor Dashboard

---

## Mood Theme Map

| Mood | Background | Colours | Music |
|------|-----------|---------|-------|
| Happy | Golden sunrise meadow | Gold #F5C842 | Birdsong + guitar |
| Sad | Cosy rain + candlelight | Amber #D4845A | Piano + rain |
| Anxious | Forest canopy | Green #7DBF8E | Forest + binaural beats |
| Frustrated | Open ocean waves | Blue #2E6E8E | Ocean rhythm |
| Confused | Starry cosmos | Lavender #9B7FD4 | Bach/Mozart |

---

## Environment Variables Needed

Create `.env` or configure in your CI:
```
FIREBASE_PROJECT_ID=mindalot
RAZORPAY_KEY_ID=rzp_test_xxxx        (for payment sprint)
BILLDESK_MERCHANT_ID=xxxx            (for payment sprint)
```

---

## Next Sprint (Post-POC)

1. Push notifications via FCM (counsellor chime)
2. Call booking screen
3. Knowledge Hub
4. Razorpay + BillDesk payment integration
5. Admin dashboard (in-app or web)
6. Subscription management
