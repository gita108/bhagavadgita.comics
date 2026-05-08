import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String _settingsBox = 'settings';
  static const String _episodesBox = 'episodes';
  static const String _musicBox = 'music';
  static const String _quotesBox = 'quotes';
  static const String _downloadsBox = 'downloads';

  static late Box<dynamic> _settings;
  static late Box<dynamic> _episodes;
  static late Box<dynamic> _music;
  static late Box<dynamic> _quotes;
  static late Box<dynamic> _downloads;

  static Future<void> initialize() async {
    await Hive.initFlutter();

    _settings = await Hive.openBox(_settingsBox);
    _episodes = await Hive.openBox(_episodesBox);
    _music = await Hive.openBox(_musicBox);
    _quotes = await Hive.openBox(_quotesBox);
    _downloads = await Hive.openBox(_downloadsBox);
  }

  static Box get settings => _settings;
  static Box get episodes => _episodes;
  static Box get music => _music;
  static Box get quotes => _quotes;
  static Box get downloads => _downloads;

  static Future<void> clearAll() async {
    await _settings.clear();
    await _episodes.clear();
    await _music.clear();
    await _quotes.clear();
    await _downloads.clear();
  }
}
