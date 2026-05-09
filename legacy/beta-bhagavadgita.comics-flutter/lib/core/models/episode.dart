/// Модель эпизода Mahabharata
///
/// Представляет один эпизод (главу) с интерактивным комиксом
class Episode {
  final String id;
  final String sku;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final String seasonId;
  final int episodeNumber;
  final bool isPurchased;
  final bool isFree;
  final String? comicsFileUrl;
  final String? audioFileUrl;
  final Duration? duration;
  final List<String> languages;
  final DateTime? releaseDate;
  final Map<String, dynamic>? customAttributes;

  Episode({
    required this.id,
    required this.sku,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.seasonId,
    required this.episodeNumber,
    this.isPurchased = false,
    this.isFree = false,
    this.comicsFileUrl,
    this.audioFileUrl,
    this.duration,
    this.languages = const ['en', 'ru', 'hi'],
    this.releaseDate,
    this.customAttributes,
  });

  /// Создать Episode из Magento продукта
  factory Episode.fromMagentoProduct(Map<String, dynamic> product) {
    return Episode(
      id: product['id']?.toString() ?? '',
      sku: product['sku']?.toString() ?? '',
      name: product['name']?.toString() ?? 'Unknown Episode',
      description: product['description']?.toString() ?? '',
      price: (product['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: _extractImageUrl(product),
      seasonId: _extractSeasonId(product),
      episodeNumber: _extractEpisodeNumber(product),
      isPurchased: _extractPurchaseStatus(product),
      isFree: _extractFreeStatus(product),
      comicsFileUrl: _extractComicsFileUrl(product),
      audioFileUrl: _extractAudioFileUrl(product),
      duration: _extractDuration(product),
      languages: _extractLanguages(product),
      releaseDate: _extractReleaseDate(product),
      customAttributes: product['custom_attributes'] as Map<String, dynamic>?,
    );
  }

  static String? _extractImageUrl(Map<String, dynamic> product) {
    if (product['media_gallery_entries'] != null) {
      final gallery = product['media_gallery_entries'] as List?;
      if (gallery != null && gallery.isNotEmpty) {
        return gallery[0]['file'] as String?;
      }
    }
    return product['image'] as String?;
  }

  static String _extractSeasonId(Map<String, dynamic> product) {
    final customAttrs = product['custom_attributes'] as Map<String, dynamic>?;
    if (customAttrs != null && customAttrs.containsKey('season_id')) {
      return customAttrs['season_id'].toString();
    }
    return '';
  }

  static int _extractEpisodeNumber(Map<String, dynamic> product) {
    final customAttrs = product['custom_attributes'] as Map<String, dynamic>?;
    if (customAttrs != null && customAttrs.containsKey('episode_number')) {
      return int.tryParse(customAttrs['episode_number'].toString()) ?? 0;
    }
    return 0;
  }

  static bool _extractPurchaseStatus(Map<String, dynamic> product) {
    // TODO: Реализовать проверку покупки из истории заказов
    return false;
  }

  static bool _extractFreeStatus(Map<String, dynamic> product) {
    final price = (product['price'] as num?)?.toDouble() ?? 0.0;
    if (price == 0.0) return true;

    final customAttrs = product['custom_attributes'] as Map<String, dynamic>?;
    if (customAttrs != null && customAttrs.containsKey('is_free')) {
      return customAttrs['is_free'].toString().toLowerCase() == 'true';
    }

    return false;
  }

  static String? _extractComicsFileUrl(Map<String, dynamic> product) {
    final customAttrs = product['custom_attributes'] as Map<String, dynamic>?;
    if (customAttrs != null && customAttrs.containsKey('comics_file_url')) {
      return customAttrs['comics_file_url'] as String?;
    }

    // Или использовать downloadable links
    if (product['downloadable_links'] != null) {
      final links = product['downloadable_links'] as List?;
      if (links != null && links.isNotEmpty) {
        for (var link in links) {
          if (link['title']?.toString().toLowerCase().contains('comics') ??
              false) {
            return link['link_url'] as String?;
          }
        }
      }
    }

    return null;
  }

  static String? _extractAudioFileUrl(Map<String, dynamic> product) {
    final customAttrs = product['custom_attributes'] as Map<String, dynamic>?;
    if (customAttrs != null && customAttrs.containsKey('audio_file_url')) {
      return customAttrs['audio_file_url'] as String?;
    }

    // Или использовать downloadable links
    if (product['downloadable_links'] != null) {
      final links = product['downloadable_links'] as List?;
      if (links != null && links.isNotEmpty) {
        for (var link in links) {
          if (link['title']?.toString().toLowerCase().contains('audio') ??
              false) {
            return link['link_url'] as String?;
          }
        }
      }
    }

    return null;
  }

  static Duration? _extractDuration(Map<String, dynamic> product) {
    final customAttrs = product['custom_attributes'] as Map<String, dynamic>?;
    if (customAttrs != null && customAttrs.containsKey('duration')) {
      final durationStr = customAttrs['duration'].toString();
      final minutes = int.tryParse(durationStr);
      if (minutes != null) {
        return Duration(minutes: minutes);
      }
    }
    return null;
  }

  static List<String> _extractLanguages(Map<String, dynamic> product) {
    final customAttrs = product['custom_attributes'] as Map<String, dynamic>?;
    if (customAttrs != null && customAttrs.containsKey('languages')) {
      final languagesStr = customAttrs['languages'].toString();
      return languagesStr.split(',').map((e) => e.trim()).toList();
    }
    return ['en', 'ru', 'hi'];
  }

  static DateTime? _extractReleaseDate(Map<String, dynamic> product) {
    final customAttrs = product['custom_attributes'] as Map<String, dynamic>?;
    if (customAttrs != null && customAttrs.containsKey('release_date')) {
      return DateTime.tryParse(customAttrs['release_date'].toString());
    }
    return null;
  }

  /// Конвертировать в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sku': sku,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'seasonId': seasonId,
      'episodeNumber': episodeNumber,
      'isPurchased': isPurchased,
      'isFree': isFree,
      'comicsFileUrl': comicsFileUrl,
      'audioFileUrl': audioFileUrl,
      'duration': duration?.inMinutes,
      'languages': languages,
      'releaseDate': releaseDate?.toIso8601String(),
      'customAttributes': customAttributes,
    };
  }

