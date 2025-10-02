import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cike/models/account.dart';
import 'package:cike/services/account_service.dart';

class AddAccountDialog extends StatefulWidget {
  final Account? editAccount; // 如果传入则为编辑模式

  const AddAccountDialog({
    super.key,
    this.editAccount,
  });

  @override
  State<AddAccountDialog> createState() => _AddAccountDialogState();
}

class _AddAccountDialogState extends State<AddAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _balanceController = TextEditingController();
  final _remarkController = TextEditingController();

  AccountType _selectedType = AccountType.debit;
  AccountStatus _selectedStatus = AccountStatus.active;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 如果是编辑模式，填充现有数据
    if (widget.editAccount != null) {
      final account = widget.editAccount!;
      _nameController.text = account.name;
      _cardNumberController.text = account.cardNumber;
      // 信用卡显示欠款金额（正数），其他显示实际余额
      if (account.type == AccountType.credit) {
        _balanceController.text = account.balance.abs().toString();
      } else {
        _balanceController.text = account.balance.toString();
      }
      _remarkController.text = account.remark ?? '';
      _selectedType = account.type;
      _selectedStatus = account.status;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cardNumberController.dispose();
    _balanceController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.editAccount != null;
    
    return Dialog(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题
                Text(
                  isEdit ? '编辑账户' : '添加账户',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // 账户名称
                _buildFieldLabel('账户名称', required: true),
                _buildTextField(
                  controller: _nameController,
                  hintText: '例如：招商银行、支付宝',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入账户名称';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 卡号/账号
                _buildFieldLabel('卡号/账号', required: true),
                _buildTextField(
                  controller: _cardNumberController,
                  hintText: '例如：6225********1234',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入卡号或账号';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 账户类型
                _buildFieldLabel('账户类型'),
                _buildTypeDropdown(),
                const SizedBox(height: 16),

                // 当前余额
                _buildFieldLabel('当前余额'),
                Row(
                  children: [
                    if (_selectedType == AccountType.credit) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                          color: Colors.grey[50],
                        ),
                        child: Text(
                          '欠款',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                    Expanded(
                      child: _buildTextField(
                        controller: _balanceController,
                        hintText: _selectedType == AccountType.credit ? '输入欠款金额' : '0.00',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                        borderRadius: _selectedType == AccountType.credit 
                            ? const BorderRadius.only(
                                topRight: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 账户状态
                _buildFieldLabel('账户状态'),
                _buildStatusDropdown(),
                const SizedBox(height: 16),

                // 备注
                _buildFieldLabel('备注'),
                _buildTextField(
                  controller: _remarkController,
                  hintText: '例如：工资卡、日常消费',
                  maxLines: 2,
                ),
                const SizedBox(height: 32),

                // 按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      child: const Text('取消'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveAccount,
                      child: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(isEdit ? '更新' : '保存'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          children: [
            TextSpan(text: label),
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
    BorderRadius? borderRadius,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[400]),
        border: OutlineInputBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<AccountType>(
      initialValue: _selectedType,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      items: AccountType.values.map((type) {
        return DropdownMenuItem<AccountType>(
          value: type,
          child: Row(
            children: [
              Icon(
                _getAccountIcon(type),
                size: 20,
                color: _getAccountColor(type),
              ),
              const SizedBox(width: 12),
              Text(_getTypeDisplayName(type)),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedType = value;
            // 切换账户类型时，清空余额输入
            _balanceController.clear();
          });
        }
      },
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<AccountStatus>(
      initialValue: _selectedStatus,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      items: AccountStatus.values.map((status) {
        return DropdownMenuItem<AccountStatus>(
          value: status,
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getStatusColor(status),
                ),
              ),
              const SizedBox(width: 12),
              Text(_getStatusDisplayName(status)),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedStatus = value;
          });
        }
      },
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

  String _getTypeDisplayName(AccountType type) {
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

  Color _getStatusColor(AccountStatus status) {
    switch (status) {
      case AccountStatus.active:
        return Colors.green;
      case AccountStatus.inactive:
        return Colors.orange;
      case AccountStatus.closed:
        return Colors.red;
    }
  }

  String _getStatusDisplayName(AccountStatus status) {
    switch (status) {
      case AccountStatus.active:
        return '使用中';
      case AccountStatus.inactive:
        return '已停用';
      case AccountStatus.closed:
        return '已注销';
    }
  }

  Future<void> _saveAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final inputBalance = double.tryParse(_balanceController.text) ?? 0.0;
      // 如果是信用卡，输入的是欠款金额，需要转为负数
      final balance = _selectedType == AccountType.credit ? -inputBalance.abs() : inputBalance;
      final remark = _remarkController.text.trim().isEmpty ? null : _remarkController.text.trim();

      if (widget.editAccount != null) {
        // 编辑模式
        final success = await AccountService.updateAccount(
          widget.editAccount!.id!,
          {
            'name': _nameController.text.trim(),
            'card_number': _cardNumberController.text.trim(),
            'type': _selectedType.toString().split('.').last,
            'balance': balance,
            'status': _selectedStatus.toString().split('.').last,
            'remark': remark,
          },
        );
        
        if (mounted) {
          if (success) {
            Navigator.pop(context, true); // 返回true表示需要刷新
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('更新失败，请重试')),
            );
          }
        }
      } else {
        // 新增模式
        final account = await AccountService.createAccount(
          name: _nameController.text.trim(),
          cardNumber: _cardNumberController.text.trim(),
          type: _selectedType,
          balance: balance,
          status: _selectedStatus,
          remark: remark,
        );

        if (mounted) {
          if (account != null) {
            Navigator.pop(context, true); // 返回true表示需要刷新
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('保存失败，请重试')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
