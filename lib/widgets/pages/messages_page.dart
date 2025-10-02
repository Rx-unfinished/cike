import 'package:flutter/material.dart';
import '../../models/message.dart';
import '../../services/message_service.dart';
import '../../services/tag_service.dart';
import '../message/message_input.dart';
import '../message/message_bubble.dart';
import '../search_box.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final MessageService _messageService = MessageService();
  List<Message> _allMessages = [];
  final List<Message> _displayMessages = [];
  String _selectedTab = 'all';  // all, todo, record, note
  bool _isLoading = true;
  Message? _editingMessage;  // 正在编辑的消息
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    
    try {
      final messages = await _messageService.getAllMessages();
      setState(() {
        _allMessages = messages;
        _displayMessages.clear();
        _displayMessages.addAll(_filterMessages());
        _isLoading = false;
      });
    } catch (e) {
      print('加载消息失败: $e');
      setState(() => _isLoading = false);
    }
  }

  // 根据标签页筛选消息
  List<Message> _filterMessages() {
    List<Message> filtered = _allMessages;

    switch (_selectedTab) {
      case 'all':
        filtered = _allMessages;
        break;
      case 'todo':
        filtered = _allMessages.where((msg) => msg.type == MessageType.todo).toList();
        break;
      case 'record':
        filtered = _allMessages.where((msg) => msg.type == MessageType.record).toList();
        break;
      case 'note':
        filtered = _allMessages.where((msg) => msg.type == MessageType.note).toList();
        break;
      default:
        filtered = _allMessages;
        break;
    }

    // search by keyword
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((msg) {
        return msg.content.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return filtered;
  }

  // 获取当前tab的默认type
  MessageType? _getDefaultType() {
    switch (_selectedTab) {
      case 'todo':
        return MessageType.todo;
      case 'record':
        return MessageType.record;
      case 'note':
        return MessageType.note;
      default:
        return null;  // all标签页不设默认type
    }
  }

  // 发送/更新消息
  Future<void> _handleSendMessage(String content, MessageType? selectedType) async {
    try {
      if (_editingMessage != null) {
        // 更新模式
        await _messageService.updateMessage(
          _editingMessage!.id!,
          content: content,
          // todo 这里需要提取type和tags
        );
        setState(() => _editingMessage = null);
        await _loadMessages();
      } else {
        // selected type first, otherwise default
        final type = selectedType ?? _getDefaultType();

        // 1. extract tags
        final tags = _extractTags(content);

        // 2. 确保所有tags存在于数据库
        for (final tagName in tags) {
          await TagService().getOrCreateTag(tagName);
        }

        // 3. create message first
        final newMessage = await _messageService.createMessage(
          content: content,
          type: type,
          tags: tags,
        );

        // 4. usage count
        for (final tagName in tags) {
          await TagService().incrementUsageCount(tagName);
        }

        // add to list without setstate
        _allMessages.insert(0, newMessage);
        if (_shouldShowMessage(newMessage)) {
          _displayMessages.insert(0, newMessage);
        }

        // 最小化setstate
        setState(() {});
      }
    } catch (e) {
      print('发送消息失败: $e');
    }
  }

  // 判断消息是否应该在当前tab显示
  bool _shouldShowMessage(Message message) {
    switch (_selectedTab) {
      case 'all':
        return true;
      case 'todo':
        return message.type == MessageType.todo;
      case 'record':
        return message.type == MessageType.record;
      case 'note':
        return message.type == MessageType.note;
      default:
        return true;
    }
  }

  // 切换tab时重新筛选
  void _switchTab(String tab) {
    setState(() {
      _selectedTab = tab;
      _displayMessages.clear();
      _displayMessages.addAll(_filterMessages());
    });
  }

  // 切换todo完成状态
  Future<void> _toggleTodo(Message message) async {
    try {
      await _messageService.toggleTodo(message.id!);
      await _loadMessages();
    } catch (e) {
      print('切换状态失败: $e');
    }
  }

  // 编辑消息
  void _editMessage(Message message) {
    setState(() {
      _editingMessage = message;
    });
  }

  // 取消编辑
  void _cancelEdit() {
    setState(() {
      _editingMessage = null;
    });
  }

  // 删除消息
  Future<void> _deleteMessage(Message message) async {
    try {
      await _messageService.deleteMessage(message.id!);
      await _loadMessages();
    } catch (e) {
      print('删除消息失败: $e');
    }
  }

  List<String> _extractTags(String content) {
    final tagPattern = RegExp(r'#(\w+)');
    final matches = tagPattern.allMatches(content);
    return matches.map((match) => match.group(1)!).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 顶部标签页
        _buildTabBar(),
        
        // 消息列表
        Expanded(
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: Colors.white))
              : _buildMessageList(),
        ),
        
        // 输入框
        MessageInput(
          onSendMessage: _handleSendMessage,
          editingMessage: _editingMessage != null
              ? {'text': _editingMessage!.content}
              : null,
          onCancelEdit: _cancelEdit,
        ),
      ],
    );
  }

  Widget _buildMessageList() {
    if (_displayMessages.isEmpty) {
      return Center(
        child: Text(
          '暂无消息',
          style: TextStyle(color: Colors.white.withAlpha(128)),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _displayMessages.length,
      reverse: true,
      itemBuilder: (context, index) {
        final message = _displayMessages[index];
        return MessageBubble(
          key: ValueKey(message.id),
          message: message,
          onToggleTodo: () => _toggleTodo(message),
          onEdit: () => _editMessage(message),
          onDelete: () => _deleteMessage(message),
        );
      },
    );
  }

  // 标签页栏
  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(        
        children: [
          // search bar + tabs
          Column(
            children: [
              SizedBox(height: 8),
              // search bar
              SizedBox(
                width: 240,
                child: SearchBox(
                  onSearch: (query) {
                    setState(() {
                      _searchQuery = query;
                      _displayMessages.clear();
                      _displayMessages.addAll(_filterMessages());
                    });
                  },
                ),
              ),
              SizedBox(height: 16),

              // tabs
              Row(
                children: [
                  _buildTab('all', '全部'),
                  SizedBox(width: 5),
                  _buildTab('todo', '待办'),
                  SizedBox(width: 5),
                  _buildTab('record', '记录'),
                  SizedBox(width: 5),
                  _buildTab('note', '笔记'),
                ],
              ),
            ],
          ),
          Spacer(),
          // 用户头像占位
          SizedBox(
            width: 100,
            child: _buildAvatar(),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String value, String label) {
    final isSelected = _selectedTab == value;
    return GestureDetector(
      onTap: () => _switchTab(value),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        decoration: BoxDecoration(
          color: isSelected ? const Color.fromARGB(0, 255, 255, 255) : const Color.fromARGB(0, 255, 255, 255),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? const Color.fromARGB(255, 52, 86, 29).withAlpha(128)
                : const Color.fromARGB(255, 90, 110, 76).withAlpha(128),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: AssetImage('assets/images/avatar.jpg'),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}