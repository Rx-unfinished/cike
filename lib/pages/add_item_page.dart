import 'package:flutter/material.dart';
import '../models/item.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../services/item_service.dart';
import '../services/account_service.dart';
import '../services/transaction_service.dart';
import '../widgets/finance/purchase_option_widget.dart';
import '../widgets/finance/transaction_selector_widget.dart';
import '../widgets/finance/transaction_info_card.dart';
import '../widgets/basic_info_tab.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // 基本信息控制器
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _serialNumberController = TextEditingController();
  final _locationController = TextEditingController();
  final _tagController = TextEditingController();

  // 购买信息控制器
  final _purchasePriceController = TextEditingController();

  // 状态变量
  String? _selectedCategory;
  ItemStatus _selectedStatus = ItemStatus.active;
  ItemCondition _selectedCondition = ItemCondition.good;
  DateTime? _purchaseDate;
  List<Account> _accounts = [];
  Account? _selectedAccount;
  // ignore: prefer_final_fields
  List<String> _tags = [];

  bool _isLoading = false;
  bool _recordPurchase = false;
  bool _linkExistingTransaction = false;
  List<Transaction> _unlinkedTransactions = [];
  Transaction? _selectedTransaction;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAccounts();
    _loadUnlinkedTransactions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _serialNumberController.dispose();
    _locationController.dispose();
    _purchasePriceController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _loadAccounts() async {
    final accounts = await AccountService.getAccounts();
    setState(() {
      _accounts = accounts.where((account) => account.status == AccountStatus.active).toList();
      if (_accounts.isNotEmpty) {
        _selectedAccount = _accounts.first;
      }
    });
  }

  Future<void> _loadUnlinkedTransactions() async {
    try {
      final allTransactions = await TransactionService.getTransactions();
      final unlinked = allTransactions.where((transaction) => 
        transaction.type == TransactionType.expense && 
        transaction.itemId == null &&
        transaction.category == '购物'
      ).toList();
      
      setState(() {
        _unlinkedTransactions = unlinked;
      });
    } catch (e) {
      // 静默处理
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加物品'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveItem,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    '保存',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          tabs: const [
            Tab(text: '基本信息'),
            Tab(text: '购买信息'),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            BasicInfoTab(
              nameController: _nameController,
              descriptionController: _descriptionController,
              brandController: _brandController,
              modelController: _modelController,
              serialNumberController: _serialNumberController,
              locationController: _locationController,
              tagController: _tagController,
              selectedCategory: _selectedCategory,
              selectedStatus: _selectedStatus,
              selectedCondition: _selectedCondition,
              tags: _tags,
              onCategoryChanged: (value) => setState(() => _selectedCategory = value),
              onStatusChanged: (value) => setState(() => _selectedStatus = value),
              onConditionChanged: (value) => setState(() => _selectedCondition = value),
              onAddTag: _addTag,
              onRemoveTag: (tag) => setState(() => _tags.remove(tag)),
            ),
            _buildPurchaseInfoTab(),
          ],
        ),
      ),
    );
  }

  // 购买信息tab - 简化版
  Widget _buildPurchaseInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 购买选项卡片
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withAlpha(13),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withAlpha(52)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '购买记录选择',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                
                // 三个选项
                PurchaseOptionWidget(
                  isSelected: !_recordPurchase && !_linkExistingTransaction,
                  icon: Icons.inventory,
                  title: '仅添加物品',
                  subtitle: '不关联任何购买记录',
                  onTap: () => setState(() {
                    _recordPurchase = false;
                    _linkExistingTransaction = false;
                    _selectedTransaction = null;
                  }),
                ),
                const SizedBox(height: 8),
                
                PurchaseOptionWidget(
                  isSelected: _linkExistingTransaction,
                  icon: Icons.link,
                  title: '关联已有购买记录',
                  subtitle: '从未关联物品的支出记录中选择',
                  onTap: () => setState(() {
                    _recordPurchase = false;
                    _linkExistingTransaction = true;
                    _selectedTransaction = null;
                  }),
                ),
                const SizedBox(height: 8),
                
                PurchaseOptionWidget(
                  isSelected: _recordPurchase,
                  icon: Icons.add_shopping_cart,
                  title: '创建新购买记录',
                  subtitle: '同时创建支出记录并关联',
                  onTap: () => setState(() {
                    _recordPurchase = true;
                    _linkExistingTransaction = false;
                    _selectedTransaction = null;
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 根据选择显示不同内容
          if (_linkExistingTransaction) ...[
            const Text('选择购买记录 *', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TransactionSelectorWidget(
              transactions: _unlinkedTransactions,
              selectedTransaction: _selectedTransaction,
              onChanged: (transaction) => setState(() {
                _selectedTransaction = transaction;
                if (transaction != null) {
                  _purchasePriceController.text = transaction.amount.abs().toString();
                  _purchaseDate = transaction.createdAt;
                }
              }),
            ),
            if (_selectedTransaction != null) ...[
              const SizedBox(height: 16),
              TransactionInfoCard(transaction: _selectedTransaction!),
            ],
          ] else if (_recordPurchase) ...[
            // 创建新记录的表单内容
            const Text('购买价格 *', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            // 这里可以添加价格输入、账户选择等
          ] else ...[
            // 仅添加物品的表单内容
            const Text('参考价格（可选）', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            // 这里可以添加参考价格输入
          ],
        ],
      ),
    );
  }

  void _addTag(String tag) {
    final trimmedTag = tag.trim();
    if (trimmedTag.isNotEmpty && !_tags.contains(trimmedTag)) {
      setState(() {
        _tags.add(trimmedTag);
        _tagController.clear();
      });
    }
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final item = Item(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        category: _selectedCategory,
        brand: _brandController.text.trim().isEmpty ? null : _brandController.text.trim(),
        model: _modelController.text.trim().isEmpty ? null : _modelController.text.trim(),
        serialNumber: _serialNumberController.text.trim().isEmpty ? null : _serialNumberController.text.trim(),
        purchasePrice: _purchasePriceController.text.trim().isEmpty ? null : double.parse(_purchasePriceController.text),
        purchaseDate: _linkExistingTransaction ? _selectedTransaction?.createdAt : _purchaseDate,
        purchaseAccountId: _linkExistingTransaction ? _selectedTransaction?.accountId : _selectedAccount?.id,
        purchaseTransactionId: _linkExistingTransaction ? _selectedTransaction?.id : null,
        status: _selectedStatus,
        condition: _selectedCondition,
        location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        tags: _tags.isEmpty ? null : _tags,
        createdAt: now,
        updatedAt: now,
      );

      Item? createdItem;

      if (_linkExistingTransaction && _selectedTransaction != null) {
        createdItem = await ItemService.createItemWithExistingTransaction(
          item: item,
          transaction: _selectedTransaction!,
        );
      } else if (_recordPurchase) {
        // 实现创建新购买记录的逻辑
        createdItem = await ItemService.createItem(item);
      } else {
        createdItem = await ItemService.createItem(item);
      }
      if (!mounted) return;

      if (createdItem != null) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_linkExistingTransaction ? '物品和购买记录关联成功' : '物品保存成功'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存失败: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
