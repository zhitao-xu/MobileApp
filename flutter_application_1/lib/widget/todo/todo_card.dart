import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/todo.dart';
import 'package:flutter_application_1/pages/task_details.dart';
import 'package:flutter_application_1/utils/theme.dart'; // For your custom colors
import 'package:flutter_application_1/utils/todo_utils.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

// Generic interface to handle both Todo and SubTask
abstract class TaskItem {
  String get title;
  String get subtitle;
  bool get isDone;
  String get priority;
  List<String> get deadline;
  String get date;
}

// Extensions to make Todo and SubTask implement TaskItem
extension TodoAsTaskItem on Todo {
  String get taskTitle => title;
  String get taskSubtitle => subtitle;
  bool get taskIsDone => isDone;
  String get taskPriority => priority;
  List<String> get taskDeadline => deadline;
  String get taskDate => date;
}

extension SubTaskAsTaskItem on SubTask {
  String get taskTitle => title;
  String get taskSubtitle => subtitle;
  bool get taskIsDone => isDone;
  String get taskPriority => priority;
  List<String> get taskDeadline => deadline;
  String get taskDate => date;
}

class TodoCard<T> extends StatelessWidget {
  final T item; // Can be Todo or SubTask
  final int originalIndex;
  final VoidCallback? onToggleCompletion;
  final VoidCallback? onDelete;
  final void Function(T updatedItem)? onUpdateFullItem;
  final bool showDate;
  final bool showTime;
  final bool isSubTask; // Flag to determine if this is a subtask
  final VoidCallback? onTap; // Custom tap handler for subtasks

  const TodoCard({
    super.key,
    required this.item,
    required this.originalIndex,
    this.onToggleCompletion,
    this.onDelete,
    this.onUpdateFullItem,
    this.showDate = true,
    this.showTime = true,
    this.isSubTask = false,
    this.onTap,
  });

  // Factory constructors for easier usage
  static TodoCard<Todo> forTodo({
    Key? key,
    required Todo todo,
    required int originalIndex,
    VoidCallback? onToggleCompletion,
    VoidCallback? onDelete,
    void Function(Todo updatedTodo)? onUpdateFullTodo,
    bool showDate = true,
    bool showTime = true,
    VoidCallback? onTap,
  }) {
    return TodoCard<Todo>(
      key: key,
      item: todo,
      originalIndex: originalIndex,
      onToggleCompletion: onToggleCompletion,
      onDelete: onDelete,
      onUpdateFullItem: onUpdateFullTodo,
      showDate: showDate,
      showTime: showTime,
      isSubTask: false,
      onTap: onTap,
    );
  }

  static TodoCard<SubTask> forSubTask({
    Key? key,
    required SubTask subTask,
    required int originalIndex,
    VoidCallback? onToggleCompletion,
    VoidCallback? onDelete,
    void Function(SubTask updatedSubTask)? onUpdateFullSubTask,
    bool showDate = true,
    bool showTime = true,
    VoidCallback? onTap,
  }) {
    return TodoCard<SubTask>(
      key: key,
      item: subTask,
      originalIndex: originalIndex,
      onToggleCompletion: onToggleCompletion,
      onDelete: onDelete,
      onUpdateFullItem: onUpdateFullSubTask,
      showDate: showDate,
      showTime: showTime,
      isSubTask: true,
      onTap: onTap,
    );
  }

  // Helper methods to access properties regardless of type
  String get title {
    if (item is Todo) {
      return (item as Todo).title;
    } else if (item is SubTask) {
      return (item as SubTask).title;
    }
    return '';
  }

  String get subtitle {
    if (item is Todo) {
      return (item as Todo).subtitle;
    } else if (item is SubTask) {
      return (item as SubTask).subtitle;
    }
    return '';
  }

  bool get isDone {
    if (item is Todo) {
      return (item as Todo).isDone;
    } else if (item is SubTask) {
      return (item as SubTask).isDone;
    }
    return false;
  }

  String get priority {
    if (item is Todo) {
      return (item as Todo).priority;
    } else if (item is SubTask) {
      return (item as SubTask).priority;
    }
    return '';
  }

  List<String> get deadline {
    if (item is Todo) {
      return (item as Todo).deadline;
    } else if (item is SubTask) {
      return (item as SubTask).deadline;
    }
    return ['', ''];
  }

