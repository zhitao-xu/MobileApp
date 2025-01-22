class Todo {
  final String title;
  final String subtitle;
  bool isDone;
  String priority;
  String date;

  Todo({
    this.title = '',
    this.subtitle = '',
    this.isDone = false,
    this.priority = '',
    this.date = ''
  });

  Todo copyWith({
    String? title,
    String? subtitle,
    bool? isDone,
    String? priority,
    String? date,
  }) {
    return Todo(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      isDone: isDone ?? this.isDone,
      priority: priority ?? this.priority,
      date: date ?? this.date,
    );
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
        title: json['title'],
        subtitle: json['subtitle'],
        isDone: json['isDone'],
        priority: json['priority'],
        date: json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'isDone': isDone,
      'priority': priority,
      'date': date,
    };
  }

  @override
  String toString() {
    return '''Todo: {
			title: $title\n
			subtitle: $subtitle\n
			isDone: $isDone\n
			priority: $priority\n
			date: $date\n
		}''';
  }
}