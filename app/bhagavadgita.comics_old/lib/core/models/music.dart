/// Модель музыки из legacy приложений
class Music {
  final int id;
  final String name;
  final String description;
  final String image;
  final String file;
  final int duration; // в секундах
  final String author;
  final int order;

  Music({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.file,
    this.duration = 0,
    this.author = '',
    this.order = 0,
  });

  factory Music.fromJson(Map<String, dynamic> json) {
    return Music(
      id: json['id'] as int? ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      file: json['file']?.toString() ?? '',
      duration: json['duration'] as int? ?? 0,
      author: json['author']?.toString() ?? '',
      order: json['order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'file': file,
      'duration': duration,
      'author': author,
      'order': order,
    };
  }

  /// Получить длительность в формате MM:SS
  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  String toString() {
    return 'Music(id: $id, name: $name, duration: $formattedDuration)';
  }
}

/// Список музыки
class MusicList {
  final List<Music> items;

  MusicList({
    required this.items,
  });

  factory MusicList.fromJson(Map<String, dynamic> json) {
    return MusicList(
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => Music.fromJson(e as Map<String, dynamic>))
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
