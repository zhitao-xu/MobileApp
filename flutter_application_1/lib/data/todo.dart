import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart'; // Import uuid

// Generate a UUID instance once
final _uuid = const Uuid();

class SubTask {
  final String id;
  final String title;
  final String subtitle;
  bool isDone;
  String priority;
  DateTime? deadline;
  DateTime createdAt;
  DateTime? actualCompletionDate;
  DateTime? remindAt; 
  String remind;
  String repeat;

  SubTask({
    String? id, // Allow passing ID for fromJson, but generate if null
    required this.title,
    this.subtitle = '',
    this.isDone = false,
    this.priority = '',
    DateTime? createdAt, // Allow passing for fromJson
    this.deadline, // Nullable DateTime
    this.actualCompletionDate, // Nullable DateTime
    this.remindAt, // Nullable DateTime
    this.remind = '',
    this.repeat = '',
  }) :
        // Generate a new ID if not provided (e.g., when creating a new task)
        id = id ?? _uuid.v4(),
        // Set creation date if not provided (e.g., when creating a new task)
        createdAt = createdAt ?? DateTime.now();


  SubTask copyWith({
    String? id,
    String? title,
    String? subtitle,
    bool? isDone,
    String? priority,
    DateTime? createdAt,
    DateTime? deadline,
    DateTime? actualCompletionDate,
    DateTime? remindAt,
    String? remind,
    String? repeat,
  }) {
    return SubTask(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      isDone: isDone ?? this.isDone,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      deadline: deadline ?? this.deadline,
      actualCompletionDate: actualCompletionDate ?? this.actualCompletionDate,
      remindAt: remindAt ?? this.remindAt,
      remind: remind ?? this.remind,
      repeat: repeat ?? this.repeat,
    );
  }

  factory SubTask.fromJson(Map<String, dynamic> json) {
    // Helper to parse DateTime from string, handling null or invalid cases.
    // This helper now also handles the old List<String> format for backward compatibility
    // if you have existing stored data in that format.
    DateTime? parseFlexibleDateTime(dynamic value) {
      if (value == null) return null;

      // Handle ISO 8601 string format (new and preferred)
      if (value is String && value.isNotEmpty) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing ISO 8601 DateTime: $value - $e');
          }
          return null;
        }
      }

      // Handle old List<String> format for deadline (for backward compatibility)
      if (value is List && value.isNotEmpty && value[0] is String) {
        try {
          String datePart = value[0];
          String timePart = value.length > 1 && value[1] is String ? value[1] : '00:00';
          if (datePart.isEmpty) return null;
          return DateTime.parse('$datePart $timePart');
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing List<String> deadline: $value - $e');
          }
          return null;
        }
      }
      return null;
    }

    return SubTask(
      id: json['id'], // ID should always be present now
      title: json['title'],
      subtitle: json['subtitle'] ?? '',
      isDone: json['isDone'] ?? false,
      priority: json['priority'] ?? '',
      createdAt: parseFlexibleDateTime(json['createdAt']) ?? DateTime.now(), // Ensure creation date is parsed or defaults
      deadline: parseFlexibleDateTime(json['deadline']), // Use the flexible parser for deadline
      actualCompletionDate: parseFlexibleDateTime(json['actualCompletionDate']),
      remindAt: parseFlexibleDateTime(json['remindAt']),
      remind: json['remind'] ?? '',
      repeat: json['repeat'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    // Helper to convert DateTime to ISO 8601 string, handling null
    String? dateTimeToJson(DateTime? dateTime) => dateTime?.toIso8601String();

    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'isDone': isDone,
      'priority': priority,
      'createdAt': dateTimeToJson(createdAt),
      // Now, save deadline as a single ISO 8601 string
      'deadline': dateTimeToJson(deadline),
      'actualCompletionDate': dateTimeToJson(actualCompletionDate),
      'remindAt': dateTimeToJson(remindAt),
      'remind': remind,
      'repeat': repeat,
    };
  }

  @override
  String toString() {
    return '\nSubTask('
        'id: $id,\n'
        'title: $title,\n'
        'subtitle: $subtitle,\n'
        'isDone: $isDone,\n'
        'priority: $priority,\n'
        'createdAt: $createdAt,\n'
        'deadline: $deadline,\n'
        'actualCompletionDate: $actualCompletionDate,\n'
        'remindAt: $remindAt,\n'
        'remind: $remind,\n'
        'repeat: $repeat)\n\n';
  }
}


class Todo {
  final String id;
  final String title;
  final String subtitle;
  bool isDone;
  String priority;
  DateTime? deadline;
  DateTime createdAt;
  DateTime? actualCompletionDate;
  DateTime? remindAt;
  String repeat;
  String remind;
  List<String> tags;
  List<SubTask> subtasks;

