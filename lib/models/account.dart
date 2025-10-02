class Account {
  final int? id;
  final String name;           // 账户名称（银行/平台）
  final String cardNumber;     // 卡号/手机号/邮箱
  final AccountType type;      // 账户类型
  final double balance;        // 当前余额
  final AccountStatus status;  // 账户状态
  final String? remark;        // 备注
  final String? iconPath;      // 图标路径
  final DateTime createdAt;
  final DateTime updatedAt;

  Account({
    this.id,
    required this.name,
    required this.cardNumber,
    required this.type,
    required this.balance,
    required this.status,
    this.remark,
    this.iconPath,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'],
      name: json['name'],
      cardNumber: json['card_number'],
      type: AccountType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => AccountType.debit,
      ),
      balance: json['balance']?.toDouble() ?? 0.0,
      status: AccountStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => AccountStatus.active,
      ),
      remark: json['remark'],
      iconPath: json['icon_path'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'card_number': cardNumber,
      'type': type.toString().split('.').last,
      'balance': balance,
      'status': status.toString().split('.').last,
      if (remark != null) 'remark': remark,
      if (iconPath != null) 'icon_path': iconPath,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // 获取格式化的卡号（脱敏）
  String get maskedCardNumber {
    if (cardNumber.length <= 4) return cardNumber;
    return '****${cardNumber.substring(cardNumber.length - 4)}';
  }

  // 获取账户类型的中文显示
  String get typeDisplayName {
    switch (type) {
      case AccountType.debit:
        return '储蓄卡';
      case AccountType.credit:
        return '信用卡';
      case AccountType.wallet:
        return '电子钱包';
      case AccountType.investment:
        return '投资账户';
      case AccountType.cash:
        return '现金';
      case AccountType.prepaid:
        return '储值卡';
    }
  }

  // 获取账户分组
  AccountGroup get group {
    switch (type) {
      case AccountType.debit:
      case AccountType.wallet:
      case AccountType.cash:
        return AccountGroup.assets;
      case AccountType.credit:
        return AccountGroup.credit;
      case AccountType.investment:
        return AccountGroup.investment;
      case AccountType.prepaid:
        return AccountGroup.prepaid;
    }
  }
}

// 账户类型枚举
enum AccountType {
  debit,      // 储蓄卡
  credit,     // 信用卡
  wallet,     // 电子钱包
  investment, // 投资账户
  cash,       // 现金
  prepaid,    // 储值卡
}

// 账户状态枚举
enum AccountStatus {
  active,     // 使用中
  inactive,   // 已停用
  closed,     // 已注销
}

// 账户分组枚举
enum AccountGroup {
  assets,     // 资金账户
  credit,     // 信用账户
  investment, // 投资账户
  prepaid,    // 储值账户
}

// 扩展方法获取分组显示名称
extension AccountGroupExtension on AccountGroup {
  String get displayName {
    switch (this) {
      case AccountGroup.assets:
        return '资金账户';
      case AccountGroup.credit:
        return '信用账户';
      case AccountGroup.investment:
        return '投资账户';
      case AccountGroup.prepaid:
        return '储值账户';
    }
  }
}
