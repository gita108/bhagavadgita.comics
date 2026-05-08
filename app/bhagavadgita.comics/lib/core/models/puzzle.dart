/// Модель пазла из legacy приложений
class Puzzle {
  final int id;
  final String name;
  final String description;
  final String image;
  final String file;
  final int rows;
  final int columns;
  final int version;
  final int order;

  Puzzle({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.file,
    this.rows = 4,
    this.columns = 4,
    this.version = 1,
    this.order = 0,
  });

  factory Puzzle.fromJson(Map<String, dynamic> json) {
    return Puzzle(
      id: json['id'] as int? ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      file: json['file']?.toString() ?? '',
      rows: json['rows'] as int? ?? 4,
      columns: json['columns'] as int? ?? 4,
      version: json['version'] as int? ?? 1,
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
      'rows': rows,
      'columns': columns,
      'version': version,
      'order': order,
    };
  }

  /// Общее количество кусочков пазла
  int get totalPieces => rows * columns;

  @override
  String toString() {
    return 'Puzzle(id: $id, name: $name, pieces: $totalPieces)';
  }
}

/// Список пазлов
class PuzzleList {
  final List<Puzzle> items;

  PuzzleList({
    required this.items,
  });

  factory PuzzleList.fromJson(Map<String, dynamic> json) {
    return PuzzleList(
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => Puzzle.fromJson(e as Map<String, dynamic>))
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

/// Состояние кусочка пазла
class PuzzlePieceState {
  final int id;
  final int row;
  final int column;
  final double x;
  final double y;
  final bool isPlaced;

  PuzzlePieceState({
    required this.id,
    required this.row,
    required this.column,
    this.x = 0.0,
    this.y = 0.0,
    this.isPlaced = false,
  });

  factory PuzzlePieceState.fromJson(Map<String, dynamic> json) {
    return PuzzlePieceState(
      id: json['id'] as int? ?? 0,
      row: json['row'] as int? ?? 0,
      column: json['column'] as int? ?? 0,
      x: (json['x'] as num?)?.toDouble() ?? 0.0,
      y: (json['y'] as num?)?.toDouble() ?? 0.0,
      isPlaced: json['isPlaced'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'row': row,
      'column': column,
      'x': x,
      'y': y,
      'isPlaced': isPlaced,
    };
  }

  PuzzlePieceState copyWith({
    int? id,
    int? row,
    int? column,
    double? x,
    double? y,
    bool? isPlaced,
  }) {
    return PuzzlePieceState(
      id: id ?? this.id,
      row: row ?? this.row,
      column: column ?? this.column,
      x: x ?? this.x,
      y: y ?? this.y,
      isPlaced: isPlaced ?? this.isPlaced,
    );
  }
}
