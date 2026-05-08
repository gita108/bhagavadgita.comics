/// Модель комикса из legacy приложений
///
/// Представляет интерактивный комикс с анимациями и звуками
class Comics {
  final int width;
  final int height;
  final List<ComicsLayer> layers;
  final List<ComicsSound> sounds;

  Comics({
    required this.width,
    required this.height,
    required this.layers,
    required this.sounds,
  });

  factory Comics.fromJson(Map<String, dynamic> json) {
    return Comics(
      width: json['width'] as int? ?? 0,
      height: json['height'] as int? ?? 0,
      layers: (json['layers'] as List<dynamic>?)
              ?.map((e) => ComicsLayer.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      sounds: (json['sounds'] as List<dynamic>?)
              ?.map((e) => ComicsSound.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'height': height,
      'layers': layers.map((e) => e.toJson()).toList(),
      'sounds': sounds.map((e) => e.toJson()).toList(),
    };
  }
}

/// Слой комикса с изображением и анимациями
class ComicsLayer {
  final String id;
  final ComicsImage image;
  final List<ComicsAnimation> animations;
  final int order;
  final bool isPreview;

  ComicsLayer({
    required this.id,
    required this.image,
    required this.animations,
    this.order = 0,
    this.isPreview = false,
  });

  factory ComicsLayer.fromJson(Map<String, dynamic> json) {
    return ComicsLayer(
      id: json['id']?.toString() ?? '',
      image: ComicsImage.fromJson(json['image'] as Map<String, dynamic>? ?? {}),
      animations: (json['animations'] as List<dynamic>?)
              ?.map((e) => ComicsAnimation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      order: json['order'] as int? ?? 0,
      isPreview: json['preview'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image.toJson(),
      'animations': animations.map((e) => e.toJson()).toList(),
      'order': order,
      'preview': isPreview,
    };
  }
}

/// Изображение в слое комикса
class ComicsImage {
  final String file;
  final int width;
  final int height;

  ComicsImage({
    required this.file,
    this.width = 0,
    this.height = 0,
  });

  factory ComicsImage.fromJson(Map<String, dynamic> json) {
    return ComicsImage(
      file: json['file']?.toString() ?? '',
      width: json['width'] as int? ?? 0,
      height: json['height'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'file': file,
      'width': width,
      'height': height,
    };
  }
}

/// Анимация слоя комикса
class ComicsAnimation {
  final String type; // translate, scale, rotate, alpha, sound
  final int start;
  final int end;
  final Map<String, dynamic> params;

  ComicsAnimation({
    required this.type,
    required this.start,
    required this.end,
    this.params = const {},
  });

  factory ComicsAnimation.fromJson(Map<String, dynamic> json) {
    return ComicsAnimation(
      type: json['type']?.toString() ?? '',
      start: json['start'] as int? ?? 0,
      end: json['end'] as int? ?? 0,
      params: json['params'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'start': start,
      'end': end,
      'params': params,
    };
  }
}

/// Звук в комиксе
class ComicsSound {
  final String file;
  final int start;
  final int? end;
  final double volume;
  final bool loop;
  final bool isPoint; // Точечный звук (играет один раз при достижении позиции)

  ComicsSound({
    required this.file,
    required this.start,
    this.end,
    this.volume = 1.0,
    this.loop = false,
    this.isPoint = false,
  });

  factory ComicsSound.fromJson(Map<String, dynamic> json) {
    return ComicsSound(
      file: json['file']?.toString() ?? '',
      start: json['start'] as int? ?? 0,
      end: json['end'] as int?,
      volume: (json['volume'] as num?)?.toDouble() ?? 1.0,
      loop: json['loop'] as bool? ?? false,
      isPoint: json['point'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'file': file,
      'start': start,
      'end': end,
      'volume': volume,
      'loop': loop,
      'point': isPoint,
    };
  }
}

/// Дескриптор комикса (метаданные о файле)
class ComicsDescriptor {
  final String comicsFile;
  final String dataFile;
  final String imagesPath;
  final String soundsPath;
  final int version;

  ComicsDescriptor({
    required this.comicsFile,
    required this.dataFile,
    required this.imagesPath,
    required this.soundsPath,
    this.version = 1,
  });

  factory ComicsDescriptor.fromJson(Map<String, dynamic> json) {
    return ComicsDescriptor(
      comicsFile: json['comicsFile']?.toString() ?? '',
      dataFile: json['dataFile']?.toString() ?? '',
      imagesPath: json['imagesPath']?.toString() ?? '',
      soundsPath: json['soundsPath']?.toString() ?? '',
      version: json['version'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'comicsFile': comicsFile,
      'dataFile': dataFile,
      'imagesPath': imagesPath,
      'soundsPath': soundsPath,
      'version': version,
    };
  }
}
