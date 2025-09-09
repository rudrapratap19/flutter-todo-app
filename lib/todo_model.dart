class TodoModel {
  final String id;
  final String userId;
  String title;
  DateTime deadline;
  bool reminderSent;
  DateTime createdAt;

  TodoModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.deadline,
    required this.reminderSent,
    required this.createdAt,
  });

  factory TodoModel.fromMap(Map<String, dynamic> m) {
    return TodoModel(
      id: m['id'] as String,
      userId: m['user_id'] as String,
      title: m['title'] as String,
      deadline: DateTime.parse(m['deadline']).toLocal(),
      reminderSent: m['reminder_sent'] ?? false,
      createdAt: DateTime.parse(
        m['created_at'] ?? DateTime.now().toUtc().toIso8601String(),
      ).toLocal(),
    );
  }
}
