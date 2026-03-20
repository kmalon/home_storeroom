# Home Storeroom

Flutter app (Android + iOS) to track storeroom inventory. Uses a Google Drive Excel file as a shared database — multiple users on the same Google account see live shared state.

## GCP OAuth Setup (required before first run)

Google requires every app using their APIs to be registered in Google Cloud Console. Having a Gmail account is **not** sufficient for programmatic API access.

### Steps

1. **Create a GCP project**
   - Go to [console.cloud.google.com](https://console.cloud.google.com)
   - Create a new project (e.g. `home-storeroom`)

2. **Enable the Drive API**
   - Navigate to "APIs & Services" → "Library"
   - Search for "Google Drive API" and click "Enable"

3. **Configure OAuth consent screen**
   - "APIs & Services" → "OAuth consent screen"
   - Choose "External" (or "Internal" if using Google Workspace)
   - Fill in app name, support email, developer email
   - Add scope: `https://www.googleapis.com/auth/drive.file`
   - Add your Gmail as a test user (required while app is in testing)

4. **Create OAuth 2.0 Client IDs**

   **Android:**
   - "APIs & Services" → "Credentials" → "Create Credentials" → "OAuth client ID"
   - Application type: **Android**
   - Package name: `com.example.home_storeroom` (match your `applicationId` in `android/app/build.gradle`)
   - SHA-1 certificate fingerprint: run `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android` and copy the SHA-1
   - Download `google-services.json` → place at:
     ```
     android/app/google-services.json
     ```
     > This file is excluded from git (`.gitignore`). You must copy it manually on every machine you build from.

     Example structure (replace placeholders with your GCP values):
     ```json
     {
       "project_info": {
         "project_number": "YOUR_PROJECT_NUMBER",
         "project_id": "YOUR_PROJECT_ID",
         "storage_bucket": ""
       },
       "client": [
         {
           "client_info": {
             "mobilesdk_app_id": "1:YOUR_PROJECT_NUMBER:android:000000000000",
             "android_client_info": {
               "package_name": "com.example.home_storeroom"
             }
           },
           "oauth_client": [
             {
               "client_id": "YOUR_PROJECT_NUMBER-XXXXXXXX.apps.googleusercontent.com",
               "client_type": 1
             }
           ],
           "api_key": [{"current_key": ""}],
           "services": {
             "appinvite_service": {
               "other_platform_oauth_client": []
             }
           }
         }
       ],
       "configuration_version": "1"
     }
     ```
     - `project_number` and `project_id`: found in GCP → Project Settings
     - `client_id`: your Android OAuth client ID from GCP → Credentials
     - `client_type`: always `1` for Android
     - `package_name`: must match `applicationId` in `android/app/build.gradle`

   **iOS:**
   - "APIs & Services" → "Credentials" → "Create Credentials" → "OAuth client ID"
   - Application type: **iOS**
   - Bundle ID: `com.example.homeStoreroom` (match your Xcode bundle ID)
   - Download `GoogleService-Info.plist` → place at:
     ```
     ios/Runner/GoogleService-Info.plist
     ```
     > Also excluded from git — copy manually on each machine.

     Example structure (replace placeholders with your GCP values):
     ```xml
     <?xml version="1.0" encoding="UTF-8"?>
     <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
       "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
     <plist version="1.0">
     <dict>
       <key>CLIENT_ID</key>
       <string>YOUR_PROJECT_NUMBER-XXXXXXXX.apps.googleusercontent.com</string>
       <key>REVERSED_CLIENT_ID</key>
       <string>com.googleusercontent.apps.YOUR_PROJECT_NUMBER-XXXXXXXX</string>
       <key>PROJECT_ID</key>
       <string>YOUR_PROJECT_ID</string>
       <key>STORAGE_BUCKET</key>
       <string></string>
       <key>GOOGLE_APP_ID</key>
       <string>1:YOUR_PROJECT_NUMBER:ios:000000000000</string>
       <key>IS_ADS_ENABLED</key>
       <false/>
       <key>IS_ANALYTICS_ENABLED</key>
       <false/>
       <key>IS_APPINVITE_ENABLED</key>
       <true/>
       <key>IS_GCM_ENABLED</key>
       <false/>
       <key>IS_SIGNIN_ENABLED</key>
       <true/>
       <key>BUNDLE_ID</key>
       <string>com.example.homeStoreroom</string>
     </dict>
     </plist>
     ```
     - `CLIENT_ID`: your iOS OAuth client ID from GCP → Credentials
     - `REVERSED_CLIENT_ID`: reverse the `CLIENT_ID` (e.g. `com.googleusercontent.apps.12345-abc`)
     - `PROJECT_ID` / `PROJECT_NUMBER`: from GCP → Project Settings
     - `BUNDLE_ID`: must match your Xcode bundle identifier

   - Open `ios/Runner/Info.plist`, find `CFBundleURLSchemes` and replace `REVERSED_CLIENT_ID` with the value from the plist
   - Find `GIDClientID` in `Info.plist` and replace `YOUR_IOS_CLIENT_ID` with your iOS client ID

5. **No billing required** — Drive API is free at this usage level.

---

## Building the App

Flutter and Java 17 are required. If `flutter` is not in PATH, use the full path (e.g. `<path>/flutter/bin/flutter`).

### First-time setup

```bash
cd home_storeroom
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Android

Get the SHA-1 fingerprint (needed for GCP OAuth setup):
```bash
JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 \
  keytool -list -v \
  -keystore <path>/.android/debug.keystore \
  -alias androiddebugkey -storepass android -keypass android \
  | grep "SHA1:"
```

Build APK (output: `build/app/outputs/flutter-apk/app-release.apk`):
```bash
JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 flutter build apk
```

After a successful build the APK is at:
```
build/app/outputs/flutter-apk/app-release.apk
```

Transfer it to your phone via USB, email, or Google Drive, then open it to install.
On the phone: Settings → Install unknown apps → allow once.

### iOS

Requires macOS with Xcode installed. Not buildable on Linux.

```bash
flutter build ios --release
```

#### Installing on iPhone — options

Unlike Android, iOS does not allow copying and installing arbitrary files. Options:

**Option 1 — Xcode on Mac (free)**
Connect iPhone via USB, open `ios/Runner.xcworkspace` in Xcode, select your device,
click Run. App expires after 7 days and must be reinstalled.

**Option 2 — AltStore (free, Windows or Mac)**
- Install AltServer on your PC
- Install AltStore on iPhone via AltServer
- Sideload the `.ipa` via AltStore
- App expires every 7 days but AltStore auto-refreshes it while your PC is on

**Option 3 — Apple Developer Account ($99/year)**
- Sign the app with your developer certificate
- Distribute via Ad Hoc to specific devices
- App valid for 1 year

**Option 4 — TestFlight (free, requires Developer Account)**
- Upload to App Store Connect, distribute via TestFlight link
- Works like a normal install, valid 90 days

There is no equivalent of the Android APK install — Apple enforces code signing
at the hardware level regardless of how the file arrives on the device.

### Run directly on connected device (debug mode)

```bash
flutter devices          # list connected devices
flutter run              # runs on the first detected device
flutter run -d <device>  # run on specific device
```

## Architecture

- **State management**: Riverpod (`AsyncNotifier`)
- **Navigation**: go_router with auth redirect guard
- **Storage**: Google Drive Excel file (`home_storeroom/storeroom.xlsx`)
- **Conflict resolution**: last upload wins
- **Barcode scanning**: mobile_scanner

## Data Model

`storeroom.xlsx` has two sheets:

**products** (row 1 = headers):
`id | category | barcode | name | quantity | expiration_date`

**categories** (row 1 = header):
`name`

## Multi-user Sync

All users sign in with the same Google account. The app reads the file from Drive on launch and on every explicit refresh (pull-to-refresh or refresh button). Writes are immediate uploads. Last write wins — no merge logic.
