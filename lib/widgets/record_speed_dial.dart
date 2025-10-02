import 'package:flutter/material.dart';
import '../models/transaction.dart';

class RecordSpeedDial extends StatefulWidget {
  final Function(TransactionType) onRecordTypeSelected;

  const RecordSpeedDial({
    super.key,
    required this.onRecordTypeSelected,
  });

  @override
  State<RecordSpeedDial> createState() => _RecordSpeedDialState();
}

class _RecordSpeedDialState extends State<RecordSpeedDial>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.25,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _onItemTap(TransactionType type) {
    _toggleExpansion();
    widget.onRecordTypeSelected(type);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 展开的选项按钮
        if (_isExpanded) ...[
          _buildSpeedDialItem(
            label: '记收入',
            color: Colors.green,
            onTap: () => _onItemTap(TransactionType.income),
          ),
          const SizedBox(height: 12),
          _buildSpeedDialItem(
            label: '记支出',
            color: Colors.red,
            onTap: () => _onItemTap(TransactionType.expense),
          ),
          const SizedBox(height: 12),
          _buildSpeedDialItem(
            label: '记转账',
            color: Colors.blue,
            onTap: () => _onItemTap(TransactionType.transfer),
          ),
          const SizedBox(height: 12),
          _buildSpeedDialItem(
            label: '记其他',
            color: Colors.orange,
            onTap: () => _onItemTap(TransactionType.other),
          ),
          const SizedBox(height: 12),
        ],
        
        // 主按钮
        FloatingActionButton(
          onPressed: _toggleExpansion,
          backgroundColor: Theme.of(context).primaryColor,
          child: AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value * 2 * 3.14159,
                child: Icon(
                  _isExpanded ? Icons.close : Icons.add,
                  color: Colors.white,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSpeedDialItem({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: color.withAlpha(78),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
