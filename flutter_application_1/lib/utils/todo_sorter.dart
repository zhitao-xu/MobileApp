import 'package:flutter/material.dart'; // Only if you need colors here, otherwise remove
import 'package:flutter_application_1/data/todo.dart'; // Import your Todo model
import 'package:flutter_application_1/utils/theme.dart'; // Import your custom colors

// Define the priority order map
// Lower number means higher priority for sorting (0 is highest)
const Map<String, int> priorityOrderMap = {
  'high': 0,
  'medium': 1,
  'low': 2,
};

// Default priority for unknown or missing priority strings
const String defaultPriority = 'medium';

/// Sorts a list of Todo items by priority (high to low) and then by deadline (closest to furthest).
List<Todo> sortTodosByPriorityAndDeadline(List<Todo> todos) {
  // Create a copy to avoid modifying the original list directly
  final List<Todo> sortedTodos = List.from(todos);

  sortedTodos.sort((a, b) {
    // Get priority order values, defaulting if not found
    final int priorityA = priorityOrderMap[a.priority.toLowerCase()] ?? priorityOrderMap[defaultPriority]!;
    final int priorityB = priorityOrderMap[b.priority.toLowerCase()] ?? priorityOrderMap[defaultPriority]!;

    // 1. Sort by Priority
    int priorityComparison = priorityA.compareTo(priorityB);
    if (priorityComparison != 0) {
      return priorityComparison;
    }

    // 2. If priorities are the same, sort by deadline (closest to now first)
    DateTime? deadlineA;
    DateTime? deadlineB;

    try {
      if (a.deadline.isNotEmpty) {
        deadlineA = DateTime.tryParse(a.deadline);
      }
    } catch (e) {
      // Handle parsing error for A if necessary, though tryParse handles most cases
    }
    try {
      if (b.deadline.isNotEmpty) {
        deadlineB = DateTime.tryParse(b.deadline);
      }
    } catch (e) {
      // Handle parsing error for B if necessary
    }


    // Handle cases where deadlines might be invalid or missing
    if (deadlineA == null && deadlineB == null) return 0; // Both invalid, maintain original relative order
    if (deadlineA == null) return 1; // A invalid, B (valid) comes first
    if (deadlineB == null) return -1; // B invalid, A (valid) comes first

    return deadlineA.compareTo(deadlineB);
  });

  return sortedTodos;
}