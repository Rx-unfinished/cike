// 必要的导入
import 'package:flutter/material.dart';
import 'package:cike/models/account.dart';

// 构造函数参数（接口定义）
class AccountSelectorWidget extends StatelessWidget {
  final List<Account> accounts;
  final Account? selectedAccount;
  final Function(Account?) onChanged;
  final String? placeholder;
  final bool enabled;

  const AccountSelectorWidget ({
    super.key,
    required this.accounts,
    required this.onChanged,
    this.selectedAccount,
    this.placeholder = '选择账户',
    this.enabled = true,
  });

  // 基本的build方法结构
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Account>(
          value: selectedAccount,
          isExpanded: true,
          hint: Text(placeholder ?? '选择账户'),
          items: accounts.map((account) {
            return DropdownMenuItem<Account>(
              value: account,
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _getAccountColor(account.type).withAlpha(26),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      _getAccountIcon(account.type),
                      color: _getAccountColor(account.type),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          account.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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
                ],
              ),
            );
          }).toList(),
          onChanged: enabled ? onChanged : null,
        )
      )
    );
  }

  // 获取账户类型对应的颜色
  Color _getAccountColor(AccountType type) {
    switch (type) {
      case AccountType.debit:
        return Colors.blue;
      case AccountType.credit:
        return Colors.orange;
      case AccountType.wallet:
        return Colors.green;
      case AccountType.investment:
        return Colors.purple;
      case AccountType.cash:
        return Colors.brown;
      case AccountType.prepaid:
        return Colors.teal;
    }
  }

  // 获取账户类型对应的图标
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
        return Icons.payments;
      case AccountType.prepaid:
        return Icons.card_giftcard;
    }
  }
}