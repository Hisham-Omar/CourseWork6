class Task {
  String id;
  String name;
  bool isCompleted;
  Map<String, List<String>>? subTasks;

  Task({
    required this.id,
    required this.name,
    this.isCompleted = false,
    this.subTasks,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'isCompleted': isCompleted,
      'subTasks': subTasks,
    };
  }

  static Task fromMap(String id, Map<String, dynamic> data) {
    return Task(
      id: id,
      name: data['name'],
      isCompleted: data['isCompleted'] ?? false,
      subTasks: Map<String, List<String>>.from(data['subTasks'] ?? {}),
    );
  }
}
