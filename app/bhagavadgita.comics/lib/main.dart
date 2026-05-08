import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Core imports
import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/config/app_config.dart';
import 'core/services/settings_service.dart';
import 'core/services/hive_service.dart';
import 'core/services/analytics_service.dart';
import 'core/l10n/app_localizations.dart';

/// Background message handler for Firebase
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait for mobile, allow all for tablet
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    print('Firebase initialization failed: $e');
  }

  // Initialize Hive for local storage
  await Hive.initFlutter();
  await HiveService.initialize();

  // Initialize settings
  await SettingsService.initialize();

  // Initialize Analytics
  try {
    await AnalyticsService.initialize();
  } catch (e) {
    print('Analytics initialization failed: $e');
  }

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.maroon1,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    const ProviderScope(
      child: MahabharataApp(),
    ),
  );
}

class MahabharataApp extends ConsumerWidget {
  const MahabharataApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Mahabharata',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Default to dark theme

      // Localization
      locale: locale,
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('ru', ''), // Russian
        Locale('hi', ''), // Hindi
        Locale('mr', 'IN'), // Marathi
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Routing
      routerConfig: router,
    );
  }
}

class AppColors {
  static const maroon1 = Color(0xFF8B0000);
  static const yellow1 = Color(0xFFFFD700);
  static const inactiveYellow = Color(0xFFFFE4B5);
}

// Providers
final localeProvider = StateProvider<Locale>((ref) {
  return const Locale('en', '');
});
