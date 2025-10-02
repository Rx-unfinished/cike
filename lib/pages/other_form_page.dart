import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/account.dart';
import '../services/transaction_service.dart';
import '../services/account_service.dart';
import '../widgets/finance/account_selector.dart';
import '../widgets/date_time_selector.dart';
import '../widgets/finance/amount_input.dart';

class OtherFormPage extends StatefulWidget {
  const OtherFormPage({super.key});

  @override
  State<OtherFormPage> createState() => _OtherFormPageState();
}

class _OtherFormPageState extends State<OtherFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<Account> _accounts = [];
  Account? _selectedAccount;
  String? _selectedCategory;
  DateTime _selectedDateTime = DateTime.now();
  bool _isLoading = false;
  bool _isPositiveAmount = true; // 正数表示收入性质，负数表示支出性质

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
        title: const Text('记录其他'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveOther,
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
              // 金额性质选择
              _buildSectionTitle('金额性质'),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isPositiveAmount = true;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _isPositiveAmount ? Colors.green : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _isPositiveAmount ? Colors.green : Colors.grey[300]!,
                          ),
                        ),
                        child: Text(
                          '收入性质 (+)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _isPositiveAmount ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isPositiveAmount = false;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_isPositiveAmount ? Colors.red : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: !_isPositiveAmount ? Colors.red : Colors.grey[300]!,
                          ),
                        ),
                        child: Text(
                          '支出性质 (-)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: !_isPositiveAmount ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 金额输入
              _buildSectionTitle('金额'),
              Container(
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(13),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withAlpha(52)),
                ),
                child: AmountInputWidget(
                  controller: _amountController,
                  placeholder: '0.00',
                  allowNegative: true, // 这是关键！启用正负切换功能
                  isPositive: _isPositiveAmount,
                  prefixText: '¥',
                ),
              ),
              const SizedBox(height: 24),

              // 相关账户
              _buildSectionTitle('相关账户'),
              _buildAccountSelector(),
              const SizedBox(height: 24),

              // 类型分类
              _buildSectionTitle('类型分类'),
              _buildCategorySelector(),
              const SizedBox(height: 24),

              // 时间选择
              _buildSectionTitle('记录时间'),
              _buildDateTimeSelector(),
              const SizedBox(height: 24),

              // 详细说明
              _buildSectionTitle('详细说明'),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: '请详细描述这笔记录的具体情况',
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
                    borderSide: const BorderSide(color: Colors.orange),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请填写详细说明';
                  }
                  return null;
                },
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
      placeholder: '选择支付账户',
    );
  }

  Widget _buildCategorySelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: OtherCategory.categories.map((category) {
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
              color: isSelected ? Colors.orange : Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? Colors.orange : Colors.grey[300]!,
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

  Future<void> _saveOther() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择相关账户')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final inputAmount = double.parse(_amountController.text);
      // 根据性质确定金额正负
      final amount = _isPositiveAmount ? inputAmount : -inputAmount;
      final description = _descriptionController.text.trim();

      final transaction = await TransactionService.createOther(
        amount: amount,
        accountId: _selectedAccount!.id!,
        category: _selectedCategory ?? '其他',
        description: description,
        dateTime: _selectedDateTime,
      );

      if (mounted) {
        if (transaction != null) {
          Navigator.pop(context, true); // 返回true表示成功创建
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('其他记录保存成功'),
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
      setState(() {
        _isLoading = false;
      });
    }
  }
}
