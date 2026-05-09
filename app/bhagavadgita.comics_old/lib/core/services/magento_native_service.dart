import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_magento/flutter_magento.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'magento_provider_extension.dart';

/// Модели для покупок
class Episode {
  final String id;
  final String name;
  final String description;
  final String image;
  final double price;
  final String currency;
  final bool isPurchased;
  final String seasonId;
  final int order;
  final String? audioUrl;
  final String? videoUrl;
  final DateTime? releaseDate;

  Episode({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.price,
    required this.currency,
    required this.isPurchased,
    required this.seasonId,
    required this.order,
    this.audioUrl,
    this.videoUrl,
    this.releaseDate,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Без названия',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'USD',
      isPurchased: json['is_purchased'] ?? false,
      seasonId: json['season_id']?.toString() ?? '',
      order: json['order'] ?? 0,
      audioUrl: json['audio_url'],
      videoUrl: json['video_url'],
      releaseDate: json['release_date'] != null
          ? DateTime.parse(json['release_date'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'price': price,
      'currency': currency,
      'is_purchased': isPurchased,
      'season_id': seasonId,
      'order': order,
      'audio_url': audioUrl,
      'video_url': videoUrl,
      'release_date': releaseDate?.toIso8601String(),
    };
  }
}

class Season {
  final String id;
  final String name;
  final String description;
  final String image;
  final double price;
  final String currency;
  final bool isPurchased;
  final List<Episode> episodes;
  final int order;
  final DateTime? releaseDate;

  Season({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.price,
    required this.currency,
    required this.isPurchased,
    required this.episodes,
    required this.order,
    this.releaseDate,
  });

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Без названия',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'USD',
      isPurchased: json['is_purchased'] ?? false,
      episodes: (json['episodes'] as List<dynamic>?)
              ?.map((e) => Episode.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      order: json['order'] ?? 0,
      releaseDate: json['release_date'] != null
          ? DateTime.parse(json['release_date'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'price': price,
      'currency': currency,
      'is_purchased': isPurchased,
      'episodes': episodes.map((e) => e.toJson()).toList(),
      'order': order,
      'release_date': releaseDate?.toIso8601String(),
    };
  }
}

class PurchaseResult {
  final bool success;
  final String? orderId;
  final String? paymentUrl;
  final String? error;
  final Map<String, dynamic>? data;

  PurchaseResult({
    required this.success,
    this.orderId,
    this.paymentUrl,
    this.error,
    this.data,
  });

  factory PurchaseResult.fromJson(Map<String, dynamic> json) {
    return PurchaseResult(
      success: json['success'] ?? false,
      orderId: json['order_id'],
      paymentUrl: json['payment_url'],
      error: json['error'],
      data: json['data'],
    );
  }
}

/// Нативный сервис Magento с полной интеграцией покупок
class MagentoNativeService {
  static MagentoNativeService? _instance;
  static MagentoNativeService get instance =>
      _instance ??= MagentoNativeService._();

  MagentoNativeService._();

  // Flutter Magento провайдеры
  MagentoProvider? _magentoProvider;
  AuthProvider? _authProvider;

  // Нативные каналы
  static const MethodChannel _anantaSoundChannel =
      MethodChannel('anantasound_service');
  static const MethodChannel _magentoNativeChannel =
      MethodChannel('magento_native_service');

  // Состояние
  bool _isInitialized = false;
  bool _isCloudEnabled = false;
  String? _baseUrl;
  DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  // Кэш данных
  List<Season> _seasons = [];
  List<Episode> _episodes = [];
  Map<String, bool> _purchaseStatus = {};

  // Стримы
  final StreamController<List<Season>> _seasonsController =
      StreamController<List<Season>>.broadcast();
  final StreamController<List<Episode>> _episodesController =
      StreamController<List<Episode>>.broadcast();
  final StreamController<Map<String, dynamic>> _purchaseController =
      StreamController<Map<String, dynamic>>.broadcast();

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isCloudEnabled => _isCloudEnabled;
  bool get isConnected => _magentoProvider?.isConnected ?? false;
  bool get isAuthenticated => _authProvider?.isAuthenticated ?? false;
  List<Season> get seasons => _seasons;
  List<Episode> get episodes => _episodes;

  Stream<List<Season>> get seasonsStream => _seasonsController.stream;
  Stream<List<Episode>> get episodesStream => _episodesController.stream;
  Stream<Map<String, dynamic>> get purchaseStream => _purchaseController.stream;

  /// Инициализация нативного сервиса
  Future<void> initialize({
    String? baseUrl,
    List<String> supportedLanguages = const ['en', 'ru', 'hi', 'sa'],
  }) async {
    try {
      debugPrint('🚀 Инициализация MagentoNativeService с системой покупок...');

      final prefs = await SharedPreferences.getInstance();
      _isCloudEnabled = prefs.getBool('cloud_enabled') ?? false;
      _baseUrl = baseUrl ?? prefs.getString('magento_base_url');

      // Инициализация нативных каналов
      await _initializeNativeChannels();

      // Инициализация AnantaSound
      await _initializeAnantaSound();

      // Инициализация Magento
      if (_isCloudEnabled && _baseUrl != null) {
        await _initializeMagentoProvider(
          baseUrl: _baseUrl!,
          supportedLanguages: supportedLanguages,
        );

        // Загрузка данных о покупках
        await _loadPurchaseStatus();
      }

      // Получение информации об устройстве
      await _initializeDeviceInfo();

      _isInitialized = true;
      debugPrint('✅ MagentoNativeService с системой покупок инициализирован');
    } catch (e) {
      debugPrint('❌ Ошибка инициализации MagentoNativeService: $e');
      _isInitialized = true; // Продолжаем работу без облачных функций
    }
  }

  /// Инициализация нативных каналов
  Future<void> _initializeNativeChannels() async {
    try {
      _anantaSoundChannel.setMethodCallHandler(_handleAnantaSoundCall);
      _magentoNativeChannel.setMethodCallHandler(_handleMagentoNativeCall);

      debugPrint('📱 Нативные каналы инициализированы');
    } catch (e) {
      debugPrint('❌ Ошибка инициализации нативных каналов: $e');
    }
  }

  /// Инициализация AnantaSound через нативный канал
  Future<void> _initializeAnantaSound() async {
    try {
      final result = await _anantaSoundChannel.invokeMethod('initialize', {
        'domeRadius': 10.0,
        'domeHeight': 5.0,
        'quantumUncertainty': 0.1,
      });

      if (result['success'] == true) {
        debugPrint('🎵 AnantaSound инициализирован через нативный канал');
        _startAnantaSoundMonitoring();
      }
    } catch (e) {
      debugPrint('❌ Ошибка инициализации AnantaSound: $e');
    }
  }

  /// Инициализация MagentoProvider
  Future<void> _initializeMagentoProvider({
    required String baseUrl,
    required List<String> supportedLanguages,
  }) async {
    try {
      _magentoProvider = MagentoProvider();

      await _magentoProvider!.initialize(
        baseUrl: baseUrl,
        supportedLanguages: supportedLanguages,
        connectionTimeout: 30000,
        receiveTimeout: 30000,
        headers: {
          'X-API-Key': 'mahabharata-native-client',
          'X-Store-Code': 'default',
          'X-Device-Info': await _getDeviceInfo(),
        },
      );

      _authProvider = AuthProvider(_magentoProvider!.auth);

      debugPrint('🛍️ MagentoProvider с системой покупок инициализирован');
    } catch (e) {
      debugPrint('❌ Ошибка инициализации MagentoProvider: $e');
      _magentoProvider = null;
      rethrow;
    }
  }

  /// Инициализация информации об устройстве
  Future<void> _initializeDeviceInfo() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await _deviceInfo.androidInfo;
        debugPrint(
            '📱 Android Device: ${androidInfo.model} (${androidInfo.version.release})');
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        debugPrint(
            '📱 iOS Device: ${iosInfo.model} (${iosInfo.systemVersion})');
      }
    } catch (e) {
      debugPrint('❌ Ошибка получения информации об устройстве: $e');
    }
  }

