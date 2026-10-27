# Currency Converter

Flutter app jo 160+ currencies ke live exchange rates ke saath conversion, charts, favorites aur rate alerts deti hai.

## Features

- Live currency conversion
- Rate charts (`fl_chart`)
- Favorites aur Rate Alerts
- Conversion history (swipe to delete)
- Light / Dark / System theme
- Offline support (saved rates)
- Glassmorphism floating navbar with animated indicator

## Tech Stack

| Area | Package |
|------|---------|
| State management | `flutter_riverpod` |
| Charts | `fl_chart` |
| Fonts | `google_fonts` |
| Local storage | `shared_preferences`, `path_provider` |
| Networking | `http` |
| Icons | `cupertino_icons` |

## Requirements

- Flutter SDK (stable)
- Xcode + CocoaPods (iOS ke liye, macOS par)
- Android Studio / Android SDK (Android ke liye)

```bash
flutter doctor -v
```

## Setup

```bash
cd currency_converter
flutter pub get
flutter run
```

## iOS Setup

Agar ye error aaye:

```
No application found for TargetPlatform.ios.
Is your project missing an ios/Runner/Info.plist?
```

to ye karein:

```bash
flutter create --platforms=ios .
flutter clean
flutter pub get
flutter run
```

Notes:
- `ios/Podfile` pehli `flutter run` par khud ban jati hai. Pehli build mein 3-5 minute lag sakte hain.
- `pod install` fail ho to: `cd ios && pod repo update && pod install && cd ..`
- Simulator pehle khol lein: `open -a Simulator`
- Real device ke liye Xcode mein `ios/Runner.xcworkspace` kholein aur Signing & Capabilities mein Team select karein.

## Android Setup

Agar `android/app/build.gradle` not found error aaye:

```bash
flutter create --platforms=android .
flutter pub get
```

## Build

Android APK:

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

Android App Bundle (Play Store):

```bash
flutter build appbundle --release
```

iOS (macOS par):

```bash
flutter build ios --release
```

## Cupertino Icons

Delete icon `CupertinoIcons` use karta hai, isliye `pubspec.yaml` mein ye zaroori hai:

```yaml
dependencies:
  cupertino_icons: ^1.0.8
```

```bash
flutter pub add cupertino_icons
```

Package add karne ke baad hot restart kaafi nahi, app band karke dobara `flutter run` karein.

## Project Structure

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── di/providers.dart
│   ├── theme/
│   ├── utils/
│   └── widgets/
└── features/
    ├── converter/
    ├── rates/
    ├── history/
    ├── favorites/
    ├── alerts/
    ├── settings/
    └── shell/
```

## Navbar Customization

File: `lib/features/shell/presentation/widgets/glass_nav_bar.dart`

| Setting | Variable | Current |
|---------|----------|---------|
| Height | `_height` | `72` |
| Max width | `_maxWidth` | `380` |
| Jelly amount | `stiffness` / `damping` | `240` / `18` |
| Glass blur | `ImageFilter.blur(sigmaX/Y)` | `16` |

Pages mein neeche padding `130` rakhi hai aur `MainShell` mein `extendBody: true` zaroori hai.

## Tests

```bash
flutter test
```

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `Info.plist` missing | `flutter create --platforms=ios .` |
| `build.gradle` not found | `flutter create --platforms=android .` |
| Cupertino icon khali | `cupertino_icons` add karein, full restart karein |
| Navbar hot reload par update na ho | Hot restart karein |
| `pod install` fail | `pod repo update` phir `pod install` |
| Purane build ka error | `flutter clean && flutter pub get` |

## Data Source

Rates ki API: fawazahmed0 Currency API (jsDelivr + Cloudflare Pages fallback), phir open.er-api.com. Flags: flagcdn.com

## App Icon

Icon files `assets/icon/` mein hain:
- `app_icon.png` (1024x1024, iOS aur Android)
- `app_icon_foreground.png` (Android adaptive icon)

`pubspec.yaml` mein `flutter_launcher_icons` ki settings hain. Icon dobara generate karne ke liye:

```bash
dart run flutter_launcher_icons
flutter clean
flutter run
```

Icon badalne ke baad simulator se purani app delete karke dobara install karein, warna purana icon dikhta rahega.
