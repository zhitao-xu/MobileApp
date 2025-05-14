class SubTask {
  final String title;
  final String subtitle;
  bool isDone;
  String priority;
  String deadline;
  String remind;
  String date;

  SubTask({
    required this.title,
    this.subtitle = '',
    this.isDone = false,
    this.priority = '',
    this.date = '',
    this.deadline = '',
    this.remind = '',
  });

  SubTask copyWith({
    String? title,
    String? subtitle,
    bool? isDone,
    String? priority,
    String? date,
    String? deadline,
    String? remind,
  }) {
    return SubTask(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      isDone: isDone ?? this.isDone,
      priority: priority ?? this.priority,
      date: date ?? this.date,
      deadline: deadline ?? this.deadline,
      remind: remind ?? this.remind,
    );
  }

  factory SubTask.fromJson(Map<String, dynamic> json) {
    return SubTask(
      title: json['title'],
      subtitle: json['subtitle'] ?? '',
      isDone: json['isDone'] ?? false,
      priority: json['priority'] ?? '',
      date: json['date'] ?? '',
      deadline: json['deadline'] ?? '',
      remind: json['remind'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'isDone': isDone,
      'priority': priority,
      'date': date,
      'deadline': deadline,
      'remind': remind,
    };
  }
}

class Todo {
  final String title;
  final String subtitle;
  bool isDone;
  String priority;
  String deadline;
  String remind;
  String date;
  List<SubTask> subtasks;

  Todo({
    this.title = '',
    this.subtitle = '',
    this.isDone = false,
    this.priority = '',
    this.date = '',
    this.deadline = '',
    this.remind = '',
    this.subtasks = const [],
  });

  Todo copyWith({
    String? title,
    String? subtitle,
    bool? isDone,
    String? priority,
    String? date,
    String? deadline,
    String? remind,
    List<SubTask>? subtasks,
  }) {
    return Todo(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      isDone: isDone ?? this.isDone,
      priority: priority ?? this.priority,
      date: date ?? this.date,
      deadline: deadline ?? this.deadline,
      remind: remind ?? this.remind,
      subtasks: subtasks ?? this.subtasks,
    );
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      title: json['title'],
      subtitle: json['subtitle'],
      isDone: json['isDone'],
      priority: json['priority'],
      date: json['date'],
      deadline: json['deadline'],
      remind: json['remind'],
      subtasks: (json['subtasks'] as List<dynamic>?)
          ?.map((e) => SubTask.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'isDone': isDone,
      'priority': priority,
      'date': date,
      'deadline': deadline,
      'remind': remind,
      'subtasks': subtasks.map((e) => e.toJson()).toList(),
    };
  }
}