  /// Создать копию с изменениями
  Episode copyWith({
    String? id,
    String? sku,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? seasonId,
    int? episodeNumber,
    bool? isPurchased,
    bool? isFree,
    String? comicsFileUrl,
    String? audioFileUrl,
    Duration? duration,
    List<String>? languages,
    DateTime? releaseDate,
    Map<String, dynamic>? customAttributes,
  }) {
    return Episode(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      seasonId: seasonId ?? this.seasonId,
      episodeNumber: episodeNumber ?? this.episodeNumber,
      isPurchased: isPurchased ?? this.isPurchased,
      isFree: isFree ?? this.isFree,
      comicsFileUrl: comicsFileUrl ?? this.comicsFileUrl,
      audioFileUrl: audioFileUrl ?? this.audioFileUrl,
      duration: duration ?? this.duration,
      languages: languages ?? this.languages,
      releaseDate: releaseDate ?? this.releaseDate,
      customAttributes: customAttributes ?? this.customAttributes,
    );
  }

  /// Проверить, доступен ли эпизод для просмотра
  bool get isAvailable => isFree || isPurchased;

  /// Получить статус эпизода (Free, Bought, Price)
  String get statusLabel {
    if (isFree) return 'FREE';
    if (isPurchased) return 'BOUGHT';
    return '\$$price';
  }

  @override
  String toString() {
    return 'Episode(id: $id, name: $name, #$episodeNumber, price: \$$price, available: $isAvailable)';
  }
}
