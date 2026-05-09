/// Модель подписки из legacy приложений
class Subscription {
  final int id;
  final String name;
  final String description;
  final String product; // Product ID для покупок
  final double price;
  final String? priceFormatted;
  final String period; // monthly, yearly, etc.
  final int duration; // в днях
  final List<String> features;
  final bool isTrial;
  final int order;

  Subscription({
    required this.id,
    required this.name,
    required this.description,
    required this.product,
    required this.price,
    this.priceFormatted,
    this.period = 'monthly',
    this.duration = 30,
    this.features = const [],
    this.isTrial = false,
    this.order = 0,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as int? ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      product: json['product']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      priceFormatted: json['priceFormatted']?.toString(),
      period: json['period']?.toString() ?? 'monthly',
      duration: json['duration'] as int? ?? 30,
      features: (json['features'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isTrial: json['isTrial'] as bool? ?? false,
      order: json['order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'product': product,
      'price': price,
      'priceFormatted': priceFormatted,
      'period': period,
      'duration': duration,
      'features': features,
      'isTrial': isTrial,
      'order': order,
    };
  }

  /// Получить отображаемую цену
  String get displayPrice => priceFormatted ?? '\$$price';

  @override
  String toString() {
    return 'Subscription(id: $id, name: $name, price: $displayPrice, period: $period)';
  }
}

/// Список подписок
class SubscriptionList {
  final List<Subscription> items;

  SubscriptionList({
    required this.items,
  });

  factory SubscriptionList.fromJson(Map<String, dynamic> json) {
    return SubscriptionList(
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => Subscription.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}
