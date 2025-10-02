import 'package:flutter/material.dart';
import '../../models/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final VoidCallback? onToggleTodo;  // 切换todo状态
  final VoidCallback? onEdit;        // 编辑
  final VoidCallback? onDelete;      // 删除

  const MessageBubble({
    super.key,
    required this.message,
    this.onToggleTodo,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 长按显示菜单
      onLongPress: () => _showContextMenu(context),
      child: Align(
        alignment: Alignment.centerRight,
        child: Stack(
          children: [
            // 消息气泡
            Container(
              margin: const EdgeInsets.only(left: 60, right: 16, top: 20, bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
                minWidth: 0,
              ),
              decoration: BoxDecoration(
                color: _getBubbleColor(),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(51),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withAlpha(77),
                  width: 0.5,
                ),
              ),
              child: IntrinsicWidth(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Todo勾选框
                    if (message.type == MessageType.todo) ...[
                      GestureDetector(
                        onTap: onToggleTodo,
                        child: Padding(
                          padding: EdgeInsets.only(right: 8, top: 2),
                          child: Icon(
                            message.isDone
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: message.isDone ? Colors.green : Colors.grey,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                    // 消息文本
                    Expanded(
                      child: SelectableText(
                        message.content,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          decoration: message.isDone
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 顶部信息：tags + type + time
            Positioned(
              top: 2,
              right: 20,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tags
                  if (message.tags.isNotEmpty) ...[
                    ...message.tags.map((tag) => Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Text(
                        '#$tag',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.blue.withAlpha(200),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )),
                  ],
                  // Type
                  if (message.type != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 232, 244, 213),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 112, 112, 112).withAlpha(52),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        _getTypeDisplayName(),
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.1,
                          color: const Color.fromARGB(255, 60, 79, 35).withAlpha(200),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                  ],
                  // Time
                  Text(
                    _formatTime(message.createdAt),
                    style: TextStyle(
                      fontSize: 10,
                      color: const Color.fromARGB(255, 225, 228, 221),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 显示长按菜单
  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withAlpha(230),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onEdit != null)
              ListTile(
                leading: Icon(Icons.edit, color: Colors.blue),
                title: Text('编辑'),
                onTap: () {
                  Navigator.pop(context);
                  onEdit!();
                },
              ),
            if (onDelete != null)
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('删除'),
                onTap: () {
                  Navigator.pop(context);
                  onDelete!();
                },
              ),
            ListTile(
              leading: Icon(Icons.cancel, color: Colors.grey),
              title: Text('取消'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  // 格式化时间
  String _formatTime(DateTime time) {
    final localTime = time.toLocal();  // ✅ 转本地时间
    return '${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}';
  }

  // 获取Type显示名称
  String _getTypeDisplayName() {
    switch (message.type) {
      case MessageType.todo:
        return '待办';
      case MessageType.record:
        return '记录';
      case MessageType.note:
        return '笔记';
      default:
        return '';
    }
  }

  // 根据类型获取气泡颜色
  Color _getBubbleColor() {
    if (message.type == MessageType.todo) {
      if (message.isDone) {
        return const Color.fromARGB(140, 220, 220, 220); // 完成的待办：灰色
      } else {
        return const Color.fromARGB(213, 255, 199, 88); // 待办：黄色
      }
    } else if (message.type == MessageType.record) {
      return const Color.fromARGB(214, 162, 204, 249); // 记录：蓝色
    } else if (message.type == MessageType.note) {
      return const Color.fromARGB(212, 225, 165, 253); // 笔记：橙色
    } else {
      return const Color.fromARGB(200, 130, 194, 88); // 默认：绿色
    }
  }
}