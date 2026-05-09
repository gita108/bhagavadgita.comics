import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // Translations
  String get appTitle =>
      _localizedStrings[locale.languageCode]?['appTitle'] ?? 'Mahabharata';
  String get home => _localizedStrings[locale.languageCode]?['home'] ?? 'Home';
  String get episodes =>
      _localizedStrings[locale.languageCode]?['episodes'] ?? 'Episodes';
  String get seasons =>
      _localizedStrings[locale.languageCode]?['seasons'] ?? 'Seasons';
  String get music =>
      _localizedStrings[locale.languageCode]?['music'] ?? 'Music';
  String get quotes =>
      _localizedStrings[locale.languageCode]?['quotes'] ?? 'Quotes';
  String get settings =>
      _localizedStrings[locale.languageCode]?['settings'] ?? 'Settings';
  String get profile =>
      _localizedStrings[locale.languageCode]?['profile'] ?? 'Profile';
  String get download =>
      _localizedStrings[locale.languageCode]?['download'] ?? 'Download';
  String get play => _localizedStrings[locale.languageCode]?['play'] ?? 'Play';
  String get pause =>
      _localizedStrings[locale.languageCode]?['pause'] ?? 'Pause';
  String get share =>
      _localizedStrings[locale.languageCode]?['share'] ?? 'Share';
  String get loading =>
      _localizedStrings[locale.languageCode]?['loading'] ?? 'Loading...';

  static const Map<String, Map<String, String>> _localizedStrings = {
    'en': {
      'appTitle': 'Mahabharata',
      'home': 'Home',
      'episodes': 'Episodes',
      'seasons': 'Seasons',
      'music': 'Music',
      'quotes': 'Quotes',
      'settings': 'Settings',
      'profile': 'Profile',
      'download': 'Download',
      'play': 'Play',
      'pause': 'Pause',
      'share': 'Share',
      'loading': 'Loading...',
    },
    'ru': {
      'appTitle': 'Махабхарата',
      'home': 'Главная',
      'episodes': 'Эпизоды',
      'seasons': 'Сезоны',
      'music': 'Музыка',
      'quotes': 'Цитаты',
      'settings': 'Настройки',
      'profile': 'Профиль',
      'download': 'Скачать',
      'play': 'Играть',
      'pause': 'Пауза',
      'share': 'Поделиться',
      'loading': 'Загрузка...',
    },
    'hi': {
      'appTitle': 'महाभारत',
      'home': 'मुख्य पृष्ठ',
      'episodes': 'एपिसोड',
      'seasons': 'सीज़न',
      'music': 'संगीत',
      'quotes': 'उद्धरण',
      'settings': 'सेटिंग्स',
      'profile': 'प्रोफ़ाइल',
      'download': 'डाउनलोड',
      'play': 'प्ले',
      'pause': 'विराम',
      'share': 'शेयर',
      'loading': 'लोड हो रहा है...',
    },
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ru', 'hi', 'mr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
