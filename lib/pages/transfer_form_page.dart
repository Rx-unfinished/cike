import 'package:flutter/material.dart';
import '../models/account.dart';
import '../services/transaction_service.dart';
import '../services/account_service.dart';
import '../widgets/finance/account_selector.dart';
import '../widgets/date_time_selector.dart';
import '../widgets/finance/amount_input.dart';

class TransferFormPage extends StatefulWidget {
  const TransferFormPage({super.key});

  @override
  State<TransferFormPage> createState() => _TransferFormPageState();
}

class _TransferFormPageState extends State<TransferFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<Account> _accounts = [];
  Account? _fromAccount;
  Account? _toAccount;
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('记录转账'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveTransfer,
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
                  color: Colors.blue.withAlpha(13),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withAlpha(52)),
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

              // 转出账户
              _buildSectionTitle('转出账户'),
              AccountSelectorWidget(
                accounts: _accounts,
                selectedAccount: _fromAccount,
                onChanged: (Account? account) {
                  setState(() {
                    _fromAccount = account;
                    // 如果转入账户和转出账户相同，清空转入账户
                    if (_toAccount == account) {
                      _toAccount = null;
                    }
                  });
                },
              ),
              const SizedBox(height: 16),

              // 转账箭头
              Center(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_downward,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 转入账户
              _buildSectionTitle('转入账户'),
              AccountSelectorWidget(
                accounts: _accounts.where((account) => account != _fromAccount).toList(),
                selectedAccount: _toAccount,
                onChanged: (Account? account) {
                  setState(() {
                    _toAccount = account;
                  });
                },
                placeholder: '选择转入账户',
              ),
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
                    borderSide: const BorderSide(color: Colors.blue),
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

  Future<void> _saveTransfer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_fromAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择转出账户')),
      );
      return;
    }

    if (_toAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择转入账户')),
      );
      return;
    }

    if (_fromAccount == _toAccount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('转出账户和转入账户不能相同')),
      );
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

      final transactions = await TransactionService.createTransfer(
        amount: amount,
        fromAccountId: _fromAccount!.id!,
        toAccountId: _toAccount!.id!,
        description: description,
        dateTime: _selectedDateTime,
      );

      if (mounted) {
        if (transactions != null && transactions.isNotEmpty) {
          Navigator.pop(context, true); // 返回true表示成功创建
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('转账记录保存成功'),
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
