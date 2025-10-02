import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/tag.dart';

class TagService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 获取所有标签
  Future<List<Tag>> getAllTags() async {
    final response = await _supabase
        .from('tags')
        .select()
        .order('usage_count', ascending: false);  // 按使用频率排序
    
    return (response as List).map((json) => Tag.fromJson(json)).toList();
  }

  // 搜索标签（用于输入#时的建议）
  Future<List<Tag>> searchTags(String query) async {
    final response = await _supabase
        .from('tags')
        .select()
        .ilike('name', '%$query%')  // 模糊搜索
        .order('usage_count', ascending: false)
        .limit(10);  // 最多返回10个建议
    
    return (response as List).map((json) => Tag.fromJson(json)).toList();
  }

  // 创建或获取标签（用户输入新标签时）
  Future<Tag> getOrCreateTag(String name) async {
    // 先查询是否已存在
    final existing = await _supabase
        .from('tags')
        .select()
        .eq('name', name)
        .maybeSingle();
    
    if (existing != null) {
      return Tag.fromJson(existing);
    }
    
    // 不存在则创建
    final response = await _supabase
        .from('tags')
        .insert({'name': name})
        .select()
        .single();
    
    return Tag.fromJson(response);
  }

  // 增加标签使用次数
  Future<void> incrementUsageCount(String tagName) async {
    await _supabase.rpc('increment_tag_usage', params: {'tag_name': tagName});
  }

  // 更新标签
  Future<void> updateTag(int id, {String? name, String? color}) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (color != null) data['color'] = color;
    
    await _supabase.from('tags').update(data).eq('id', id);
  }

  // 删除标签
  Future<void> deleteTag(int id) async {
    await _supabase.from('tags').delete().eq('id', id);
  }
}