import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import 'supabase_service.dart';
import 'account_service.dart';

class TransactionService {
  static const String _tableName = 'transactions';
  static final _uuid = Uuid();

  // 获取所有流水记录
  static Future<List<Transaction>> getTransactions() async {
    try {
      final response = await SupabaseService.client
          .from(_tableName)
          .select('''
            *,
            accounts!transactions_account_id_fkey(name, card_number),
            to_accounts:accounts!transactions_to_account_id_fkey(name, card_number)
          ''')
          .order('created_at', ascending: false);

      return response.map((json) => Transaction.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // 获取特定账户的流水记录
  static Future<List<Transaction>> getTransactionsByAccount(int accountId) async {
    try {
      final response = await SupabaseService.client
          .from(_tableName)
          .select('''
            *,
            accounts!transactions_account_id_fkey(name, card_number),
            to_accounts:accounts!transactions_to_account_id_fkey(name, card_number)
          ''')
          .or('account_id.eq.$accountId,to_account_id.eq.$accountId')
          .order('created_at', ascending: false);

      return response.map((json) => Transaction.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // 根据ID获取交易记录
  static Future<Transaction?> getTransactionById(int id) async {
    try {
      final response = await SupabaseService.client
          .from(_tableName)
          .select('''
            *,
            accounts!transactions_account_id_fkey(name, card_number),
            to_accounts:accounts!transactions_to_account_id_fkey(name, card_number)
          ''')
          .eq('id', id)
          .single();

      return Transaction.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // 创建收入记录
  static Future<Transaction?> createIncome({
    required double amount,
    required int accountId,
    required String category,
    String? description,
    DateTime? dateTime,
  }) async {
    final transaction = Transaction(
      type: TransactionType.income,
      amount: amount.abs(), // 收入为正数
      accountId: accountId,
      category: category,
      description: description,
      createdAt: dateTime ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      // 1. 创建流水记录
      final response = await SupabaseService.client
          .from(_tableName)
          .insert(transaction.toJson())
          .select()
          .single();

      // 2. 更新账户余额
      await _updateAccountBalance(accountId, amount.abs());

      return Transaction.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // 创建收入记录（带物品关联）
  static Future<Transaction?> createIncomeWithItem({
    required double amount,
    required int accountId,
    required String category,
    String? description,
    DateTime? dateTime,
    int? itemId,
    String? itemAction,
  }) async {
    final transaction = Transaction(
      type: TransactionType.income,
      amount: amount.abs(), // 收入为正数
      accountId: accountId,
      itemId: itemId,
      itemAction: itemAction,
      category: category,
      description: description,
      createdAt: dateTime ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      // 1. 创建流水记录
      final response = await SupabaseService.client
          .from(_tableName)
          .insert(transaction.toJson())
          .select()
          .single();

      // 2. 更新账户余额
      await _updateAccountBalance(accountId, amount.abs());

      return Transaction.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // 创建支出记录
  static Future<Transaction?> createExpense({
    required double amount,
    required int accountId,
    required String category,
    String? description,
    DateTime? dateTime,
  }) async {
    final transaction = Transaction(
      type: TransactionType.expense,
      amount: -amount.abs(), // 支出为负数
      accountId: accountId,
      category: category,
      description: description,
      createdAt: dateTime ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      // 1. 创建流水记录
      final response = await SupabaseService.client
          .from(_tableName)
          .insert(transaction.toJson())
          .select()
          .single();

      // 2. 更新账户余额
      await _updateAccountBalance(accountId, -amount.abs());

      return Transaction.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // 创建支出记录（带物品关联）
  static Future<Transaction?> createExpenseWithItem({
    required double amount,
    required int accountId,
    required String category,
    String? description,
    DateTime? dateTime,
    int? itemId,
    String? itemAction,
  }) async {
    final transaction = Transaction(
      type: TransactionType.expense,
      amount: -amount.abs(), // 支出为负数
      accountId: accountId,
      itemId: itemId,
      itemAction: itemAction,
      category: category,
      description: description,
      createdAt: dateTime ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      // 1. 创建流水记录
      final response = await SupabaseService.client
          .from(_tableName)
          .insert(transaction.toJson())
          .select()
          .single();

      // 2. 更新账户余额
      await _updateAccountBalance(accountId, -amount.abs());

      return Transaction.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // 创建转账记录
  static Future<List<Transaction>?> createTransfer({
    required double amount,
    required int fromAccountId,
    required int toAccountId,
    String? description,
    DateTime? dateTime,
  }) async {
    final transferId = _uuid.v4();
    final now = dateTime ?? DateTime.now();

    try {
      // 1. 创建转出记录
      final outTransaction = Transaction(
        type: TransactionType.transfer,
        amount: -amount.abs(),
        accountId: fromAccountId,
        toAccountId: toAccountId,
        transferId: transferId,
        description: description,
        createdAt: now,
        updatedAt: now,
      );

      // 2. 创建转入记录
      final inTransaction = Transaction(
        type: TransactionType.transfer,
        amount: amount.abs(),
        accountId: toAccountId,
        toAccountId: fromAccountId,
        transferId: transferId,
        description: description,
        createdAt: now,
        updatedAt: now,
      );

      // 3. 批量插入两条记录
      final responses = await SupabaseService.client
          .from(_tableName)
          .insert([
            outTransaction.toJson(),
            inTransaction.toJson(),
          ])
          .select();

      // 4. 更新两个账户余额
      await Future.wait([
        _updateAccountBalance(fromAccountId, -amount.abs()),
        _updateAccountBalance(toAccountId, amount.abs()),
      ]);

      return responses.map((json) => Transaction.fromJson(json)).toList();
    } catch (e) {
      return null;
    }
  }

  // 创建其他记录
  static Future<Transaction?> createOther({
    required double amount,
    required int accountId,
    required String category,
    String? description,
    DateTime? dateTime,
  }) async {
    final transaction = Transaction(
      type: TransactionType.other,
      amount: amount, // 保持原始正负号
      accountId: accountId,
      category: category,
      description: description,
      createdAt: dateTime ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      // 1. 创建流水记录
      final response = await SupabaseService.client
          .from(_tableName)
          .insert(transaction.toJson())
          .select()
          .single();

      // 2. 更新账户余额
      await _updateAccountBalance(accountId, amount);

      return Transaction.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // 删除流水记录
  static Future<bool> deleteTransaction(int id) async {
    try {
      // 1. 获取要删除的记录
      final response = await SupabaseService.client
          .from(_tableName)
          .select()
          .eq('id', id)
          .single();

      final transaction = Transaction.fromJson(response);

      // 2. 如果是转账，需要删除关联的另一条记录
      if (transaction.type == TransactionType.transfer && transaction.transferId != null) {
        await SupabaseService.client
            .from(_tableName)
            .delete()
            .eq('transfer_id', transaction.transferId!);
      } else {
        // 3. 删除单条记录
        await SupabaseService.client
            .from(_tableName)
            .delete()
            .eq('id', id);
      }

      // 4. 恢复账户余额（反向操作）
      await _updateAccountBalance(transaction.accountId, -transaction.amount);
      if (transaction.toAccountId != null) {
        await _updateAccountBalance(transaction.toAccountId!, transaction.amount);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // 更新账户余额的私有方法
  static Future<void> _updateAccountBalance(int accountId, double deltaAmount) async {
    final success = await AccountService.updateBalance(accountId, deltaAmount);
    if (!success) {
      throw Exception('Failed to update account balance');
    }
  }

  // 按类型筛选流水
  static List<Transaction> filterByType(List<Transaction> transactions, TransactionType type) {
    return transactions.where((t) => t.type == type).toList();
  }

  // 合并显示转账记录（将同一transfer_id的两条记录合并为一条显示）
  static List<Transaction> mergeTransferRecords(List<Transaction> transactions) {
    final Map<String, Transaction> transferMap = {};
    final List<Transaction> result = [];

    for (final transaction in transactions) {
      if (transaction.type == TransactionType.transfer && 
          transaction.transferId != null &&
          transaction.amount < 0) { // 只保留转出记录作为代表
        transferMap[transaction.transferId!] = transaction;
      } else if (transaction.type != TransactionType.transfer) {
        result.add(transaction);
      }
    }

    result.addAll(transferMap.values);
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result;
  }
}
