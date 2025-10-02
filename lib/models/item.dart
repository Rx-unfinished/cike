import 'package:flutter/material.dart';

enum ItemStatus {
  active,     // 在用
  idle,       // 闲置
  damaged,    // 损坏
  sold,       // 已出售
  lost,       // 丢失
}

enum ItemCondition {
  newItem,      // 全新
  likeNew,      // 几乎全新
  excellent,     // 优秀
  good,          // 良好
  fair,          // 一般
  poor,          // 较差
}

class Item {
  final int? id;
  final String name;
  final String? description;
  final String? category;
  final String? brand;
  final String? model;
  final String? serialNumber;
  final double? purchasePrice;
  final DateTime? purchaseDate;
  final int? purchaseAccountId;
  final int? purchaseTransactionId;
  final ItemStatus status;
  final ItemCondition condition;
  final String? location;
  final String? imageUrl;
  final List<String>? tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  // 关联的账户信息（用于显示）
  final String? purchaseAccountName;

  Item({
    this.id,
    required this.name,
    this.description,
    this.category,
    this.brand,
    this.model,
    this.serialNumber,
    this.purchasePrice,
    this.purchaseDate,
    this.purchaseAccountId,
    this.purchaseTransactionId,
    this.status = ItemStatus.active,
    this.condition = ItemCondition.good,
    this.location,
    this.imageUrl,
    this.tags,
    required this.createdAt,
    required this.updatedAt,
    this.purchaseAccountName,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      brand: json['brand'],
      model: json['model'],
      serialNumber: json['serial_number'],
      purchasePrice: json['purchase_price']?.toDouble(),
      purchaseDate: json['purchase_date'] != null 
          ? DateTime.parse(json['purchase_date']) 
          : null,
      purchaseAccountId: json['purchase_account_id'],
      purchaseTransactionId: json['purchase_transaction_id'],
      status: ItemStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => ItemStatus.active,
      ),
      condition: ItemCondition.values.firstWhere(
        (e) => e.toString().split('.').last == json['condition'],
        orElse: () => ItemCondition.good,
      ),
      location: json['location'],
      imageUrl: json['image_url'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      purchaseAccountName: json['accounts']?['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (description != null) 'description': description,
      if (category != null) 'category': category,
      if (brand != null) 'brand': brand,
      if (model != null) 'model': model,
      if (serialNumber != null) 'serial_number': serialNumber,
      if (purchasePrice != null) 'purchase_price': purchasePrice,
      if (purchaseDate != null) 'purchase_date': purchaseDate!.toIso8601String(),
      if (purchaseAccountId != null) 'purchase_account_id': purchaseAccountId,
      if (purchaseTransactionId != null) 'purchase_transaction_id': purchaseTransactionId,
      'status': status.toString().split('.').last,
      'condition': condition.toString().split('.').last,
      if (location != null) 'location': location,
      if (imageUrl != null) 'image_url': imageUrl,
      if (tags != null) 'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // 获取状态显示名称
  String get statusDisplayName {
    switch (status) {
      case ItemStatus.active:
        return '在用';
      case ItemStatus.idle:
        return '闲置';
      case ItemStatus.damaged:
        return '损坏';
      case ItemStatus.sold:
        return '已出售';
      case ItemStatus.lost:
        return '丢失';
    }
  }

  // 获取状态颜色
  Color get statusColor {
    switch (status) {
      case ItemStatus.active:
        return Colors.green;
      case ItemStatus.idle:
        return Colors.orange;
      case ItemStatus.damaged:
        return Colors.red;
      case ItemStatus.sold:
        return Colors.blue;
      case ItemStatus.lost:
        return Colors.grey;
    }
  }

  // 获取状态图标
  IconData get statusIcon {
    switch (status) {
      case ItemStatus.active:
        return Icons.check_circle;
      case ItemStatus.idle:
        return Icons.pause_circle;
      case ItemStatus.damaged:
        return Icons.error;
      case ItemStatus.sold:
        return Icons.sell;
      case ItemStatus.lost:
        return Icons.help;
    }
  }

  // 获取成色显示名称
  String get conditionDisplayName {
    switch (condition) {
      case ItemCondition.newItem:
        return '全新';
      case ItemCondition.likeNew:
        return '几乎全新';
      case ItemCondition.excellent:
        return '优秀';
      case ItemCondition.good:
        return '良好';
      case ItemCondition.fair:
        return '一般';
      case ItemCondition.poor:
        return '较差';
    }
  }

  // 获取成色颜色
  Color get conditionColor {
    switch (condition) {
      case ItemCondition.newItem:
        return Colors.green;
      case ItemCondition.likeNew:
        return Colors.lightGreen;
      case ItemCondition.excellent:
        return Colors.blue;
      case ItemCondition.good:
        return Colors.orange;
      case ItemCondition.fair:
        return Colors.deepOrange;
      case ItemCondition.poor:
        return Colors.red;
    }
  }

  // 获取格式化的购买价格
  String get formattedPurchasePrice {
    if (purchasePrice == null) return '未记录';
    return '¥${purchasePrice!.toStringAsFixed(2)}';
  }

  // 获取格式化的购买日期
  String get formattedPurchaseDate {
    if (purchaseDate == null) return '未记录';
    return '${purchaseDate!.year}-${purchaseDate!.month.toString().padLeft(2, '0')}-${purchaseDate!.day.toString().padLeft(2, '0')}';
  }

  // 获取完整名称（品牌 + 型号 + 名称）
  String get fullName {
    final parts = <String>[];
    if (brand != null && brand!.isNotEmpty) parts.add(brand!);
    if (model != null && model!.isNotEmpty) parts.add(model!);
    parts.add(name);
    return parts.join(' ');
  }

  // 计算持有天数
  int get daysOwned {
    final startDate = purchaseDate ?? createdAt;
    return DateTime.now().difference(startDate).inDays;
  }
}

// 物品分类
class ItemCategory {
  static const List<String> categories = [
    '电子产品',
    '家用电器',
    '家具',
    '服装鞋帽',
    '书籍文具',
    '运动器材',
    '厨房用品',
    '数码配件',
    '汽车用品',
    '美妆护肤',
    '玩具游戏',
    '其他',
  ];

  // 获取分类图标
  static IconData getCategoryIcon(String? category) {
    switch (category) {
      case '电子产品':
        return Icons.devices;
      case '家用电器':
        return Icons.home;
      case '家具':
        return Icons.chair;
      case '服装鞋帽':
        return Icons.checkroom;
      case '书籍文具':
        return Icons.book;
      case '运动器材':
        return Icons.fitness_center;
      case '厨房用品':
        return Icons.kitchen;
      case '数码配件':
        return Icons.cable;
      case '汽车用品':
        return Icons.directions_car;
      case '美妆护肤':
        return Icons.face;
      case '玩具游戏':
        return Icons.toys;
      default:
        return Icons.inventory;
    }
  }

  // 获取分类颜色
  static Color getCategoryColor(String? category) {
    switch (category) {
      case '电子产品':
        return Colors.blue;
      case '家用电器':
        return Colors.green;
      case '家具':
        return Colors.brown;
      case '服装鞋帽':
        return Colors.purple;
      case '书籍文具':
        return Colors.orange;
      case '运动器材':
        return Colors.red;
      case '厨房用品':
        return Colors.teal;
      case '数码配件':
        return Colors.indigo;
      case '汽车用品':
        return Colors.grey;
      case '美妆护肤':
        return Colors.pink;
      case '玩具游戏':
        return Colors.amber;
      default:
        return Colors.blueGrey;
    }
  }
}
