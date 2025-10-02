import '../models/account.dart';
import 'supabase_service.dart';

class AccountService {
  static const String _tableName = 'accounts';

  // 获取所有账户
  static Future<List<Account>> getAccounts() async {
    try {
      final response = await SupabaseService.client
          .from(_tableName)
          .select()
          .order('created_at', ascending: false);

      return response.map((json) => Account.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // 创建账户
  static Future<Account?> createAccount({
    required String name,
    required String cardNumber,
    required AccountType type,
    required double balance,
    required AccountStatus status,
    String? remark,
    String? iconPath,
  }) async {
    final account = Account(
      name: name,
      cardNumber: cardNumber,
      type: type,
      balance: balance,
      status: status,
      remark: remark,
      iconPath: iconPath,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      final response = await SupabaseService.client
          .from(_tableName)
          .insert(account.toJson())
          .select()
          .single();

      return Account.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // 更新账户
  static Future<bool> updateAccount(int id, Map<String, dynamic> updates) async {
    try {
      updates['updated_at'] = DateTime.now().toIso8601String();
      
      await SupabaseService.client
          .from(_tableName)
          .update(updates)
          .eq('id', id);
      return true;
    } catch (e) {
      return false;
    }
  }

  // 删除账户
  static Future<bool> deleteAccount(int id) async {
    try {
      await SupabaseService.client
          .from(_tableName)
          .delete()
          .eq('id', id);
      return true;
    } catch (e) {
      return false;
    }
  }

  // 按分组获取账户
  static Map<AccountGroup, List<Account>> groupAccountsByType(List<Account> accounts) {
    final Map<AccountGroup, List<Account>> grouped = {};
    
    for (final group in AccountGroup.values) {
      grouped[group] = accounts.where((account) => account.group == group).toList();
    }
    
    return grouped;
  }

  // 计算总资产
  static double calculateTotalAssets(List<Account> accounts) {
    return accounts
        .where((account) => account.group != AccountGroup.credit)
        .fold(0.0, (sum, account) => sum + account.balance);
  }

  // 计算总负债
  static double calculateTotalDebt(List<Account> accounts) {
    return accounts
        .where((account) => account.group == AccountGroup.credit)
        .fold(0.0, (sum, account) => sum + account.balance.abs());
  }

  // 计算净资产
  static double calculateNetWorth(List<Account> accounts) {
    return calculateTotalAssets(accounts) - calculateTotalDebt(accounts);
  }

  // 按分组计算余额
  static double calculateGroupBalance(List<Account> accounts, AccountGroup group) {
    return accounts
        .where((account) => account.group == group)
        .fold(0.0, (sum, account) => sum + account.balance);
  }

  // 余额更新
  static Future<bool> updateBalance(int accountId, double deltaAmount) async {
    try {
      // 获取当前余额
      final response = await SupabaseService.client
          .from(_tableName)
          .select('balance')
          .eq('id', accountId)
          .single();

      final currentBalance = response['balance']?.toDouble() ?? 0.0;
      final newBalance = currentBalance + deltaAmount;

      // 更新余额
      await SupabaseService.client
          .from(_tableName)
          .update({
            'balance': newBalance,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', accountId);

      return true;
    } catch (e) {
      return false;
    }
  }
}
