# MIHLGSO Mobile

Android companion app for **MIHLGSO** (Mafia Island Higher Learning Graduates
and Students Organization), talking to the same backend as the
[mihlgso website](https://github.com/MSEMBE/mihlgso) (Next.js). Android only —
there is no iOS target.

## Features

- **Public**: home, about, projects, gallery, news, leadership, membership
  application/status check, contact.
- **Auth**: sign in, forgot/reset password.
- **Member portal**: dashboard, record/view payments and donations, annual
  subscription status, contributor/donor leaderboards, profile, bank accounts
  ("where to pay") for each contribution type.
- **Admin portal**: manage members, payments, donations, applications,
  contribution types, org stats.
- **Exports**: Excel/PDF exports across admin and member list screens,
  visually matched to the website's own export output (branded letterhead,
  gradient header/total rows, zebra-striped tables), saved straight to the
  device's Downloads folder with a "download complete" notification — no
  share sheet.

## Tech stack

- **Flutter** (Dart), Android only (`minSdk 24`)
- **State management**: Riverpod (`flutter_riverpod`, code-gen via
  `riverpod_generator`)
- **Networking**: Dio
- **Routing**: go_router
- **Models**: Freezed + json_serializable
- **Secure storage**: flutter_secure_storage (auth tokens)
- **Exports**: `excel` + `pdf` packages, saved via a native Kotlin
  `MethodChannel` (`android/.../MainActivity.kt`) using `MediaStore.Downloads`
  (Android 10+) or direct file write + `FileProvider` (Android 9 and below)
- **Localization**: hand-rolled `AppStrings` (English/Swahili), not ARB/`intl`
  code-gen

## Project structure

```
lib/
  core/           theme, localization (AppStrings), shared constants
  models/         Freezed/json_serializable data models
  providers/      Riverpod providers (state + data fetching)
  repositories/   data-access layer between providers and services
  routes/         go_router route definitions
  screens/
    admin/        admin-only screens (members, payments, donations, ...)
    auth/         sign in / password reset
    member/       member portal screens
    public/       public-facing marketing/info screens
  services/       API clients and platform-channel services (e.g. exports)
  widgets/        shared reusable widgets
```

## Getting started

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs   # generate Freezed/Riverpod/json code
flutter run
```

## Building a release APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`.

## Backend

Points at the same MySQL-backed Next.js API as the website. No local backend
is included in this repo — configure the API base URL for your environment
before building.
