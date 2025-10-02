import '../models/note.dart';
import 'supabase_service.dart';

class NoteService {
  static const String _tableName = 'notes';

  // 创建笔记（从消息转移过来）
  static Future<Note?> createNoteFromMessage({
    required String content,
    required DateTime originalTime,
  }) async {
    final note = Note(
      content: content,
      originalTime: originalTime,
      processedTime: DateTime.now(), // 当前处理时间
    );

    try {
      final response = await SupabaseService.client
          .from(_tableName)
          .insert(note.toJson())
          .select()
          .single();

      return Note.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // 获取所有笔记
  static Future<List<Note>> getNotes() async {
    try {
      final response = await SupabaseService.client
          .from(_tableName)
          .select()
          .order('original_time', ascending: false); // 按原始时间倒序

      return response.map((json) => Note.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // 删除笔记
  static Future<bool> deleteNote(int id) async {
    try {
      await SupabaseService.client
          .from(_tableName)
          .delete()
          .eq('id', id);
      return true;
    } catch (e) {
      return false;
    }
  }

  // 更新笔记
  static Future<bool> updateNote(int id, Map<String, dynamic> updates) async {
    try {
      await SupabaseService.client
          .from(_tableName)
          .update(updates)
          .eq('id', id);
      return true;
    } catch (e) {
      return false;
    }
  }
}