# SETUP.md — Auth Pro Plus

Auth Pro Plus is a **production-ready, modular authentication system** designed for real-world SwiftUI applications.

It supports:

- Email / Password authentication
- Forgot Password
- Google Sign-In
- Sign In with Apple
- Optional username creation
- Optional profile photo upload
- Consistent error handling
- Supabase or Firebase backend (swappable)

This document explains **everything required** to:

1. Run the included demo project  
2. Configure Supabase or Firebase  
3. Integrate Auth Pro Plus into your own existing app  

---

# 0) Project Structure (Actual Structure From Repo)

The project lives inside:

```
AuthProPlus/
```

The source code is here:

```
AuthProPlus/AuthProPlus/
```

Important folders:

```
AuthProPlus/AuthProPlus/
├── App/
│   └── AuthProPlusApp.swift
├── Core/
│   ├── Auth/
│   ├── Users/
│   ├── Components/
│   ├── Extensions/
│   ├── Utils/
│   └── ...
├── Resources/
│   ├── Info.plist
│   ├── AuthProPlus.entitlements
│   ├── Assets.xcassets
│   └── GoogleService-Info.plist (Firebase only)
├── ContentView.swift
```

Xcode project:

```
AuthProPlus/AuthProPlus.xcodeproj
```

---

# 1) Open & Run the Demo App

1. Unzip the project.
2. Open:

```
AuthProPlus/AuthProPlus.xcodeproj
```

3. Select the `AuthProPlus` scheme.
4. Run.

If you haven’t configured Supabase or Firebase yet, authentication will fail — but the project will build.

---

# 2) Swift Package Dependencies (Required)

If integrating into an existing app, add these via Swift Package Manager.

## Required for BOTH Providers

Google Sign-In:
```
https://github.com/google/GoogleSignIn-iOS
Products:
- GoogleSignIn
- GoogleSignInSwift
```

Kingfisher (image loading):
```
https://github.com/onevcat/Kingfisher
Product:
- Kingfisher
```

---

## If Using Firebase

```
https://github.com/firebase/firebase-ios-sdk
Products:
- FirebaseCore
- FirebaseAuth
- FirebaseFirestore
- FirebaseStorage
```

---

## If Using Supabase

```
https://github.com/supabase/supabase-swift
Product:
- Supabase
```

---

# 3) Selecting Your Backend Provider

Provider is configured in:

```
Core/Auth/Configuration/AuthConfig.swift
```

Edit this:

```swift
static var provider: AuthServiceProvider {
    // SUPABASE:
    return .supabase(client: supabaseClient)

    // FIREBASE:
    // return .firebase
}
```

---

# SUPABASE SETUP

---

## 1) Update Supabase Constants

File:
```
Core/Utils/Constants/AppConstants.swift
```

Replace:

```swift
static let projectURLString = "https://YOUR_PROJECT.supabase.co"
static let projectAPIKey = "YOUR_SUPABASE_ANON_KEY"
static let googleClientID = "YOUR_GOOGLE_IOS_CLIENT_ID"
```

Important:
- Use Supabase **anon key**
- Never use service role key in iOS app

---

## 2) Supabase Database Schema

Create this in Supabase SQL Editor:

```sql
create table if not exists public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique,
  email text,
  profileImageUrl text,
  fullname text,
  createdAt timestamptz not null default now(),
  lastActiveAt timestamptz
);

alter table public.users enable row level security;

create policy "Users can read own row"
on public.users
for select
to authenticated
using (auth.uid() = id);

create policy "Users can insert own row"
on public.users
for insert
to authenticated
with check (auth.uid() = id);

create policy "Users can update own row"
on public.users
for update
to authenticated
using (auth.uid() = id)
with check (auth.uid() = id);
```

---

## 3) Supabase Storage Setup (Profile Photos)

Create bucket:

```
profile-photos
```

Make it public (simplest setup).

Optional RLS:

```sql
create policy "Authenticated upload profile photos"
on storage.objects
for insert
to authenticated
with check (bucket_id = 'profile-photos');
```

---

## 4) Google Sign-In (Supabase)

This uses native GoogleSignIn SDK (no deep links).

### Add URL Scheme to Info.plist

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.googleusercontent.apps.YOUR_REVERSED_CLIENT_ID</string>
    </array>
  </dict>
</array>
```

Replace with your reversed client ID.

---

## 5) Sign In With Apple (Supabase)

In Xcode:

Signing & Capabilities → Add:
```
Sign In with Apple
```

Ensure it’s enabled in Apple Developer portal.

---

# FIREBASE SETUP

---

## 1) Set Provider

```
AuthConfig.swift
```

```swift
static var provider: AuthServiceProvider {
    return .firebase
}
```

Firebase auto-configures in `AuthProPlusApp.swift`.

---

## 2) Add GoogleService-Info.plist

Download from Firebase Console and replace:

```
Resources/GoogleService-Info.plist
```

Ensure it is included in target membership.

---

## 3) Enable Auth Providers in Firebase Console

Enable:
- Email/Password
- Google
- Apple

---

## 4) Firestore Rules

```txt
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## 5) Firebase Storage Rules

```txt
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /profile_images/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

---

## 6) Google Sign-In URL Scheme (Firebase)

Add to Info.plist:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.googleusercontent.apps.YOUR_REVERSED_CLIENT_ID</string>
    </array>
  </dict>
</array>
```

Use reversed client ID from `GoogleService-Info.plist`.

---

# 4) Integrating Into Your Existing App

---

## Step 1: Copy Source Folder

Copy:

```
AuthProPlus/AuthProPlus/Core/
```

Into your project.

Also copy:
```
Assets.xcassets
AuthProPlus.entitlements (or re-add capability manually)
```

---

## Step 2: Add Required Swift Packages

Add packages listed earlier.

---

## Step 3: Initialize Provider

In your App file:

```swift
@main
struct MyApp: App {

    init() {
        let provider = AuthConfig.provider

        if case .firebase = provider {
            FirebaseApp.configure()
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
```

---

## Step 4: Present Auth Flow

Example root:

```swift
struct RootView: View {
    @Environment(\.authManager) private var authManager

    var body: some View {
        switch authManager.authState {
        case .authenticated:
            HomeView()
        case .unauthenticated:
            AuthenticationRootView()
        default:
            ProgressView()
        }
    }
}
```

---

# 5) Common Issues Checklist

### Google sign-in fails immediately
- Wrong client ID
- Missing URL scheme
- Firebase not configured

### Supabase user never loads
- `users` table missing
- RLS blocking access

### Profile photo upload fails
- Storage bucket missing
- Rules blocking upload

---

# Final Quick Checklist

### Supabase
- Set project URL + anon key
- Create users table
- Create profile-photos bucket
- Add URL scheme
- Enable Apple capability

### Firebase
- Add GoogleService-Info.plist
- Enable providers
- Add URL scheme
- Add Firestore rules
- Add Storage rules
- Enable Apple capability

---

Auth Pro Plus is now fully configured and ready to integrate into production apps.
