import 'package:flutter/material.dart';
import 'package:cike/models/transaction.dart';

// 交易记录选择器组件
class TransactionSelectorWidget extends StatelessWidget {
  final List<Transaction> transactions;
  final Transaction? selectedTransaction;
  final Function(Transaction?) onChanged;

  const TransactionSelectorWidget({
    super.key,
    required this.transactions,
    required this.selectedTransaction,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withAlpha(26),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.withAlpha(78)),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange[700]),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                '暂无未关联物品的购物支出记录',
                style: TextStyle(color: Colors.black87),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Transaction>(
          value: selectedTransaction,
          isExpanded: true,
          hint: const Text('选择购买记录'),
          items: transactions.map((transaction) {
            return DropdownMenuItem<Transaction>(
              value: transaction,
              child: _buildTransactionItem(transaction),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                transaction.description ?? '购物支出',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              transaction.formattedAmount,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: transaction.amountColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Text(
              transaction.accountName ?? '',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const Spacer(),
            Text(
              _formatDateTime(transaction.createdAt),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
