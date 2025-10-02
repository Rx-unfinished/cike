import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/transaction_service.dart';
import '../widgets/record_speed_dial.dart';
import '../widgets/finance/transaction_card.dart';
import 'income_form_page.dart';
import 'expense_form_page.dart';
import 'transfer_form_page.dart';
import 'other_form_page.dart';

class IncomeExpensePage extends StatefulWidget {
  const IncomeExpensePage({super.key});

  @override
  State<IncomeExpensePage> createState() => _IncomeExpensePageState();
}

class _IncomeExpensePageState extends State<IncomeExpensePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<Transaction> _allTransactions = [];
  List<Transaction> _filteredTransactions = [];
  bool _isLoading = true;
  int _currentTabIndex = 0;

  final List<String> _tabs = ['全部', '收入', '支出', '转账', '其他'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadTransactions();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _currentTabIndex = _tabController.index;
        _filterTransactions();
      });
    }
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final transactions = await TransactionService.getTransactions();
      setState(() {
        _allTransactions = TransactionService.mergeTransferRecords(transactions);
        _filterTransactions();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败: $e')),
        );
    }
  }

  void _filterTransactions() {
    switch (_currentTabIndex) {
      case 0: // 全部
        _filteredTransactions = _allTransactions;
        break;
      case 1: // 收入
        _filteredTransactions = TransactionService.filterByType(
          _allTransactions, 
          TransactionType.income
        );
        break;
      case 2: // 支出
        _filteredTransactions = TransactionService.filterByType(
          _allTransactions, 
          TransactionType.expense
        );
        break;
      case 3: // 转账
        _filteredTransactions = TransactionService.filterByType(
          _allTransactions, 
          TransactionType.transfer
        );
        break;
      case 4: // 其他
        _filteredTransactions = TransactionService.filterByType(
          _allTransactions, 
          TransactionType.other
        );
        break;
    }
  }

  void _handleRecordTypeSelected(TransactionType type) async {
    Widget page;
    
    switch (type) {
      case TransactionType.income:
        page = const IncomeFormPage();
        break;
      case TransactionType.expense:
        page = const ExpenseFormPage();
        break;
      case TransactionType.transfer:
        page = const TransferFormPage();
        break;
      case TransactionType.other:
        page = const OtherFormPage();
        break;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder:(context) => page),
    );

    if (result == true) {
      _loadTransactions();
    }
  }

  void _handleTransactionTap(Transaction transaction) {
    // 跳转到交易详情或编辑页面
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('查看${transaction.typeDisplayName}详情'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _handleTransactionLongPress(Transaction transaction) {
    // 显示操作菜单（编辑/删除）
    _showTransactionMenu(transaction);
  }

  void _showTransactionMenu(Transaction transaction) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('编辑'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('编辑功能开发中')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('删除', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(transaction);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除这条${transaction.typeDisplayName}记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);

              navigator.pop();
              final success = await TransactionService.deleteTransaction(transaction.id!);

              if (!mounted) return;

              if (success) {
                _loadTransactions();
                messenger.showSnackBar(
                  const SnackBar(content: Text('删除成功')),
                );
              } else {
                messenger.showSnackBar(
                  const SnackBar(content: Text('删除失败')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('收支流水'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredTransactions.isEmpty
              ? _buildEmptyState()
              : _buildTransactionList(),
      floatingActionButton: RecordSpeedDial(
        onRecordTypeSelected: _handleRecordTypeSelected,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            '还没有收支记录',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '点击右下角按钮开始记录',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    return RefreshIndicator(
      onRefresh: _loadTransactions,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredTransactions.length,
        itemBuilder: (context, index) {
          final transaction = _filteredTransactions[index];
          return TransactionCard(
            transaction: transaction,
            onTap: () => _handleTransactionTap(transaction),
            onLongPress: () => _handleTransactionLongPress(transaction),
          );
        },
      ),
    );
  }
}
