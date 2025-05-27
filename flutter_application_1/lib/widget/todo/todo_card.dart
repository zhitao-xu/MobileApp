import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/todo.dart'; // Import your Todo and SubTask models
import 'package:flutter_application_1/pages/task_details.dart';
import 'package:flutter_application_1/utils/theme.dart'; // For your custom colors
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

// --- REMOVE TaskItem abstract class ---
// --- REMOVE TodoAsTaskItem and SubTaskAsTaskItem extensions ---

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

  // Factory constructors for easier usage - No changes here, still works
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
  // These are crucial for type safety inside the build method
  String get _id { // Renamed to _id to avoid conflict if `id` is a getter on `item`
    if (item is Todo) {
      return (item as Todo).id;
    } else if (item is SubTask) {
      return (item as SubTask).id;
    }
    return ''; // Should not happen with valid Todo/SubTask
  }

  String get _title {
    if (item is Todo) {
      return (item as Todo).title;
    } else if (item is SubTask) {
      return (item as SubTask).title;
    }
    return '';
  }

  String get _subtitle {
    if (item is Todo) {
      return (item as Todo).subtitle;
    } else if (item is SubTask) {
      return (item as SubTask).subtitle;
    }
    return '';
  }

  bool get _isDone {
    if (item is Todo) {
      return (item as Todo).isDone;
    } else if (item is SubTask) {
      return (item as SubTask).isDone;
    }
    return false;
  }

  String get _priority {
    if (item is Todo) {
      return (item as Todo).priority;
    } else if (item is SubTask) {
      return (item as SubTask).priority;
    }
    return '';
  }

  // Now correctly returns DateTime?
  DateTime? get _deadline {
    if (item is Todo) {
      return (item as Todo).deadline;
    } else if (item is SubTask) {
      return (item as SubTask).deadline;
    }
    return null;
  }

  // Now correctly returns DateTime (createdAt property)
  DateTime get _createdAt { // Renamed from 'date' to 'createdAt' to match your model
    if (item is Todo) {
      return (item as Todo).createdAt;
    } else if (item is SubTask) {
      return (item as SubTask).createdAt;
    }
    return DateTime.now(); // Fallback: should ideally always have a createdAt
  }


  @override
  Widget build(BuildContext context) {
    final isCompleted = _isDone; // Use the helper getter

    final backgroundColor = isCompleted
        ? Colors.grey[300]
        : getPriorityColor(_priority); // Use the helper getter

    // Directly use the _deadline getter which returns DateTime?
    DateTime? currentDeadline = _deadline;

    // Build the deadline string based on showDate and showTime flags
    String deadlineText = '';
    if (currentDeadline != null) {
      if (showDate && showTime) {
        deadlineText = 'Deadline: ${DateFormat('dd-MM-yyyy HH:mm').format(currentDeadline)}';
      } else if (showDate) {
        deadlineText = 'Deadline: ${DateFormat('dd-MM-yyyy').format(currentDeadline)}';
      } else if (showTime) {
        deadlineText = 'Deadline: ${DateFormat('HH:mm').format(currentDeadline)}';
      } else {
        deadlineText = 'Deadline set'; // Minimal indicator
      }
    } else {
      deadlineText = 'No deadline';
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
          key: ValueKey(_id), // Use the helper getter for unique key
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
              onTap: () {
                if (onTap != null) {
                  onTap!();
                  return;
                } else if (!isSubTask) {
                  // If it's not a subtask, navigate to the details page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TaskDetailsPage(taskIndex: originalIndex),
                    ),
                  );
                }
                // The duplicate Navigator.push was removed as discussed before.
              },
              title: Text(
                _title, // Use the helper getter
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
                  if (_subtitle.isNotEmpty) // Use the helper getter
                    Text(
                      _subtitle,
                      style: TextStyle(
                        color: black,
                        fontSize: isSubTask ? 12 : 14,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      maxLines: 2,
                    ),
                  const SizedBox(height: 4), // Display the constructed deadline text
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
                value: _isDone, // Use the helper getter
                activeColor: isCompleted ? Colors.grey[800] : Theme.of(context).colorScheme.secondary,
                checkColor: Colors.white,
                materialTapTargetSize: isSubTask
                    ? MaterialTapTargetSize.shrinkWrap
                    : MaterialTapTargetSize.padded,
                onChanged: (value) {
                  if (onToggleCompletion != null) {
                    onToggleCompletion!();
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}