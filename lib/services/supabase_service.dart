import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient? _client;
  
  // 初始化 Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://woghflzqpnctibgwoipg.supabase.co',        // 替换为你的项目URL
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndvZ2hmbHpxcG5jdGliZ3dvaXBnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg4NDgzNzcsImV4cCI6MjA3NDQyNDM3N30.V9Hau2wfnk1G0H3R5qqmKTSuptSOH7JSaB7JBb5gvbw', // 替换为你的匿名密钥
    );
    _client = Supabase.instance.client;
  }
  
  static SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase not initialized');
    }
    return _client!;
  }
}