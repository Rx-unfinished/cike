class Note {
  final int? id;
  final String content;
  final DateTime originalTime;  // 原始记录时间（5点）
  final DateTime processedTime; // 处理时间（7点）

  Note({
    this.id,
    required this.content,
    required this.originalTime,
    required this.processedTime,
  });

  // 从 Supabase 数据转换为 Note 对象
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      content: json['content'],
      originalTime: DateTime.parse(json['original_time']),
      processedTime: DateTime.parse(json['processed_time']),
    );
  }

  // 转换为 Supabase 数据格式
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'content': content,
      'original_time': originalTime.toIso8601String(),
      'processed_time': processedTime.toIso8601String(),
    };
  }
}