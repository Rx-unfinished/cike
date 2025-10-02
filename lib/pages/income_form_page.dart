import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/account.dart';
import '../services/transaction_service.dart';
import '../services/account_service.dart';
import '../widgets/finance/account_selector.dart';
import '../widgets/date_time_selector.dart';
import '../widgets/finance/amount_input.dart';

class IncomeFormPage extends StatefulWidget {
  const IncomeFormPage({super.key});

  @override
  State<IncomeFormPage> createState() => _IncomeFormPageState();
}

class _IncomeFormPageState extends State<IncomeFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<Account> _accounts = [];
  Account? _selectedAccount;
  String? _selectedCategory;
  DateTime _selectedDateTime = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('记录收入'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveIncome,
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 金额输入
              _buildSectionTitle('支出金额'),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha(13),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withAlpha(52)),
                ),
                child: AmountInputWidget(
                  controller: _amountController,
                  placeholder: '0.00',
                  prefixText: '¥',
                  onChanged: (double? amount) {
                    // 可以在这里添加实时验证逻辑
                  },
                ),
              ),

              const SizedBox(height: 24),

              // 收入账户
              _buildSectionTitle('收入账户'),
              _buildAccountSelector(),
              const SizedBox(height: 24),

              // 收入分类
              _buildSectionTitle('收入分类'),
              _buildCategorySelector(),
              const SizedBox(height: 24),

              // 时间选择
              _buildSectionTitle('记录时间'),
              _buildDateTimeSelector(),
              const SizedBox(height: 24),

              // 备注
              _buildSectionTitle('备注说明'),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: '添加备注信息（可选）',
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
                    borderSide: const BorderSide(color: Colors.green),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildAccountSelector() {
    return AccountSelectorWidget(
      accounts: _accounts,
      selectedAccount: _selectedAccount,
      onChanged: (Account? account) {
        setState(() {
          _selectedAccount = account;
        });
      },
      placeholder: '选择收入账户',
    );
  }

  Widget _buildCategorySelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: IncomeCategory.categories.map((category) {
        final isSelected = _selectedCategory == category;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCategory = isSelected ? null : category;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.green : Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? Colors.green : Colors.grey[300]!,
              ),
            ),
            child: Text(
              category,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateTimeSelector() {
    return DateTimeSelectorWidget(
      selectedDateTime: _selectedDateTime,
      onChanged: (DateTime dateTime) {
        setState(() {
          _selectedDateTime = dateTime;
        });
      },
      mode: DateTimeMode.dateTime,
    );
  }

  Future<void> _saveIncome() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedAccount == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请选择收入账户')),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final amount = double.parse(_amountController.text);
      final description = _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim();

      final transaction = await TransactionService.createIncome(
        amount: amount,
        accountId: _selectedAccount!.id!,
        category: _selectedCategory ?? '其他收入',
        description: description,
        dateTime: _selectedDateTime,
      );

      if (mounted) {
        if (transaction != null) {
          Navigator.pop(context, true); // 返回true表示成功创建
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('收入记录保存成功'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('保存失败，请重试')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
