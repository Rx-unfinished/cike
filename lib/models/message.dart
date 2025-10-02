enum MessageType {
  todo,
  record,
  note,
}

class Message {
  final int? id;
  final String content;
  final DateTime createdAt;
  final MessageType? type;
  final List<String> tags;

  // when type=todo
  final bool isDone;
  final DateTime? doneAt; 

  Message({
    this.id,
    required this.content,
    DateTime? createdAt,
    this.type,
    this.tags = const [],
    this.isDone = false,
    this.doneAt, 
  }) : createdAt = createdAt ?? DateTime.now();

  // 从 Supabase 数据转换为 Message 对象
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      type: json['type'] != null
        ? MessageType.values.firstWhere(
          (e) => e.toString().split('.').last == json['type'],
          orElse: () => MessageType.note,
        )
        : null,
      tags: List<String>.from(json['tags'] ?? []),
      isDone: json['is_done'] ?? false,
      doneAt: json['done_at'] != null 
        ? DateTime.parse(json['done_at']) 
        : null, 
    );
  }

  // 转换为 Supabase 数据格式
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'type': type?.toString().split('.').last, 
      'tags': tags,
      'is_done': isDone,
      'done_at': doneAt?.toIso8601String(),
    };
  }
}