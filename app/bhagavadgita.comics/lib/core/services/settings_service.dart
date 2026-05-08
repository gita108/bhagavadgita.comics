import 'package:shared_preferences/shared_preferences.dart';
import 'hive_service.dart';

class SettingsService {
  static late SharedPreferences _prefs;

  static const String _keyLanguage = 'language';
  static const String _keyToken = 'token';
  static const String _keyPushToken = 'pushToken';
  static const String _keyInitialized = 'initialized';
  static const String _keySoundEnabled = 'soundEnabled';
  static const String _keyMusicEnabled = 'musicEnabled';
  static const String _keyAutoDownload = 'autoDownload';
  static const String _keyThemeMode = 'themeMode';

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Language
  static String get language => _prefs.getString(_keyLanguage) ?? 'en';
  static set language(String value) => _prefs.setString(_keyLanguage, value);

  // Token
  static String? get token => _prefs.getString(_keyToken);
  static set token(String? value) {
    if (value != null) {
      _prefs.setString(_keyToken, value);
    } else {
      _prefs.remove(_keyToken);
    }
  }

  // Push Token
  static String? get pushToken => _prefs.getString(_keyPushToken);
  static set pushToken(String? value) {
    if (value != null) {
      _prefs.setString(_keyPushToken, value);
    } else {
      _prefs.remove(_keyPushToken);
    }
  }

  // Initialized
  static bool get initialized => _prefs.getBool(_keyInitialized) ?? false;
  static set initialized(bool value) => _prefs.setBool(_keyInitialized, value);

  // Sound
  static bool get soundEnabled => _prefs.getBool(_keySoundEnabled) ?? true;
  static set soundEnabled(bool value) =>
      _prefs.setBool(_keySoundEnabled, value);

  // Music
  static bool get musicEnabled => _prefs.getBool(_keyMusicEnabled) ?? true;
  static set musicEnabled(bool value) =>
      _prefs.setBool(_keyMusicEnabled, value);

  // Auto Download
  static bool get autoDownload => _prefs.getBool(_keyAutoDownload) ?? false;
  static set autoDownload(bool value) =>
      _prefs.setBool(_keyAutoDownload, value);

  // Theme Mode
  static String get themeMode => _prefs.getString(_keyThemeMode) ?? 'dark';
  static set themeMode(String value) => _prefs.setString(_keyThemeMode, value);

  static Future<void> clear() async {
    await _prefs.clear();
  }
}
