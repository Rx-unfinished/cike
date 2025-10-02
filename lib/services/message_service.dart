import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message.dart';

class MessageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 获取所有消息
  Future<List<Message>> getAllMessages() async {
    final response = await _supabase
        .from('messages')
        .select()
        .order('created_at', ascending: false);
    
    return (response as List).map((json) => Message.fromJson(json)).toList();
  }

  // 创建消息
  Future<Message> createMessage({
    required String content,
    MessageType? type,
    List<String> tags = const [],
  }) async {
    final response = await _supabase
        .from('messages')
        .insert({
          'content': content,
          'type': type?.toString().split('.').last,
          'tags': tags,
        })
        .select()
        .single();
    
    return Message.fromJson(response);
  }

  // 更新消息
  Future<void> updateMessage(
    int id, {
    String? content,
    MessageType? type,
    List<String>? tags,
  }) async {
    final data = <String, dynamic>{};
    if (content != null) data['content'] = content;
    if (type != null) data['type'] = type.toString().split('.').last;
    if (tags != null) data['tags'] = tags;
    
    await _supabase.from('messages').update(data).eq('id', id);
  }

  // 切换todo状态
  Future<void> toggleTodo(int id) async {
    // 先获取当前状态
    final message = await _supabase
        .from('messages')
        .select()
        .eq('id', id)
        .single();
    
    final isDone = message['is_done'] ?? false;
    
    await _supabase.from('messages').update({
      'is_done': !isDone,
      'done_at': !isDone ? DateTime.now().toIso8601String() : null,
    }).eq('id', id);
  }

  // 删除消息
  Future<void> deleteMessage(int id) async {
    await _supabase.from('messages').delete().eq('id', id);
  }
}