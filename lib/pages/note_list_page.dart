import 'package:flutter/material.dart';
import '../services/note_service.dart';
import '../models/note.dart';
import '../widgets/note_context_menu.dart';

class NoteListPage extends StatefulWidget {
  const NoteListPage({super.key});

  @override
  State<NoteListPage> createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteListPage> {
  List<Note> _notes = [];  // 修改为 Note 对象
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();  // 修改方法名
  }

  Future<void> _loadNotes() async {  // 修改方法
    setState(() {
      _isLoading = true;
    });

    try {
      final notes = await NoteService.getNotes();  // 使用 NoteService

      setState(() {
        _notes = notes;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载失败: $e')),
      );
    }
  }

  Future<void> _handleNoteAction(String action, Map<String, dynamic> noteData) async {
    switch (action) {
      case 'edit' :
        break;
      case 'delete':
        final success = await NoteService.deleteNote(noteData['id']);
        if (!mounted) return;
        if (success) {
          _loadNotes();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('笔记已删除')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('删除失败，请重试')),
          );
        }
        break;
      case 'tag':
        break;
      case 'export':
        break;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('笔记'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notes.isEmpty
              ? _buildEmptyState()
              : _buildNoteList(),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_outlined,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            '还没有笔记',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '长按消息选择"保存笔记"来创建笔记',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteList() {
    return RefreshIndicator(
      onRefresh: _loadNotes,  // 修改方法名
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _notes.length,  // 修改变量名
        itemBuilder: (context, index) {
          final note = _notes[index];  // 修改变量名
          return _buildNoteCard(note);
        },
      ),
    );
  }

  Widget _buildNoteCard(Note note) {  // 参数类型改为 Note
    return GestureDetector(
      onLongPressStart: (details) {
        NoteContextMenu.show(
          context: context,
          position: details.globalPosition,
          note: {
            'id': note.id,
            'content': note.content,
            'originalTime': note.originalTime,
          },
          onAction: _handleNoteAction,
        );
      },
    
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头部：笔记标签和时间
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.purple.withAlpha(26),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.note,
                          size: 16,
                          color: Colors.purple[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '笔记',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.purple[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDateTime(note.originalTime),  // 显示原始时间（5点）
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // 笔记内容
              Text(
                note.content,  // 使用 note.content
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dateStr;
    if (messageDate == today) {
      dateStr = '今天';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      dateStr = '昨天';
    } else {
      dateStr = '${dateTime.month}-${dateTime.day}';
    }

    return '$dateStr ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}