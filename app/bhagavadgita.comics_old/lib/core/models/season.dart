/// Модель сезона Mahabharata
///
/// Представляет сезон (книгу) Mahabharata с списком эпизодов
class Season {
  final String id;
  final String sku;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final int episodeCount;
  final bool isPurchased;
  final List<String> languages;
  final DateTime? releaseDate;
  final Map<String, dynamic>? customAttributes;

  Season({
    required this.id,
    required this.sku,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    this.episodeCount = 0,
    this.isPurchased = false,
    this.languages = const ['en', 'ru', 'hi'],
    this.releaseDate,
    this.customAttributes,
  });

  /// Создать Season из Magento продукта
  factory Season.fromMagentoProduct(Map<String, dynamic> product) {
    return Season(
      id: product['id']?.toString() ?? '',
      sku: product['sku']?.toString() ?? '',
      name: product['name']?.toString() ?? 'Unknown Season',
      description: product['description']?.toString() ?? '',
      price: (product['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: _extractImageUrl(product),
      episodeCount: _extractEpisodeCount(product),
      isPurchased: _extractPurchaseStatus(product),
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

  static int _extractEpisodeCount(Map<String, dynamic> product) {
    final customAttrs = product['custom_attributes'] as Map<String, dynamic>?;
    if (customAttrs != null && customAttrs.containsKey('episode_count')) {
      return int.tryParse(customAttrs['episode_count'].toString()) ?? 0;
    }
    return 0;
  }

  static bool _extractPurchaseStatus(Map<String, dynamic> product) {
    // TODO: Реализовать проверку покупки из истории заказов
    return false;
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
      'episodeCount': episodeCount,
      'isPurchased': isPurchased,
      'languages': languages,
      'releaseDate': releaseDate?.toIso8601String(),
      'customAttributes': customAttributes,
    };
  }

  /// Создать копию с изменениями
  Season copyWith({
    String? id,
    String? sku,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    int? episodeCount,
    bool? isPurchased,
    List<String>? languages,
    DateTime? releaseDate,
    Map<String, dynamic>? customAttributes,
  }) {
    return Season(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      episodeCount: episodeCount ?? this.episodeCount,
      isPurchased: isPurchased ?? this.isPurchased,
      languages: languages ?? this.languages,
      releaseDate: releaseDate ?? this.releaseDate,
      customAttributes: customAttributes ?? this.customAttributes,
    );
  }

  @override
  String toString() {
    return 'Season(id: $id, name: $name, episodes: $episodeCount, price: \$$price)';
  }
}
