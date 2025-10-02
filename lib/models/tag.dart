import 'package:flutter/material.dart';

class Tag {
  final int? id;
  final String name;
  final String? color;
  final int usageCount;
  final bool isSystem;
  final DateTime createdAt;

  Tag({
    this.id,
    required this.name,
    this.color,
    this.usageCount = 0,
    this.isSystem = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Color get flutterColor {
    if (color == null) return Colors.grey;
    try {
      // support #FF5722 code
      return Color(int.parse(color!.replaceFirst('#', '0xff')));
    } catch (e) {
      return Colors.grey; // if failed, return default color
    }
  }


  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'],
      name: json['name'],
      color: json['color'],
      usageCount: json['usage_count'] ?? 0,
      isSystem: json['is_system'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'color': color,
      'usage_count': usageCount,
      'is_system': isSystem,
      'created_at': createdAt.toIso8601String(),
    };
  }
}