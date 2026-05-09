# Mahabharata App - Modern Flutter Implementation (2025)

[![Flutter Version](https://img.shields.io/badge/Flutter-3.10+-blue.svg)](https://flutter.dev/)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20Web-green.svg)](https://flutter.dev/)

## Overview

Modern Flutter application for Mahabharata.pro featuring interactive storytelling, e-commerce integration, NFT support, and comprehensive multimedia capabilities.

## 🎯 Key Features

### Core Functionality
- **Interactive Episodes**: Animated comics with sound, layers, and rich visual effects
- **Multi-Language Support**: English, Russian, Hindi, Marathi
- **Offline Mode**: Download episodes for offline viewing
- **Audio Playback**: Background music and sound effects
- **Quotes Library**: Browse and share inspirational quotes
- **Settings & Preferences**: Customizable user experience

### Modern Integrations (2025 Best Practices)
- **Flutter ICP**: Internet Computer Protocol blockchain integration
- **Flutter Magento**: E-commerce platform with RADA format support
- **Flutter Marketplace**: Multi-vendor marketplace functionality
- **Flutter Notifications**: Push and in-app notifications
- **Flutter Yuku**: Universal blockchain operations
- **Flutter Messenger**: Real-time messaging
- **Flutter NFT**: NFT wallet and minting capabilities

### Technical Features
- **Firebase Integration**: Analytics, Crashlytics, Cloud Messaging
- **State Management**: Riverpod for reactive state management
- **Offline-First**: Local caching with Hive
- **Modern UI**: Material Design 3 with custom theming
- **Type-Safe Navigation**: GoRouter for declarative routing

## 🏗️ Architecture

```
lib/
├── core/
│   ├── config/          # App configuration
│   ├── l10n/            # Localization
│   ├── navigation/      # Routing configuration
│   ├── services/        # Core services (Analytics, Settings, Hive, Magento)
│   └── theme/           # App theming
├── features/
│   ├── splash/          # Splash screen
│   ├── home/            # Home screen with tabs
│   ├── seasons/         # Seasons & episodes
│   ├── episode/         # Episode viewer
│   ├── settings/        # Settings screen
│   ├── profile/         # User profile
│   ├── purchase/        # In-app purchases
│   └── dome/            # Dome experience
└── main.dart            # App entry point
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK >=3.10.0
- Dart SDK >=3.0.0
- Xcode 15+ (for iOS)
- Android Studio / VS Code

### Installation

1. **Clone the repository**
```bash
cd /Users/anton/proj.boilerplate/mahabharata-heap/mahabharata_app
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the app**
```bash
# iOS Simulator
flutter run -d 'iPad Pro (12.9-inch) (6th generation)'

# Android Emulator
flutter run -d emulator-5554

# Release mode
flutter run --release
```

## 📱 Platform Support

| Platform | Status | Min Version |
|----------|--------|-------------|
| iOS      | ✅     | iOS 12.0+   |
| Android  | ✅     | API 24+     |
| Web      | ✅     | Modern browsers |
| macOS    | ✅     | macOS 10.14+ |
| Windows  | ✅     | Windows 10+ |
| Linux    | ✅     | Any         |

## 🎨 Theming

The app uses a custom dark theme with:
- **Primary Color**: Maroon (#8B0000)
- **Secondary Color**: Gold (#FFD700)
- **Font Family**: Proxima Nova, Hindi, Sanskrit, Devanagari

## 🔧 Configuration

### Firebase Setup
1. Add `google-services.json` (Android) to `android/app/`
2. Add `GoogleService-Info.plist` (iOS) to `ios/Runner/`

### API Configuration
Update `lib/core/config/app_config.dart`:
```dart
static const String magentoBaseUrl = 'https://your-api.com';
static const String icpCanisterId = 'your-canister-id';
```

## 📦 Deployment

### Using Fastlane

#### iOS TestFlight
```bash
cd fastlane
bundle install
bundle exec fastlane ios beta
```

#### Android Play Store
```bash
bundle exec fastlane android beta
```

### Manual Build

#### iOS
```bash
flutter build ios --release
```

#### Android
```bash
flutter build appbundle --release
```

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## 📊 Project Stats

- **Total Screens**: 8+ functional screens
- **Core Services**: 6 integrated services
- **Supported Languages**: 4 languages
- **Dependencies**: Modern, stable packages
- **Architecture**: Clean architecture with separation of concerns

## 🔄 Migration from Legacy

This app replaces the legacy native implementations:
- ✅ **Legacy Android** (Java/Kotlin) - Removed
- ✅ **Legacy iOS** (Swift) - Removed
- ✅ **Modern Flutter** - Fully implemented

### What Changed
- Unified codebase for all platforms
- Modern state management (Riverpod)
- Enhanced performance and maintainability
- Better offline support
- Improved UI/UX with Material Design 3
- Integration-ready architecture

## 📝 License

This project is proprietary. All rights reserved.

## 👥 Contributors

- Anton Dodonov - Initial modernization and Flutter implementation

## 🆘 Support

For issues or questions:
- Check the [fastlane/README.md](fastlane/README.md) for deployment help
- Review Firebase console for analytics and crash reports
- Check device logs for runtime issues

## 🗺️ Roadmap

- [ ] Complete Dome experience implementation
- [ ] Full NFT marketplace integration
- [ ] Enhanced offline synchronization
- [ ] Additional language support
- [ ] Performance optimizations
- [ ] Comprehensive test coverage

## 📱 Screenshots

The app features:
- Beautiful animated splash screen
- Tab-based navigation (Episodes, Quotes, Music, Profile)
- Interactive episode viewer with controls
- Comprehensive settings panel
- Modern UI with custom theming

---

**Built with ❤️ using Flutter**
