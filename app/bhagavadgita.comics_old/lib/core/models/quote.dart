/// Модель цитаты из Mahabharata
class Quote {
  final int id;
  final String text;
  final String author;
  final String source; // Источник (книга, глава)
  final String image;
  final int order;
  final Map<String, String>? translations; // Переводы на разные языки

  Quote({
    required this.id,
    required this.text,
    required this.author,
    this.source = '',
    this.image = '',
    this.order = 0,
    this.translations,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'] as int? ?? 0,
      text: json['text']?.toString() ?? '',
      author: json['author']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      order: json['order'] as int? ?? 0,
      translations: json['translations'] != null
          ? Map<String, String>.from(json['translations'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'author': author,
      'source': source,
      'image': image,
      'order': order,
      'translations': translations,
    };
  }

  /// Получить текст на нужном языке
  String getLocalizedText(String languageCode) {
    if (translations != null && translations!.containsKey(languageCode)) {
      return translations![languageCode]!;
    }
    return text;
  }

  @override
  String toString() {
    return 'Quote(id: $id, author: $author, text: ${text.substring(0, text.length > 50 ? 50 : text.length)}...)';
  }
}

/// Список цитат
class QuoteList {
  final List<Quote> items;

  QuoteList({
    required this.items,
  });

  factory QuoteList.fromJson(Map<String, dynamic> json) {
    return QuoteList(
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => Quote.fromJson(e as Map<String, dynamic>))
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
