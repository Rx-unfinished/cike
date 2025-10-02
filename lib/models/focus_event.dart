class FocusEvent {
  final int? id;
  final DateTime startTime;
  final DateTime? endTime;
  final String description;
  final int? todoId;  // 关联的待办ID（可选）
  final List<String>? tags;  // 标签（可选）
  final String? notes;  // 备注（可选）
  final int plannedDuration;  // 计划时长（秒）
  final int? actualDuration;  // 实际时长（秒）
  final bool isCompleted;

  FocusEvent({
    this.id,
    required this.startTime,
    this.endTime,
    required this.description,
    this.todoId,
    this.tags,
    this.notes,
    required this.plannedDuration,
    this.actualDuration,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'description': description,
      'todo_id': todoId,
      'tags': tags,
      'notes': notes,
      'planned_duration': plannedDuration,
      'actual_duration': actualDuration,
      'is_completed': isCompleted,
    };
  }

  factory FocusEvent.fromJson(Map<String, dynamic> json) {
    return FocusEvent(
      id: json['id'],
      startTime: DateTime.parse(json['start_time']),
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      description: json['description'],
      todoId: json['todo_id'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      notes: json['notes'],
      plannedDuration: json['planned_duration'],
      actualDuration: json['actual_duration'],
      isCompleted: json['is_completed'] ?? false,
    );
  }
}
