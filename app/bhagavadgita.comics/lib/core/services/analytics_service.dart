import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  static late FirebaseAnalytics _analytics;
  static late FirebaseCrashlytics _crashlytics;

  static Future<void> initialize() async {
    _analytics = FirebaseAnalytics.instance;
    _crashlytics = FirebaseCrashlytics.instance;

    // Enable crashlytics collection
    await _crashlytics.setCrashlyticsCollectionEnabled(true);

    // Pass all uncaught errors to Crashlytics
    FlutterError.onError = _crashlytics.recordFlutterFatalError;

    // Pass all uncaught asynchronous errors to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      _crashlytics.recordError(error, stack, fatal: true);
      return true;
    };
  }

  static FirebaseAnalytics get analytics => _analytics;

  // Log events
  static Future<void> logEvent(String name,
      {Map<String, Object>? parameters}) async {
    await _analytics.logEvent(name: name, parameters: parameters);
  }

  static Future<void> logEpisodeView(
      String episodeId, String episodeName) async {
    await logEvent('episode_view', parameters: {
      'episode_id': episodeId,
      'episode_name': episodeName,
    });
  }

  static Future<void> logEpisodeComplete(String episodeId) async {
    await logEvent('episode_complete', parameters: {
      'episode_id': episodeId,
    });
  }

  static Future<void> logQuoteShare(String quoteId) async {
    await logEvent('quote_share', parameters: {
      'quote_id': quoteId,
    });
  }

  static Future<void> logMusicPlay(String musicId, String musicName) async {
    await logEvent('music_play', parameters: {
      'music_id': musicId,
      'music_name': musicName,
    });
  }

  static Future<void> logPurchase(String productId, double price) async {
    await _analytics.logPurchase(
      value: price,
      currency: 'USD',
      items: [
        AnalyticsEventItem(
          itemId: productId,
          itemName: productId,
        ),
      ],
    );
  }

  static Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }

  static Future<void> setUserProperty(String name, String value) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  // Crashlytics
  static void recordError(dynamic exception, StackTrace? stackTrace,
      {String? reason}) {
    _crashlytics.recordError(exception, stackTrace, reason: reason);
  }

  static Future<void> log(String message) async {
    await _crashlytics.log(message);
  }
}
