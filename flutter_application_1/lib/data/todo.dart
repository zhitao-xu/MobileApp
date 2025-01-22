class Todo {
  final String title;
  final String subtitle;
  bool isDone;
  String priority;
  String deadline;
  String remind;
  String date;

  Todo({
    this.title = '',
    this.subtitle = '',
    this.isDone = false,
    this.priority = '',
    this.date = '',
    this.deadline = '',
    this.remind = '',
  });

  Todo copyWith({
    String? title,
    String? subtitle,
    bool? isDone,
    String? priority,
    String? date,
    String? deadline,
    String? remind,
  }) {
    return Todo(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      isDone: isDone ?? this.isDone,
      priority: priority ?? this.priority,
      date: date ?? this.date,
      deadline: deadline ?? this.deadline,
      remind: remind ?? this.remind,
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