  /// Получение информации об устройстве для API
  Future<String> _getDeviceInfo() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await _deviceInfo.androidInfo;
        return jsonEncode({
          'platform': 'android',
          'model': androidInfo.model,
          'version': androidInfo.version.release,
          'sdk': androidInfo.version.sdkInt,
          'brand': androidInfo.brand,
          'manufacturer': androidInfo.manufacturer,
        });
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return jsonEncode({
          'platform': 'ios',
          'model': iosInfo.model,
          'version': iosInfo.systemVersion,
          'name': iosInfo.name,
          'localizedModel': iosInfo.localizedModel,
          'identifierForVendor': iosInfo.identifierForVendor,
        });
      }
      return jsonEncode({'platform': 'unknown'});
    } catch (e) {
      debugPrint('❌ Ошибка получения информации об устройстве: $e');
      return jsonEncode({'platform': 'error'});
    }
  }

  /// Загрузка статуса покупок
  Future<void> _loadPurchaseStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final purchaseData = prefs.getString('purchase_status');

      if (purchaseData != null) {
        final Map<String, dynamic> data = jsonDecode(purchaseData);
        _purchaseStatus = Map<String, bool>.from(data);
        debugPrint(
            '💰 Статус покупок загружен: ${_purchaseStatus.length} записей');
      }
    } catch (e) {
      debugPrint('❌ Ошибка загрузки статуса покупок: $e');
    }
  }

  /// Сохранение статуса покупок
  Future<void> _savePurchaseStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('purchase_status', jsonEncode(_purchaseStatus));
      debugPrint('💰 Статус покупок сохранен');
    } catch (e) {
      debugPrint('❌ Ошибка сохранения статуса покупок: $e');
    }
  }

  /// Обработчик вызовов AnantaSound
  Future<dynamic> _handleAnantaSoundCall(MethodCall call) async {
    switch (call.method) {
      case 'onStatisticsUpdate':
        final stats = Map<String, dynamic>.from(call.arguments);
        _purchaseController.add({'type': 'ananta_stats', 'data': stats});
        return {'success': true};

      case 'onFieldsUpdate':
        final fields = List<Map<String, dynamic>>.from(call.arguments);
        _purchaseController.add({'type': 'fields_update', 'data': fields});
        return {'success': true};

      case 'onQuantumEvent':
        final event = Map<String, dynamic>.from(call.arguments);
        _purchaseController.add({'type': 'quantum_event', 'data': event});
        return {'success': true};

      default:
        throw PlatformException(
          code: 'UNIMPLEMENTED',
          message: 'MagentoNativeService не поддерживает метод ${call.method}',
        );
    }
  }

  /// Обработчик вызовов Magento Native
  Future<dynamic> _handleMagentoNativeCall(MethodCall call) async {
    switch (call.method) {
      case 'processPayment':
        final paymentData = Map<String, dynamic>.from(call.arguments);
        return await _processPaymentNative(paymentData);

      case 'downloadEpisode':
        final episodeData = Map<String, dynamic>.from(call.arguments);
        return await _downloadEpisodeNative(episodeData);

      case 'getDeviceCapabilities':
        return await _getDeviceCapabilities();

      case 'performQuantumSync':
        return await _performQuantumSync();

      default:
        throw PlatformException(
          code: 'UNIMPLEMENTED',
          message: 'MagentoNativeService не поддерживает метод ${call.method}',
        );
    }
  }

  /// Запуск мониторинга AnantaSound
  void _startAnantaSoundMonitoring() {
    Timer.periodic(const Duration(seconds: 2), (timer) async {
      try {
        final stats = await _anantaSoundChannel.invokeMethod('getStatistics');
        if (stats != null) {
          final statistics = Map<String, dynamic>.from(stats);
          _purchaseController.add({'type': 'ananta_stats', 'data': statistics});
        }
      } catch (e) {
        debugPrint('❌ Ошибка получения статистики AnantaSound: $e');
      }
    });
  }

  /// Обработка платежа через нативный канал
  Future<Map<String, dynamic>> _processPaymentNative(
      Map<String, dynamic> paymentData) async {
    try {
      final productId = paymentData['product_id'] as String;
      final productType =
          paymentData['product_type'] as String; // 'season' или 'episode'
      final amount = paymentData['amount'] as double;
      final currency = paymentData['currency'] as String;

      // Добавляем информацию об устройстве и AnantaSound
      final enhancedData = {
        ...paymentData,
        'device_info': await _getDeviceInfo(),
        'ananta_sound_stats': await _getAnantaSoundStats(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      if (_magentoProvider != null && isAuthenticated) {
        // Создаем заказ в Magento
        final orderResponse = await _magentoProvider!.dio.post(
          '/rest/V1/mahabharata/orders/create',
          data: enhancedData,
        );

        if (orderResponse.statusCode == 200) {
          final orderData = orderResponse.data;
          final orderId = orderData['order_id'];

          // Обрабатываем платеж
          final paymentResponse = await _magentoProvider!.dio.post(
            '/rest/V1/mahabharata/payments/process',
            data: {
              'order_id': orderId,
              'payment_method': paymentData['payment_method'] ?? 'card',
              'amount': amount,
              'currency': currency,
            },
          );

          if (paymentResponse.statusCode == 200) {
            final paymentResult = paymentResponse.data;

            // Обновляем статус покупки
            _purchaseStatus[productId] = true;
            await _savePurchaseStatus();

            debugPrint('💳 Платеж обработан через нативный канал: $productId');
            return {
              'success': true,
              'order_id': orderId,
              'payment_result': paymentResult,
            };
          }
        }
      }

      return {'success': false, 'error': 'Не удалось обработать платеж'};
    } catch (e) {
      debugPrint('❌ Ошибка обработки платежа: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Загрузка эпизода через нативный канал
  Future<Map<String, dynamic>> _downloadEpisodeNative(
      Map<String, dynamic> episodeData) async {
    try {
      final cloudId = episodeData['cloud_id'] as String;
      final localPath = episodeData['local_path'] as String;

      // Получаем URL для загрузки
      final downloadUrl = await _getDownloadUrl(cloudId);

      if (downloadUrl != null) {
        // Используем нативный канал для загрузки
        final result =
            await _magentoNativeChannel.invokeMethod('downloadFile', {
          'url': downloadUrl,
          'localPath': localPath,
          'cloudId': cloudId,
        });

        debugPrint('📥 Эпизод загружен через нативный канал: $cloudId');
        return result;
      }

      return {
        'success': false,
        'error': 'Не удалось получить URL для загрузки'
      };
    } catch (e) {
      debugPrint('❌ Ошибка загрузки эпизода: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Получение возможностей устройства
  Future<Map<String, dynamic>> _getDeviceCapabilities() async {
    try {
      final capabilities = {
        'platform': defaultTargetPlatform.name,
        'device_info': await _getDeviceInfo(),
        'ananta_sound_available': await _checkAnantaSoundAvailability(),
        'quantum_computing': await _checkQuantumComputingSupport(),
        'dome_rendering': await _checkDomeRenderingSupport(),
        'spatial_audio': await _checkSpatialAudioSupport(),
        'payment_support': await _checkPaymentSupport(),
      };

      return {'success': true, 'capabilities': capabilities};
    } catch (e) {
      debugPrint('❌ Ошибка получения возможностей устройства: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Выполнение квантовой синхронизации
  Future<Map<String, dynamic>> _performQuantumSync() async {
    try {
      // Создаем квантовое звуковое поле для синхронизации
      final quantumField =
          await _anantaSoundChannel.invokeMethod('createQuantumSoundField', {
        'frequency': 440.0,
        'position': {
          'r': 5.0,
          'theta': 0.0,
          'phi': 0.0,
          'height': 2.5,
        },
        'state': 'entangled',
      });

      // Получаем статистику квантового состояния
      final quantumStats = await _getAnantaSoundStats();

      // Синхронизируем с Magento
      if (_magentoProvider != null) {
        final response = await _magentoProvider!.dio.post(
          '/rest/V1/mahabharata/quantum-sync',
          data: {
            'quantum_field': quantumField,
            'quantum_stats': quantumStats,
            'sync_timestamp': DateTime.now().millisecondsSinceEpoch,
          },
        );

        if (response.statusCode == 200) {
          debugPrint('🌌 Квантовая синхронизация выполнена');
          return {'success': true, 'data': response.data};
        }
      }

      return {
        'success': false,
        'error': 'Не удалось выполнить квантовую синхронизацию'
      };
    } catch (e) {
      debugPrint('❌ Ошибка квантовой синхронизации: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Получение статистики AnantaSound
  Future<Map<String, dynamic>> _getAnantaSoundStats() async {
    try {
      final stats = await _anantaSoundChannel.invokeMethod('getStatistics');
      return Map<String, dynamic>.from(stats ?? {});
    } catch (e) {
      debugPrint('❌ Ошибка получения статистики AnantaSound: $e');
      return {};
    }
  }

  /// Проверка доступности AnantaSound
  Future<bool> _checkAnantaSoundAvailability() async {
    try {
      final result = await _anantaSoundChannel.invokeMethod('isAvailable');
      return result == true;
    } catch (e) {
      return false;
    }
  }

  /// Проверка поддержки квантовых вычислений
  Future<bool> _checkQuantumComputingSupport() async {
    try {
      final result =
          await _magentoNativeChannel.invokeMethod('checkQuantumSupport');
      return result == true;
    } catch (e) {
      return false;
    }
  }

  /// Проверка поддержки купольного рендеринга
  Future<bool> _checkDomeRenderingSupport() async {
    try {
      final result =
          await _magentoNativeChannel.invokeMethod('checkDomeSupport');
      return result == true;
    } catch (e) {
      return false;
    }
  }

  /// Проверка поддержки пространственного аудио
  Future<bool> _checkSpatialAudioSupport() async {
    try {
      final result =
          await _magentoNativeChannel.invokeMethod('checkSpatialAudio');
      return result == true;
    } catch (e) {
      return false;
    }
  }

  /// Проверка поддержки платежей
  Future<bool> _checkPaymentSupport() async {
    try {
      final result =
          await _magentoNativeChannel.invokeMethod('checkPaymentSupport');
      return result == true;
    } catch (e) {
      return false;
    }
  }

  /// Получение URL для загрузки
  Future<String?> _getDownloadUrl(String cloudId) async {
    if (_magentoProvider == null) return null;

    try {
      final response = await _magentoProvider!.dio
          .get('/rest/V1/mahabharata/episode/$cloudId/download');

      if (response.statusCode == 200 && response.data != null) {
        return response.data['download_url'] as String?;
      }
    } catch (e) {
      debugPrint('❌ Ошибка получения URL для загрузки: $e');
    }

    return null;
  }

  /// Публичные методы для интеграции с UI

  /// Авторизация пользователя
  Future<bool> authenticateUser({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    if (!_isCloudEnabled || _authProvider == null) {
      return false;
    }

    try {
      final success = await _authProvider!.authenticate(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );

      if (success) {
        debugPrint('👤 Пользователь авторизован через нативный сервис');
        // Загружаем данные после авторизации
        await loadSeasons();
      }

      return success;
    } catch (e) {
      debugPrint('❌ Ошибка авторизации: $e');
      return false;
    }
  }

  /// Загрузка сезонов с информацией о покупках
  Future<List<Season>?> loadSeasons() async {
    if (!_isCloudEnabled || _magentoProvider == null) {
      return null;
    }

    try {
      // Получаем квантовую статистику
      final quantumStats = await _getAnantaSoundStats();

      // Используем новый API для поиска сезонов
      final products = await _magentoProvider!.searchProducts(
        query: 'mahabharata_season',
        page: 1,
        pageSize: 100,
      );

      final seasons = <Season>[];

      for (final product in products) {
        final seasonId = product.id.toString();
        final isPurchased = _purchaseStatus[seasonId] ?? false;

        // Загружаем эпизоды для сезона
        final episodes = await _loadEpisodesForSeason(seasonId);

        final season = Season(
          id: seasonId,
          name: product.name,
          description: product.description ?? '',
          image: _getProductImage(product) ?? '',
          price: (product.price ?? 0.0).toDouble(),
          currency: 'USD',
          isPurchased: isPurchased,
          episodes: episodes,
          order: _getCustomAttribute(product, 'order') ?? 0,
          releaseDate: DateTime.tryParse(product.createdAt ?? ''),
        );

        seasons.add(season);
      }

      _seasons = seasons;
      _seasonsController.add(seasons);

      debugPrint(
          '📚 Загружено ${seasons.length} сезонов с информацией о покупках');
      return seasons;
    } catch (e) {
      debugPrint('❌ Ошибка загрузки сезонов: $e');
      return null;
    }
  }

  /// Загрузка эпизодов для сезона
  Future<List<Episode>> _loadEpisodesForSeason(String seasonId) async {
    try {
      final products = await _magentoProvider!.searchProducts(
        query: 'mahabharata_episode $seasonId',
        page: 1,
        pageSize: 100,
      );

      final episodes = <Episode>[];

      for (final product in products) {
        final episodeId = product.id.toString();
        final isPurchased = _purchaseStatus[episodeId] ?? false;

        final episode = Episode(
          id: episodeId,
          name: product.name,
          description: product.description ?? '',
          image: _getProductImage(product) ?? '',
          price: (product.price ?? 0.0).toDouble(),
          currency: 'USD',
          isPurchased: isPurchased,
          seasonId: seasonId,
          order: _getCustomAttribute(product, 'order') ?? 0,
          audioUrl: _getCustomAttribute(product, 'audio_url'),
          videoUrl: _getCustomAttribute(product, 'video_url'),
          releaseDate: DateTime.tryParse(product.createdAt ?? ''),
        );

        episodes.add(episode);
      }

      return episodes;
    } catch (e) {
      debugPrint('❌ Ошибка загрузки эпизодов для сезона $seasonId: $e');
      return [];
    }
  }

  /// Покупка сезона
  Future<PurchaseResult> purchaseSeason(String seasonId) async {
    try {
      final season = _seasons.firstWhere((s) => s.id == seasonId);

      if (season.isPurchased) {
        return PurchaseResult(
          success: true,
          error: 'Сезон уже куплен',
        );
      }

      final paymentData = {
        'product_id': seasonId,
        'product_type': 'season',
        'amount': season.price,
        'currency': season.currency,
        'payment_method': 'card',
        'product_name': season.name,
      };

      final result = await _magentoNativeChannel.invokeMethod(
          'processPayment', paymentData);

      if (result['success'] == true) {
        // Обновляем статус покупки
        _purchaseStatus[seasonId] = true;
        await _savePurchaseStatus();

        // Обновляем данные
        await loadSeasons();

        _purchaseController.add({
          'type': 'purchase_success',
          'product_type': 'season',
          'product_id': seasonId,
          'data': result,
        });

        debugPrint('💰 Сезон куплен: ${season.name}');

        return PurchaseResult.fromJson(result);
      } else {
        return PurchaseResult(
          success: false,
          error: result['error'] ?? 'Ошибка покупки',
        );
      }
    } catch (e) {
      debugPrint('❌ Ошибка покупки сезона: $e');
      return PurchaseResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Покупка эпизода
  Future<PurchaseResult> purchaseEpisode(String episodeId) async {
    try {
      Episode? episode;
      for (final season in _seasons) {
        episode = season.episodes.firstWhere(
          (e) => e.id == episodeId,
          orElse: () => throw StateError('Episode not found'),
        );
        if (episode != null) break;
      }

      if (episode == null) {
        return PurchaseResult(
          success: false,
          error: 'Эпизод не найден',
        );
      }

      if (episode.isPurchased) {
        return PurchaseResult(
          success: true,
          error: 'Эпизод уже куплен',
        );
      }

      final paymentData = {
        'product_id': episodeId,
        'product_type': 'episode',
        'amount': episode.price,
        'currency': episode.currency,
        'payment_method': 'card',
        'product_name': episode.name,
        'season_id': episode.seasonId,
      };

      final result = await _magentoNativeChannel.invokeMethod(
          'processPayment', paymentData);

      if (result['success'] == true) {
        // Обновляем статус покупки
        _purchaseStatus[episodeId] = true;
        await _savePurchaseStatus();

        // Обновляем данные
        await loadSeasons();

        _purchaseController.add({
          'type': 'purchase_success',
          'product_type': 'episode',
          'product_id': episodeId,
          'data': result,
        });

        debugPrint('💰 Эпизод куплен: ${episode.name}');

        return PurchaseResult.fromJson(result);
      } else {
        return PurchaseResult(
          success: false,
          error: result['error'] ?? 'Ошибка покупки',
        );
      }
    } catch (e) {
      debugPrint('❌ Ошибка покупки эпизода: $e');
      return PurchaseResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Проверка статуса покупки
  bool isPurchased(String productId) {
    return _purchaseStatus[productId] ?? false;
  }

  /// Получение изображения продукта
  String? _getProductImage(dynamic product) {
    try {
      if (product.mediaGalleryEntries != null &&
          product.mediaGalleryEntries.isNotEmpty) {
        return product.mediaGalleryEntries.first.file;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Получение кастомного атрибута продукта
  dynamic _getCustomAttribute(dynamic product, String attributeCode) {
    try {
      if (product.customAttributes != null) {
        for (final attr in product.customAttributes) {
          if (attr.attributeCode == attributeCode) {
            return attr.value;
          }
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Освобождение ресурсов
  Future<void> dispose() async {
    await _seasonsController.close();
    await _episodesController.close();
    await _purchaseController.close();

    _magentoProvider = null;
    _authProvider = null;
    _isInitialized = false;

    debugPrint('🛑 MagentoNativeService остановлен');
  }
}
