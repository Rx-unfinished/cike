import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AmountInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final String? placeholder;
  final bool allowNegative;
  final Function(double?)? onChanged;
  final bool enabled;
  final String? prefixText;
  final bool? isPositive;

  const AmountInputWidget({
    super.key,
    required this.controller,
    this.placeholder = '请输入金额',
    this.allowNegative = false,
    this.onChanged,
    this.enabled = true,
    this.prefixText,
    this.isPositive,
  });

  @override
  State<AmountInputWidget> createState() => _AmountInputWidgetState();
}

class _AmountInputWidgetState extends State<AmountInputWidget> {
  bool _isNegative = false;

  @override
  void initState() {
    super.initState();
    // 如果有外部控制，同步初始状态
    if (widget.isPositive != null) {
      _isNegative = !widget.isPositive!;
    } else {
      // 原有的初始化逻辑
      if (widget.allowNegative && widget.controller.text.isNotEmpty) {
        try {
          double value = double.parse(widget.controller.text);
          if (value < 0) {
            _isNegative = true;
            widget.controller.text = (-value).toString();
          }
        } catch (e) {
          // 忽略解析错误
        }
      }
    }
  }

  @override
  void didUpdateWidget(AmountInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当外部isPositive参数变化时，同步内部状态
    if (widget.isPositive != null && widget.isPositive != oldWidget.isPositive) {
      setState(() {
        _isNegative = !widget.isPositive!;
      });
      // 重新计算并通知父组件
      _onAmountChanged(widget.controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: widget.enabled ? Colors.white : Colors.grey[100],
      ),
      child: Row(
        children: [
          // 正负号切换按钮（只在allowNegative时显示）
          if (widget.allowNegative) ...[
            GestureDetector(
              onTap: widget.enabled ? _toggleSign : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _isNegative ? Colors.red.withAlpha(26) : Colors.green.withAlpha(26),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _isNegative ? '-' : '+',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _isNegative ? Colors.red : Colors.green,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          
          // 货币符号
          Text(
            widget.prefixText ?? '¥',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: widget.enabled ? Colors.black87 : Colors.grey[500],
            ),
          ),
          const SizedBox(width: 8),
          
          // 金额输入框
          Expanded(
            child: TextField(
              controller: widget.controller,
              enabled: widget.enabled,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: widget.placeholder,
                border: InputBorder.none,
                hintStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey,
                ),
              ),
              onChanged: _onAmountChanged,
            ),
          ),
        ],
      ),
    );
  }
  // 切换正负号
  void _toggleSign() {
    // 如果有外部控制isPositive，就不允许手动切换
    if (widget.isPositive != null) return;
    
    setState(() {
      _isNegative = !_isNegative;
    });
    _onAmountChanged(widget.controller.text);
  }

  // 金额变化处理
  void _onAmountChanged(String value) {
    // 防止范围错误
    if (value.length > widget.controller.text.length + 1) {
      return;
    }

    if (widget.onChanged != null) {
      if (value.isEmpty) {
        widget.onChanged!(null);
        return;
      }
      
      try {
        double amount = double.parse(value);
        // 如果允许负数且当前是负数状态，则返回负值
        if (widget.allowNegative && _isNegative) {
          amount = -amount;
        }
        widget.onChanged!(amount);
      } catch (e) {
        widget.onChanged!(null);
      }
    }
  }
}