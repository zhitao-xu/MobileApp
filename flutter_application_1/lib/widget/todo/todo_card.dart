import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/todo.dart';
import 'package:flutter_application_1/pages/task_details.dart';
import 'package:flutter_application_1/utils/theme.dart'; // For your custom colors
import 'package:flutter_application_1/utils/todo_utils.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class TodoCard extends StatelessWidget {
  final Todo todo;
  // This originalIndex is crucial because your Bloc's AlterTodo and UpdateTodo
  // events still rely on an integer index to identify the Todo.
  final int originalIndex;
  // Callbacks are now more specific to the Bloc's existing events.
  final VoidCallback? onToggleCompletion; // For AlterTodo(index)
  final VoidCallback? onDelete;           // For RemoveTodo(todo)
  final void Function(Todo updatedTodo)? onUpdateFullTodo; // For UpdateTodo(index, updatedTodo)


  // New boolean flags for display control
  final bool showDate;
  final bool showTime;

  const TodoCard({
    super.key,
    required this.todo,
    required this.originalIndex,
    this.onToggleCompletion,
    this.onDelete,
    this.onUpdateFullTodo, // This will be used if you decide to update more than just 'isDone'
    this.showDate = true, // Default to true for general use cases
    this.showTime = true, // Default to true for general use cases
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = todo.isDone;

    final backgroundColor = isCompleted
        ? Colors.grey[300]
        : getPriorityColor(todo.priority);

    
    // Use the centralized parsing function
    DateTime? parsedDeadline = parseTodoDeadline(todo.deadline);

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
      if (todo.deadline.isEmpty || todo.deadline.length < 2 || (todo.deadline[0].isEmpty && todo.deadline[1].isEmpty)) {
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
        margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 0),
        color: backgroundColor,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Slidable(
          key: ValueKey(todo.title + todo.date), // Use todo.id for a truly unique key
          startActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              CustomSlidableAction(
                onPressed: onDelete != null ? (_) => onDelete!() : null,
                backgroundColor: const Color(0xFFFE4A49),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.delete, color: Colors.white),
                    SizedBox(height: 4),
                    Text('Delete', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: ListTile(
              onTap: () {
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
                todo.title,
                style: TextStyle(
                  color: black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                ),
                overflow: TextOverflow.ellipsis,
                softWrap: true,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (todo.subtitle.isNotEmpty)
                    Text(
                      todo.subtitle,
                      style: TextStyle(
                        color: black,
                        fontSize: 14,
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
                        fontSize: 12,
                        color: isCompleted ? Colors.grey[600] : Colors.grey[700],
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                ],
              ),
              trailing: Checkbox(
                value: todo.isDone,
                activeColor: isCompleted ? Colors.grey[800] : Theme.of(context).colorScheme.secondary,
                checkColor: Colors.white,
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