  Todo({
    String? id, // Allow passing ID for fromJson, but generate if null
    this.title = '',
    this.subtitle = '',
    this.isDone = false,
    this.priority = '',
    DateTime? createdAt, // Allow passing for fromJson
    this.deadline, // Nullable DateTime
    this.actualCompletionDate, // Nullable DateTime
    this.remindAt, // Nullable DateTime
    this.repeat = '',
    this.remind = '',
    this.tags = const [],
    this.subtasks = const [],
  }) :
        // Generate a new ID if not provided (e.g., when creating a new task)
        id = id ?? _uuid.v4(),
        // Set creation date if not provided (e.g., when creating a new task)
        createdAt = createdAt ?? DateTime.now();


  Todo copyWith({
    String? id,
    String? title,
    String? subtitle,
    bool? isDone,
    String? priority,
    DateTime? createdAt,
    DateTime? deadline,
    DateTime? actualCompletionDate,
    DateTime? remindAt,
    String? repeat,
    String? remind,
    List<String>? tags,
    List<SubTask>? subtasks,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      isDone: isDone ?? this.isDone,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      deadline: deadline ?? this.deadline,
      actualCompletionDate: actualCompletionDate ?? this.actualCompletionDate,
      remindAt: remindAt ?? this.remindAt,
      remind: remind ?? this.remind,
      repeat: repeat ?? this.repeat,
      tags: tags ?? this.tags,
      subtasks: subtasks ?? this.subtasks,
    );
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    // Helper to parse DateTime from string, handling null or invalid cases.
    // This helper now also handles the old List<String> format for backward compatibility
    DateTime? parseFlexibleDateTime(dynamic value) {
      if (value == null) return null;

      // Handle ISO 8601 string format (new and preferred)
      if (value is String && value.isNotEmpty) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing ISO 8601 DateTime: $value - $e');
          }
          return null;
        }
      }

      // Handle old List<String> format for deadline (for backward compatibility)
      if (value is List && value.isNotEmpty && value[0] is String) {
        try {
          String datePart = value[0];
          String timePart = value.length > 1 && value[1] is String ? value[1] : '00:00';
          if (datePart.isEmpty) return null;
          return DateTime.parse('$datePart $timePart');
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing List<String> deadline: $value - $e');
          }
          return null;
        }
      }
      return null;
    }


    return Todo(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'] ?? '',
      isDone: json['isDone'] ?? false,
      priority: json['priority'] ?? '',
      createdAt: parseFlexibleDateTime(json['createdAt']) ?? DateTime.now(),
      deadline: parseFlexibleDateTime(json['deadline']), // Use the flexible parser for deadline
      actualCompletionDate: parseFlexibleDateTime(json['actualCompletionDate']),
      remindAt: parseFlexibleDateTime(json['remindAt']),
      repeat: json['repeat'] ?? '',
      remind: json['remind'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      subtasks: (json['subtasks'] as List<dynamic>?)
          ?.map((e) => SubTask.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    String? dateTimeToJson(DateTime? dateTime) => dateTime?.toIso8601String();

    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'isDone': isDone,
      'priority': priority,
      'createdAt': dateTimeToJson(createdAt),
      // Now, save deadline as a single ISO 8601 string
      'deadline': dateTimeToJson(deadline),
      'actualCompletionDate': dateTimeToJson(actualCompletionDate),
      'remindAt': dateTimeToJson(remindAt),
      'remind': remind,
      'repeat': repeat,
      'tags': tags,
      'subtasks': subtasks.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return '\nTodo('
        'id: $id,\n'
        'title: $title,\n'
        'subtitle: $subtitle,\n'
        'isDone: $isDone,\n'
        'priority: $priority,\n'
        'createdAt: $createdAt,\n'
        'deadline: $deadline,\n'
        'actualCompletionDate: $actualCompletionDate,\n'
        'remindAt: $remindAt,\n'
        'repeat: $repeat,\n'
        'remind: $remind\n'
        'tags: $tags,\n'
        'subtasks: $subtasks)\n\n';
  }

  // Inside your Todo class, above or below your copyWith method
  bool get wasCompletedOnTime {
    if (!isDone || actualCompletionDate == null || deadline == null) {
      return false; // Not done, or no completion/deadline info
    }
    // A task is on time if it was completed AT or BEFORE its deadline.
    // Ensure both are treated as UTC or Local consistently for comparison.
    // For safety and consistency, it's often best to convert to UTC before comparison
    // or ensure both are timezone-aware if that's critical for your app.
    // For now, assuming they are consistently generated (e.g., all local or all UTC).
    return actualCompletionDate!.isBefore(deadline!) || actualCompletionDate!.isAtSameMomentAs(deadline!);
  }
}