  String get date {
    if (item is Todo) {
      return (item as Todo).date;
    } else if (item is SubTask) {
      return (item as SubTask).date;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = isDone;

    final backgroundColor = isCompleted
        ? Colors.grey[300]
        : getPriorityColor(priority);

    
    // Use the centralized parsing function
    DateTime? parsedDeadline = parseTodoDeadline(deadline);

    // Build the deadline string based on showDate and showTime flags
    String deadlineText = '';
    if (parsedDeadline != null) {
      if (showDate && showTime) {
        deadlineText = 'Deadline: ${DateFormat('dd-MM-yyyy HH:mm').format(parsedDeadline)}';
      } else if (showDate) {
        deadlineText = 'Deadline: ${DateFormat('dd-MM-yyyy').format(parsedDeadline)}';
      } else if (showTime) {
        deadlineText = 'Deadline: ${DateFormat('HH:mm').format(parsedDeadline)}';
      } else {
        // If neither date nor time are requested, but there's a deadline,
        // you might still want to indicate its presence or just show nothing.
        // For now, let's make it empty if both are false.
        deadlineText = 'Deadline set but not visible'; // Or 'Deadline set' if you want a minimal indicator
      }
    } else {
      // If parsedDeadline is null, we need to distinguish why.
      // Option 1: The deadline list is empty or has insufficient parts.
      if (deadline.isEmpty || deadline.length < 2 || (deadline[0].isEmpty && deadline[1].isEmpty)) {
        deadlineText = 'No deadline';
      }
      // Option 2: The deadline list had parts, but they were genuinely unparseable (e.g., "32-02-2025" or "not-a-time").
      else {
        deadlineText = 'Deadline: Invalid Date Format';
      }
    }
    
    

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Card(
        margin: EdgeInsets.symmetric(
          vertical: isSubTask ? 3.0 : 6.0,
          horizontal: isSubTask ? 8.0 : 0.0,
        ),
        color: backgroundColor,
        elevation: isSubTask ? 0.5 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: isSubTask 
            ? BorderSide(color: Colors.grey[300]!, width: 0.5)
            : BorderSide.none,
        ),
        child: Slidable(
          key: ValueKey(title + date), // Use todo.id for a truly unique key
          startActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              CustomSlidableAction(
                onPressed: onDelete != null ? (_) => onDelete!() : null,
                backgroundColor: const Color(0xFFFE4A49),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.delete, color: white),
                    SizedBox(height: 4),
                    Text('Delete', style: TextStyle(color: white)),
                  ],
                ),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: isSubTask ? 0.0 : 4.0),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.0, 
                vertical: isSubTask ? 0.0 : 4.0,
              ),
              // leading: isSubTask
              //     ? Icon(
              //         Icons.subdirectory_arrow_right,
              //         color: getPriorityColor(priority),
              //       )
              //     : null,
              onTap: () {
                if(onTap != null) {
                  onTap!();
                  return;
                }else if (!isSubTask) {
                  // If it's not a subtask, navigate to the details page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TaskDetailsPage(taskIndex: originalIndex),
                    ),
                  );
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    // Pass the original index. If TaskDetailsPage could take Todo object or ID,
                    // that would be even better for decoupled code.
                    builder: (context) => TaskDetailsPage(taskIndex: originalIndex),
                  ),
                );
              },
              title: Text(
                title,
                style: TextStyle(
                  color: black,
                  fontWeight: isSubTask ? FontWeight.normal : FontWeight.bold,
                  fontSize: isSubTask ? 14 : 16,
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                ),
                overflow: TextOverflow.ellipsis,
                softWrap: true,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: black,
                        fontSize: isSubTask ? 12 : 14,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      maxLines: 2,
                    ),
                  const SizedBox(height: 4),// Display the constructed deadline text
                  if (deadlineText.isNotEmpty) // Only show if there's something to display
                    Text(
                      deadlineText,
                      style: TextStyle(
                        fontSize: isSubTask ? 10 : 12,
                        color: isCompleted ? Colors.grey[600] : Colors.grey[700],
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                ],
              ),
              trailing: Checkbox(
                value: isDone,
                activeColor: isCompleted ? Colors.grey[800] : Theme.of(context).colorScheme.secondary,
                checkColor: Colors.white,
                materialTapTargetSize: isSubTask 
                    ? MaterialTapTargetSize.shrinkWrap
                    : MaterialTapTargetSize.padded,
                onChanged: (value) {
                  // Use the specific onToggleCompletion callback
                  if (onToggleCompletion != null) {
                    onToggleCompletion!();
                  }
                  // If you were using onUpdateFullTodo for toggling, it would look like this:
                  // if (onUpdateFullTodo != null) {
                  //   onUpdateFullTodo!(todo.copyWith(isDone: value ?? false));
                  // }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}