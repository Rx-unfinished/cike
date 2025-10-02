import 'package:flutter/material.dart';
import '../models/account.dart';
import '../services/account_service.dart';
import '../widgets/finance/add_account_dialog.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  // ignore: prefer_final_fields
  List<Account> _accounts = [];
  bool _isLoading = true;
  // ignore: prefer_final_fields
  Map<AccountGroup, bool> _groupExpanded = {
    AccountGroup.assets: true,
    AccountGroup.credit: true,
    AccountGroup.investment: true,
    AccountGroup.prepaid: true,
  };

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final accounts = await AccountService.getAccounts();
      setState(() {
        _accounts = accounts;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('账户'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddAccountDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _accounts.isEmpty
              ? _buildEmptyState()
              : _buildAccountList(),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            '还没有账户',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '点击右上角 + 号添加第一个账户',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountList() {
    final groupedAccounts = AccountService.groupAccountsByType(_accounts);
    final totalAssets = AccountService.calculateTotalAssets(_accounts);
    final totalDebt = AccountService.calculateTotalDebt(_accounts);
    final netWorth = AccountService.calculateNetWorth(_accounts);

    return RefreshIndicator(
      onRefresh: _loadAccounts,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 总览卡片
          _buildOverviewCard(netWorth, totalAssets, totalDebt),
          const SizedBox(height: 24),
          
          // 账户分组列表
          ...AccountGroup.values.map((group) {
            final accounts = groupedAccounts[group] ?? [];
            if (accounts.isEmpty) return const SizedBox.shrink();
            
            return Column(
              children: [
                _buildGroupHeader(group, accounts),
                if (_groupExpanded[group]!) ...
                  accounts.map((account) => _buildAccountCard(account)),
                const SizedBox(height: 16),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(double netWorth, double totalAssets, double totalDebt) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '净资产',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '¥${_formatAmount(netWorth)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '总资产',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '¥${_formatAmount(totalAssets)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '总负债',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '¥${_formatAmount(totalDebt)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGroupHeader(AccountGroup group, List<Account> accounts) {
    final groupBalance = AccountService.calculateGroupBalance(accounts, group);
    final isExpanded = _groupExpanded[group]!;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _groupExpanded[group] = !isExpanded;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text(
              '${group.displayName} (${accounts.length})',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            Text(
              group == AccountGroup.credit 
                  ? '欠款 ¥${_formatAmount(groupBalance.abs())}'
                  : '余额 ¥${_formatAmount(groupBalance)}',
              style: TextStyle(
                fontSize: 14,
                color: group == AccountGroup.credit ? Colors.red : Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountCard(Account account) {
    return GestureDetector(
      onTap: () => _showEditAccountDialog(account),
      onLongPressStart: (details) => _showAccountContextMenu(context, details.globalPosition, account),
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            // 账户图标
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getAccountColor(account.type).withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getAccountIcon(account.type),
                color: _getAccountColor(account.type),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // 账户信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${account.typeDisplayName} ${account.maskedCardNumber}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // 余额
            Text(
              account.group == AccountGroup.credit
                  ? '-¥${_formatAmount(account.balance.abs())}'
                  : '¥${_formatAmount(account.balance)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: account.group == AccountGroup.credit ? Colors.red : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getAccountIcon(AccountType type) {
    switch (type) {
      case AccountType.debit:
        return Icons.account_balance;
      case AccountType.credit:
        return Icons.credit_card;
      case AccountType.wallet:
        return Icons.account_balance_wallet;
      case AccountType.investment:
        return Icons.trending_up;
      case AccountType.cash:
        return Icons.money;
      case AccountType.prepaid:
        return Icons.card_giftcard;
    }
  }

  Color _getAccountColor(AccountType type) {
    switch (type) {
      case AccountType.debit:
        return Colors.blue;
      case AccountType.credit:
        return Colors.red;
      case AccountType.wallet:
        return Colors.green;
      case AccountType.investment:
        return Colors.orange;
      case AccountType.cash:
        return Colors.amber;
      case AccountType.prepaid:
        return Colors.purple;
    }
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(2);
  }

  Future<void> _showEditAccountDialog(Account account) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AddAccountDialog(editAccount: account),
    );

    // 如果返回true，表示需要刷新列表
    if (result == true) {
      _loadAccounts();
    }
  }

  Future<void> _showAccountContextMenu(BuildContext context, Offset position, Account account) async {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        position & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      items: [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 16),
              SizedBox(width: 8),
              Text('编辑'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 16, color: Colors.red),
              SizedBox(width: 8),
              Text('删除', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );

    if (result == 'edit') {
      _showEditAccountDialog(account);
    } else if (result == 'delete') {
      _showDeleteConfirmDialog(account);
    }
  }

  Future<void> _showDeleteConfirmDialog(Account account) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除账户「${account.name}」吗？\n\n删除后无法恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await AccountService.deleteAccount(account.id!);

      if (!mounted) return;

      if (success) {
        _loadAccounts();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('账户「${account.name}」已删除')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('删除失败，请重试')),
        );
      }
    }
  }

  Future<void> _showAddAccountDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AddAccountDialog(),
    );

    // 如果返回true，表示需要刷新列表
    if (result == true) {
      _loadAccounts();
    }
  }
}