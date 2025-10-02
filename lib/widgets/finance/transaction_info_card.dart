import 'package:flutter/material.dart';
import 'package:cike/models/transaction.dart';

// 交易信息展示卡片组件
class TransactionInfoCard extends StatelessWidget {
  final Transaction transaction;

  const TransactionInfoCard({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withAlpha(13),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withAlpha(52)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                '已选择购买记录',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('交易描述', transaction.description ?? '购物支出'),
          _buildInfoRow('支出金额', transaction.formattedAmount),
          _buildInfoRow('使用账户', transaction.accountName ?? ''),
          _buildInfoRow('交易时间', _formatDateTime(transaction.createdAt)),
          const SizedBox(height: 8),
          Text(
            '物品的购买价格和日期将自动填入上述信息',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
