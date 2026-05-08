/// Модель настроек приложения из legacy приложений
class AppSettings {
  final String language; // en, ru, hi
  final bool soundOn;
  final bool subscribed;
  final String? deviceToken;
  final String? pushToken;
  final bool initialized;

  AppSettings({
    this.language = 'en',
    this.soundOn = true,
    this.subscribed = false,
    this.deviceToken,
    this.pushToken,
    this.initialized = false,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      language: json['language']?.toString() ?? 'en',
      soundOn: json['soundOn'] as bool? ?? true,
      subscribed: json['subscribed'] as bool? ?? false,
      deviceToken: json['deviceToken']?.toString(),
      pushToken: json['pushToken']?.toString(),
      initialized: json['initialized'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'soundOn': soundOn,
      'subscribed': subscribed,
      'deviceToken': deviceToken,
      'pushToken': pushToken,
      'initialized': initialized,
    };
  }

  AppSettings copyWith({
    String? language,
    bool? soundOn,
    bool? subscribed,
    String? deviceToken,
    String? pushToken,
    bool? initialized,
  }) {
    return AppSettings(
      language: language ?? this.language,
      soundOn: soundOn ?? this.soundOn,
      subscribed: subscribed ?? this.subscribed,
      deviceToken: deviceToken ?? this.deviceToken,
      pushToken: pushToken ?? this.pushToken,
      initialized: initialized ?? this.initialized,
    );
  }

  @override
  String toString() {
    return 'AppSettings(language: $language, soundOn: $soundOn, subscribed: $subscribed)';
  }
}

/// Язык приложения
enum AppLanguage {
  english('en', 'English', 'EN'),
  russian('ru', 'Русский', 'РУС'),
  hindi('hi', 'हिन्दी', 'हिन्दी'),
  marathi('mr', 'मराठी', 'मराठी');

  final String code;
  final String name;
  final String nativeName;

  const AppLanguage(this.code, this.name, this.nativeName);

  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => AppLanguage.english,
    );
  }

  @override
  String toString() => code;
}
