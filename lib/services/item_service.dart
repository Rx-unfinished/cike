import '../models/item.dart';
import '../models/transaction.dart';
import '../services/supabase_service.dart';
import '../services/transaction_service.dart';

class ItemService {
  static const String _tableName = 'items';

  // 获取所有物品
  static Future<List<Item>> getItems({ItemStatus? status, String? category}) async {
    try {
      var query = SupabaseService.client
          .from(_tableName)
          .select('''
            *,
            accounts!items_purchase_account_id_fkey(name)
          ''');

      if (status != null) {
        query = query.eq('status', status.toString().split('.').last);
      }

      if (category != null && category.isNotEmpty) {
        query = query.eq('category', category);
      }

      final response = await query.order('created_at', ascending: false);

      return response.map((json) => Item.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // 根据ID获取物品
  static Future<Item?> getItemById(int id) async {
    try {
      final response = await SupabaseService.client
          .from(_tableName)
          .select('''
            *,
            accounts!items_purchase_account_id_fkey(name)
          ''')
          .eq('id', id)
          .single();

      return Item.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // 创建物品
  static Future<Item?> createItem(Item item) async {
    try {
      final response = await SupabaseService.client
          .from(_tableName)
          .insert(item.toJson())
          .select()
          .single();

      return Item.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // 创建物品并关联已有交易记录
  static Future<Item?> createItemWithExistingTransaction({
    required Item item,
    required Transaction transaction,
  }) async {
    try {
      // 1. 创建物品记录
      final createdItem = await createItem(item);
      if (createdItem == null) {
        throw Exception('创建物品失败');
      }

      // 2. 更新交易记录，关联物品ID
      await _updateTransactionItemId(transaction.id!, createdItem.id!);

      return createdItem;
    } catch (e) {
      return null;
    }
  }

  // 创建物品并关联购买交易
  static Future<Item?> createItemWithPurchase({
    required Item item,
    required double purchaseAmount,
    required int accountId,
    String? description,
    DateTime? purchaseDateTime,
  }) async {
    try {
      // 1. 创建购买支出记录，添加物品关联信息
      final transaction = await TransactionService.createExpenseWithItem(
        amount: purchaseAmount,
        accountId: accountId,
        category: '购物',
        description: description ?? '购买${item.name}',
        dateTime: purchaseDateTime,
        itemAction: 'purchase',
      );

      if (transaction == null) {
        throw Exception('创建购买记录失败');
      }

      // 2. 创建物品，关联交易信息
      final newItem = Item(
        name: item.name,
        description: item.description,
        category: item.category,
        brand: item.brand,
        model: item.model,
        serialNumber: item.serialNumber,
        purchasePrice: purchaseAmount,
        purchaseDate: purchaseDateTime ?? DateTime.now(),
        purchaseAccountId: accountId,
        purchaseTransactionId: transaction.id,
        status: item.status,
        condition: item.condition,
        location: item.location,
        imageUrl: item.imageUrl,
        tags: item.tags,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final createdItem = await createItem(newItem);
      if (createdItem == null) {
        throw Exception('创建物品失败');
      }

      // 3. 更新交易记录，关联物品ID
      await _updateTransactionItemId(transaction.id!, createdItem.id!);

      return createdItem;
    } catch (e) {
      return null;
    }
  }

  // 更新物品
  static Future<Item?> updateItem(Item item) async {
    try {
      final response = await SupabaseService.client
          .from(_tableName)
          .update({
            ...item.toJson(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', item.id!)
          .select()
          .single();

      return Item.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // 删除物品
  static Future<bool> deleteItem(int id) async {
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

  // 出售物品
  static Future<bool> sellItem({
    required int itemId,
    required double sellPrice,
    required int accountId,
    String? description,
    DateTime? sellDateTime,
  }) async {
    try {
      // 1. 创建出售收入记录
      final transaction = await TransactionService.createIncomeWithItem(
        amount: sellPrice,
        accountId: accountId,
        category: '出售物品',
        description: description ?? '出售物品',
        dateTime: sellDateTime,
        itemId: itemId,
        itemAction: 'sell',
      );

      if (transaction == null) {
        throw Exception('创建出售记录失败');
      }

      // 2. 更新物品状态为已出售
      final item = await getItemById(itemId);
      if (item == null) {
        throw Exception('物品不存在');
      }

      final updatedItem = Item(
        id: item.id,
        name: item.name,
        description: item.description,
        category: item.category,
        brand: item.brand,
        model: item.model,
        serialNumber: item.serialNumber,
        purchasePrice: item.purchasePrice,
        purchaseDate: item.purchaseDate,
        purchaseAccountId: item.purchaseAccountId,
        purchaseTransactionId: item.purchaseTransactionId,
        status: ItemStatus.sold,
        condition: item.condition,
        location: item.location,
        imageUrl: item.imageUrl,
        tags: item.tags,
        createdAt: item.createdAt,
        updatedAt: DateTime.now(),
      );

      await updateItem(updatedItem);
      return true;
    } catch (e) {
      return false;
    }
  }

  // 添加维修记录
  static Future<bool> addMaintenanceRecord({
    required int itemId,
    required double amount,
    required int accountId,
    String? description,
    DateTime? dateTime,
  }) async {
    try {
      final transaction = await TransactionService.createExpenseWithItem(
        amount: amount,
        accountId: accountId,
        category: '维修',
        description: description ?? '物品维修',
        dateTime: dateTime,
        itemId: itemId,
        itemAction: 'maintenance',
      );

      return transaction != null;
    } catch (e) {
      return false;
    }
  }

  // 获取物品的相关交易记录
  static Future<List<Transaction>> getItemTransactions(int itemId) async {
    try {
      final response = await SupabaseService.client
          .from('transactions')
          .select('''
            *,
            accounts!transactions_account_id_fkey(name, card_number)
          ''')
          .eq('item_id', itemId)
          .order('created_at', ascending: false);

      return response.map((json) => Transaction.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // 按分类获取物品统计
  static Future<Map<String, int>> getItemStatsByCategory() async {
    try {
      final response = await SupabaseService.client
          .from(_tableName)
          .select('category')
          .neq('status', 'sold');

      final Map<String, int> stats = {};
      for (final item in response) {
        final category = item['category'] ?? '其他';
        stats[category] = (stats[category] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      return {};
    }
  }

  // 按状态获取物品统计
  static Future<Map<ItemStatus, int>> getItemStatsByStatus() async {
    try {
      final response = await SupabaseService.client
          .from(_tableName)
          .select('status');

      final Map<ItemStatus, int> stats = {};
      for (final status in ItemStatus.values) {
        stats[status] = 0;
      }

      for (final item in response) {
        final status = ItemStatus.values.firstWhere(
          (e) => e.toString().split('.').last == item['status'],
          orElse: () => ItemStatus.active,
        );
        stats[status] = (stats[status] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      return {};
    }
  }

  // 搜索物品
  static Future<List<Item>> searchItems(String query) async {
    try {
      final response = await SupabaseService.client
          .from(_tableName)
          .select('''
            *,
            accounts!items_purchase_account_id_fkey(name)
          ''')
          .or('name.ilike.%$query%,brand.ilike.%$query%,model.ilike.%$query%,description.ilike.%$query%')
          .order('created_at', ascending: false);

      return response.map((json) => Item.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // 更新交易记录的物品ID
  static Future<void> _updateTransactionItemId(int transactionId, int itemId) async {
    try {
      await SupabaseService.client
          .from('transactions')
          .update({
            'item_id': itemId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', transactionId);
    } catch (e) {
      rethrow;
    }
  }
}
