import 'package:flutter/material.dart';

enum TransactionType {
  income,    // 收入
  expense,   // 支出  
  transfer,  // 转账
  other,     // 其他
}

class Transaction {
  final int? id;
  final TransactionType type;
  final double amount;
  final int accountId;
  final int? toAccountId;        // 转账目标账户ID（仅转账时使用）
  final String? transferId;      // 转账关联ID（仅转账时使用）
  final int? itemId;             // 关联物品ID（物品相关交易时使用）
  final String? itemAction;      // 物品操作类型：purchase, sell, maintenance等
  final String? category;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  // 关联的账户信息（用于显示）
  final String? accountName;
  final String? accountCardNumber;
  final String? toAccountName;   // 转账目标账户名称

  Transaction({
    this.id,
    required this.type,
    required this.amount,
    required this.accountId,
    this.toAccountId,
    this.transferId,
    this.itemId,
    this.itemAction,
    this.category,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.accountName,
    this.accountCardNumber,
    this.toAccountName,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      type: TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => TransactionType.expense,
      ),
      amount: json['amount']?.toDouble() ?? 0.0,
      accountId: json['account_id'],
      toAccountId: json['to_account_id'],
      transferId: json['transfer_id'],
      itemId: json['item_id'],
      itemAction: json['item_action'],
      category: json['category'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      accountName: json['accounts']?['name'],
      accountCardNumber: json['accounts']?['card_number'],
      toAccountName: json['to_accounts']?['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'type': type.toString().split('.').last,
      'amount': amount,
      'account_id': accountId,
      if (toAccountId != null) 'to_account_id': toAccountId,
      if (transferId != null) 'transfer_id': transferId,
      if (itemId != null) 'item_id': itemId,
      if (itemAction != null) 'item_action': itemAction,
      if (category != null) 'category': category,
      if (description != null) 'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // 获取类型显示名称
  String get typeDisplayName {
    switch (type) {
      case TransactionType.income:
        return '收入';
      case TransactionType.expense:
        return '支出';
      case TransactionType.transfer:
        return '转账';
      case TransactionType.other:
        return '其他';
    }
  }

  // 获取格式化的卡号
  String get maskedCardNumber {
    if (accountCardNumber == null) return '';
    if (accountCardNumber!.length <= 4) return accountCardNumber!;
    return '****${accountCardNumber!.substring(accountCardNumber!.length - 4)}';
  }

  // 获取格式化的金额显示
  String get formattedAmount {
    final absAmount = amount.abs().toStringAsFixed(2);
    
    switch (type) {
      case TransactionType.income:
        return '+¥$absAmount';
      case TransactionType.expense:
        return '-¥$absAmount';
      case TransactionType.transfer:
        return '¥$absAmount';
      case TransactionType.other:
        return amount >= 0 ? '+¥$absAmount' : '-¥$absAmount';
    }
  }

  // 获取金额颜色
  Color get amountColor {
    switch (type) {
      case TransactionType.income:
        return Colors.green;
      case TransactionType.expense:
        return Colors.red;
      case TransactionType.transfer:
        return Colors.blue;
      case TransactionType.other:
        return amount >= 0 ? Colors.green : Colors.red;
    }
  }

  // 获取类型图标
  IconData get typeIcon {
    switch (type) {
      case TransactionType.income:
        return Icons.arrow_downward;
      case TransactionType.expense:
        return Icons.arrow_upward;
      case TransactionType.transfer:
        return Icons.swap_horiz;
      case TransactionType.other:
        return Icons.more_horiz;
    }
  }
}

// 收入分类
class IncomeCategory {
  static const List<String> categories = [
    '工资',
    '奖金',
    '投资收益',
    '副业收入',
    '退款',
    '礼金',
    '其他收入',
  ];
}

// 支出分类
class ExpenseCategory {
  static const List<String> categories = [
    '餐饮',
    '购物',
    '交通',
    '住房',
    '医疗',
    '娱乐',
    '教育',
    '通讯',
    '其他支出',
  ];
}

// 其他分类
class OtherCategory {
  static const List<String> categories = [
    '垫付',
    '报销',
    '借出',
    '收回',
    '代付',
    '代收',
    '其他',
  ];
}
