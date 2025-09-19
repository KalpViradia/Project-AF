import '../utils/import_export.dart';

class Category {
  final int categoryId;
  final String name;
  final String? description;
  final String color;
  final String icon;
  final bool isActive;

  Category({
    required this.categoryId,
    required this.name,
    this.description,
    required this.color,
    required this.icon,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'name': name,
      'description': description,
      'color': color,
      'icon': icon,
      'isActive': isActive,
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryId: json['categoryId'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      color: json['color'] ?? '#2196F3',
      icon: json['icon'] ?? 'event',
      isActive: json['isActive'] == true || json['isActive'] == 1,
    );
  }

  Category copyWith({
    int? categoryId,
    String? name,
    String? description,
    String? color,
    String? icon,
    bool? isActive,
  }) {
    return Category(
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
    );
  }

  Color get colorValue {
    try {
      return Color(int.parse(color.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }

  IconData get iconData {
    switch (icon.toLowerCase()) {
      default:
        return Icons.event_note;
    }
  }
}
