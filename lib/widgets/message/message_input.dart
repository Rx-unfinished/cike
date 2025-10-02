import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cike/widgets/tags_selector.dart';
import '../../models/message.dart';

class MessageInput extends StatefulWidget {
  final Function(String content, MessageType? type) onSendMessage;
  final Map<String, dynamic>? editingMessage;
  final VoidCallback? onCancelEdit;

  const MessageInput({
    super.key,
    required this.onSendMessage,
    this.editingMessage,
    this.onCancelEdit,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();
  final LayerLink _layerLink = LayerLink();  // 用于定位TagsSelector
  OverlayEntry? _overlayEntry;
  
  String? _currentTagQuery;  // 当前正在输入的标签
  int? _tagStartPos;  // 标签开始位置

  MessageType? _selectedType;

  @override
  void initState() {
    super.initState();
    if (widget.editingMessage != null) {
      _controller.text = widget.editingMessage!['text'] ?? '';
    }
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(MessageInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.editingMessage != oldWidget.editingMessage) {
      if (widget.editingMessage != null) {
        _controller.text = widget.editingMessage!['text'] ?? '';
      } else {
        _controller.clear();
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _hideTagSelector();
    super.dispose();
  }

  // 监听输入变化，检测标签
  void _onTextChanged() {
    final text = _controller.text;
    final cursorPos = _controller.selection.baseOffset;

    // 如果光标位置无效，隐藏选择器
    if (cursorPos < 0 || cursorPos > text.length) {
      _hideTagSelector();
      return;
    }
    
    // 查找光标前最近的#
    int? hashPos;
    for (int i = cursorPos - 1; i >= 0; i--) {
      if (text[i] == '#') {
        hashPos = i;
        break;
      }
      if (text[i] == ' ') break;  // 遇到空格就停止
    }
    
    if (hashPos != null) {
      // 提取#到光标之间的文本作为query
      final query = text.substring(hashPos + 1, cursorPos);
      
      // 如果query中有空格，说明这个标签已经结束了
      if (query.contains(' ')) {
        _hideTagSelector();
        return;
      }
      
      setState(() {
        _currentTagQuery = query;
        _tagStartPos = hashPos;
      });
      _showTagSelector();
    } else {
      // 只隐藏选择器，不清空_tagStartPos
      if (_overlayEntry != null) {
      _hideTagSelector();
      }
    }
  }

  // 显示标签选择器
  void _showTagSelector() {
    _hideTagSelector();  // 先移除旧的
    
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width - 32,  // 减去padding
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, -210),  // 在输入框下方
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: TagsSelector(
              query: _currentTagQuery ?? '',
              onTagSelected: _onTagSelected,
            ),
          ),
        ),
      ),
    );
    
    Overlay.of(context).insert(_overlayEntry!);
  }

  // 隐藏标签选择器
  void _hideTagSelector() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // 选中标签后的处理
  void _onTagSelected(String tagName) {
    print('选中标签: $tagName');  // ✅ 添加调试
    print('tagStartPos: $_tagStartPos');  // ✅ 查看位置

    if (_tagStartPos == null) {
      print('tagStartPos为null，返回');  // ✅ 看是否这里返回了 
      return;
    }
    
    final text = _controller.text;
    final cursorPos = _controller.selection.baseOffset;
    
    // 替换#query为#标签名
    final before = text.substring(0, _tagStartPos!);
    final after = text.substring(cursorPos);
    final newText = '$before#$tagName $after';  // 标签后加空格
    
    _controller.text = newText;
    _controller.selection = TextSelection.collapsed(
      offset: before.length + tagName.length + 2,  // +2是#和空格
    );
    
    _hideTagSelector();

    // 强制刷新
    setState(() {
      _currentTagQuery = null;
      _tagStartPos = null;
    });
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      final content = _controller.text;
      // 传递选中的类型
      widget.onSendMessage(content, _selectedType);

      if (widget.editingMessage == null) {
        _controller.clear();
        // clear after sent
        setState(() {
          _selectedType = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(0),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          border: Border(
            top: BorderSide(
              color: Colors.grey.withAlpha(0),
              width: 1,
            ),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(128),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // 输入框
              Focus(
                onKeyEvent: (node, event) {
                  if (event is KeyDownEvent) {
                    if (event.logicalKey == LogicalKeyboardKey.enter &&
                        HardwareKeyboard.instance.isControlPressed) {
                      _sendMessage();
                      return KeyEventResult.handled;
                    }
                  }
                  return KeyEventResult.ignored;
                },
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    hintText: '此刻想说什么...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),          

              // 底部按钮
              Row(
                children: [
                  // type buttons
                  SizedBox(width: 8),
                  _buildTypeButton(MessageType.todo, '待办', const Color.fromARGB(255, 241, 231, 203).withAlpha(200)),
                  SizedBox(width: 8),
                  _buildTypeButton(MessageType.record, '记录', const Color.fromARGB(255, 185, 211, 233).withAlpha(200)),
                  SizedBox(width: 8),
                  _buildTypeButton(MessageType.note, '笔记', const Color.fromARGB(255, 231, 188, 231).withAlpha(200)),
                  
                  Spacer(),

                  if (widget.editingMessage != null)
                    IconButton(
                      icon: Icon(Icons.cancel, color: Colors.red),
                      onPressed: widget.onCancelEdit,
                    ),
                  Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.send,
                      color: const Color.fromARGB(255, 108, 136, 99),
                    ),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 添加类型按钮
  Widget _buildTypeButton(MessageType type, String label, Color color) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          // 点击同一个按钮则取消选择
          _selectedType = isSelected ? null : type;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey.withAlpha(51),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withAlpha(0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            height: 1.2,
            color: isSelected ? const Color.fromARGB(255, 78, 101, 34) : Color.fromARGB(255, 78, 101, 34),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}