import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../models/season.dart';
import '../models/music.dart';
import '../models/quote.dart';
import '../models/puzzle.dart';
import '../models/subscription.dart';

/// Сервис для работы с API данных Mahabharata
/// Аналог DataService из legacy Android/iOS приложений
class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  static DataService get instance => _instance;

  late final Dio _dio;
  String? _authToken;

  /// Инициализация сервиса
  Future<void> initialize() async {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: AppConfig.networkTimeout,
      receiveTimeout: AppConfig.networkTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Добавляем интерсепторы для логирования
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ));
    }

    // Интерсептор для добавления токена
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_authToken != null) {
          options.headers['Authorization'] = 'Bearer $_authToken';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        debugPrint('API Error: ${error.message}');
        return handler.next(error);
      },
    ));
  }

  /// Установить токен авторизации
  void setAuthToken(String? token) {
    _authToken = token;
  }

  /// Получить список сезонов
  Future<List<Season>> getSeasons() async {
    try {
      final response = await _dio.get('/api/Data/Seasons');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;

        // Поддержка разных форматов ответа
        List<dynamic> seasonsData;
        if (data is Map && data.containsKey('items')) {
          seasonsData = data['items'] as List<dynamic>;
        } else if (data is List) {
          seasonsData = data;
        } else {
          throw Exception('Unexpected response format');
        }

        return seasonsData
            .map((json) =>
                Season.fromMagentoProduct(json as Map<String, dynamic>))
            .toList();
      }

      throw Exception('Failed to load seasons');
    } catch (e) {
      debugPrint('Error loading seasons: $e');
      rethrow;
    }
  }

  /// Получить список подписок
  Future<List<Subscription>> getSubscriptions() async {
    try {
      final response = await _dio.get('/api/Data/Subscriptions');

      if (response.statusCode == 200 && response.data != null) {
        final subscriptionList =
            SubscriptionList.fromJson(response.data as Map<String, dynamic>);
        return subscriptionList.items;
      }

      throw Exception('Failed to load subscriptions');
    } catch (e) {
      debugPrint('Error loading subscriptions: $e');
      rethrow;
    }
  }

  /// Получить список пазлов
  Future<List<Puzzle>> getPuzzles() async {
    try {
      final response = await _dio.get('/api/Data/Puzzles');

      if (response.statusCode == 200 && response.data != null) {
        final puzzleList =
            PuzzleList.fromJson(response.data as Map<String, dynamic>);
        return puzzleList.items;
      }

      throw Exception('Failed to load puzzles');
    } catch (e) {
      debugPrint('Error loading puzzles: $e');
      rethrow;
    }
  }

  /// Получить список цитат
  Future<List<Quote>> getQuotes() async {
    try {
      final response = await _dio.get('/api/Data/Quotes');

      if (response.statusCode == 200 && response.data != null) {
        final quoteList =
            QuoteList.fromJson(response.data as Map<String, dynamic>);
        return quoteList.items;
      }

      throw Exception('Failed to load quotes');
    } catch (e) {
      debugPrint('Error loading quotes: $e');
      rethrow;
    }
  }

  /// Получить список музыки
  Future<List<Music>> getMusic() async {
    try {
      final response = await _dio.get('/api/Data/Music');

      if (response.statusCode == 200 && response.data != null) {
        final musicList =
            MusicList.fromJson(response.data as Map<String, dynamic>);
        return musicList.items;
      }

      throw Exception('Failed to load music');
    } catch (e) {
      debugPrint('Error loading music: $e');
      rethrow;
    }
  }

  /// Обновить информацию об устройстве
  Future<String?> updateDevice(String deviceId) async {
    try {
      final response = await _dio.post('/api/Auth/UpdateDevice', data: {
        'deviceId': deviceId,
        'localTime': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      });

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return data['token'] as String?;
      }

      return null;
    } catch (e) {
      debugPrint('Error updating device: $e');
      rethrow;
    }
  }

  /// Обновить Push токен
  Future<void> updatePushToken(String token) async {
    try {
      await _dio.post('/api/Auth/UpdatePushToken', data: {
        'token': token,
      });
    } catch (e) {
      debugPrint('Error updating push token: $e');
      // Не бросаем ошибку, т.к. это не критично
    }
  }

  /// Скачать файл с прогресс-колбэком
  Future<void> downloadFile(
    String url,
    String savePath, {
    Function(int, int)? onProgress,
  }) async {
    try {
      await _dio.download(
        url,
        savePath,
        onReceiveProgress: onProgress,
      );
    } catch (e) {
      debugPrint('Error downloading file: $e');
      rethrow;
    }
  }

  /// Получить полный URL для ресурса
  String getResourceUrl(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    return '${AppConfig.baseUrl}$path';
  }
}
