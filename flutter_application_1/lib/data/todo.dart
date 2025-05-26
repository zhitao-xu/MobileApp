class SubTask {
  final String title;
  final String subtitle;
  bool isDone;
  String priority;
  List<String> deadline;
  String remind;
  String repeat;
  String date;

  SubTask({
    required this.title,
    this.subtitle = '',
    this.isDone = false,
    this.priority = '',
    this.date = '',
    this.deadline = const ['', ''],
    this.remind = '',
    this.repeat = '',
  });

  SubTask copyWith({
    String? title,
    String? subtitle,
    bool? isDone,
    String? priority,
    String? date,
    List<String>? deadline,
    String? remind,
    String? repeat,
  }) {
    return SubTask(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      isDone: isDone ?? this.isDone,
      priority: priority ?? this.priority,
      date: date ?? this.date,
      deadline: deadline ?? this.deadline,
      remind: remind ?? this.remind,
      repeat: repeat ?? this.repeat,
    );
  }

  factory SubTask.fromJson(Map<String, dynamic> json) {
    return SubTask(
      title: json['title'],
      subtitle: json['subtitle'] ?? '',
      isDone: json['isDone'] ?? false,
      priority: json['priority'] ?? '',
      date: json['date'] ?? '',
      deadline: List<String>.from(json['deadline'] ?? ['', '']),
      remind: json['remind'] ?? '',
      repeat: json['repeat'] ?? '',
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
      'repeat': repeat,
    };
  }
}

class Todo {
  final String title;
  final String subtitle;
  bool isDone;
  String priority;
  List<String> deadline;
  String remind;
  String repeat;
  String date;
  List<String> tags;
  List<SubTask> subtasks;

  Todo({
    this.title = '',
    this.subtitle = '',
    this.isDone = false,
    this.priority = '',
    this.date = '',
    this.deadline = const ['', ''],
    this.remind = '',
    this.repeat = '',
    this.tags = const [],
    this.subtasks = const [],
  });

  Todo copyWith({
    String? title,
    String? subtitle,
    bool? isDone,
    String? priority,
    String? date,
    List<String>? deadline,
    String? remind,
    String? repeat,
    List<String>? tags,
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
      repeat: repeat ?? this.repeat,
      tags: tags ?? this.tags,
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
      deadline: List<String>.from(json['deadline'] ?? ['', '']),
      remind: json['remind'],
      repeat: json['repeat'],
      tags: List<String>.from(json['tags'] ?? []),
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
      'repeat': repeat,
      'tags': tags,
      'subtasks': subtasks.map((e) => e.toJson()).toList(),
    };
  }
}