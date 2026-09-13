class TaskItem {
  final String title;
  final String description;

  const TaskItem({
    required this.title,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
    };
  }

  factory TaskItem.fromMap(Map<String, dynamic> map) {
    return TaskItem(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
    );
  }
}