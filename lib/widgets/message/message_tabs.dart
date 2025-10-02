import 'package:flutter/material.dart';

class MessageTabs extends StatelessWidget {
  final String? selectedTab;
  final Function(String) onTabChanged;
  final List<String> tabs;

  const MessageTabs({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
    this.tabs = const ['all', 'todo', 'done'],
  });

  // 映射 tab 值到显示文本
  String _getTabDisplayText(String tab) {
    switch (tab) {
      case 'all':
        return '全部';
      case 'todo':
        return '待办';
      case 'done':
        return '已完成';
      default:
        return tab.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final isSelected = tab == selectedTab;
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GestureDetector(
              onTap: () => onTabChanged(tab),
              child: Center(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 80),
                  style: TextStyle(
                    fontSize: isSelected ? 16 : 14,  // 选中时稍大
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected 
                      ? Colors.white.withAlpha(230)  // 选中时更亮
                      : Colors.white.withAlpha(128),  // 未选中时半透明
                  ),
                  child: Text(_getTabDisplayText(tab)),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
