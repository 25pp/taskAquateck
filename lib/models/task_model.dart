class TaskModel {
  final int id;
  final String title;
  final String body;
  final String status;
  final String priority;
  final String assignedTo;

  TaskModel({
    required this.id,
    required this.title,
    required this.body,
    required this.status,
    required this.priority,
    required this.assignedTo,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final statuses = ["Open", "In Progress", "Resolved"];
    final priorities = ["Low", "Medium", "High"];
    final engineers = ["John", "Meera", "Dev", "Riya", "Alex"];

    return TaskModel(
      id: json["id"],
      title: json["title"],
      body: json["body"],
      status: statuses[json["id"] % statuses.length],
      priority: priorities[json["id"] % priorities.length],
      assignedTo: engineers[json["id"] % engineers.length],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "body": body,
      "status": status,
      "priority": priority,
      "assignedTo": assignedTo,
    };
  }
}
