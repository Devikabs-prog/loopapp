class Task {
  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    this.dueAt,
    this.reminderAt,
    this.completed = false,
  });

  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? dueAt;
  final DateTime? reminderAt;
  final bool completed;

  Task copyWith({
    String? title,
    String? description,
    DateTime? dueAt,
    DateTime? reminderAt,
    bool? completed,
  }) => Task(
    id: id,
    title: title ?? this.title,
    description: description ?? this.description,
    createdAt: createdAt,
    updatedAt: DateTime.now().toUtc(),
    dueAt: dueAt ?? this.dueAt,
    reminderAt: reminderAt ?? this.reminderAt,
    completed: completed ?? this.completed,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    'dueAt': dueAt?.toUtc().toIso8601String(),
    'reminderAt': reminderAt?.toUtc().toIso8601String(),
    'completed': completed,
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'] as String,
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    createdAt: DateTime.parse(json['createdAt'] as String).toUtc(),
    updatedAt: DateTime.parse(json['updatedAt'] as String).toUtc(),
    dueAt: _date(json['dueAt']),
    reminderAt: _date(json['reminderAt']),
    completed: json['completed'] as bool? ?? false,
  );

  static DateTime? _date(Object? value) =>
      value is String ? DateTime.tryParse(value)?.toUtc() : null;
}
