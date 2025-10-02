import 'package:flutter/material.dart';

class NoteContextMenu {
  static Future<void> show({
    required BuildContext context,
    required Offset position,
    required Map<String, dynamic> note,
    required Function(String, Map<String, dynamic>) onAction,
  }) {

    // 1. 先复制这两行代码
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    // 2. 然后复制showMenu的整个结构
    return showMenu(
      context: context,
      position: RelativeRect.fromRect(
        position & const Size(40, 40), // 触摸区域
        Offset.zero & overlay.size,   // 整个屏幕
      ),
      items: [
        PopupMenuItem(
          value: 'delete',
          child: const Row(
            children: [
              Icon(Icons.delete, size: 16),
              SizedBox(width: 8),
              Text('删除'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'edit',
          child: const Row(
            children: [
              Icon(Icons.edit, size: 16),
              SizedBox(width: 8),
              Text('编辑'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'tag',
          child: const Row(
            children: [
              Icon(Icons.label, size: 16),
              SizedBox(width: 8),
              Text('添加标签'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'export',
          child: const Row(
            children: [
              Icon(Icons.share, size: 16),
              SizedBox(width: 8),
              Text('导出'),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value != null) {
        onAction(value, note);
      }
    });
  }
}