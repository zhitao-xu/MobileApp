import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/data/todo.dart';
import 'package:intl/intl.dart'; // Import your Todo model

// Define the priority order map
// Lower number means higher priority for sorting (0 is highest)
const Map<String, int> priorityOrderMap = {
  'high': 0,
  'medium': 1,
  'low': 2,
  'none': 3,
};

// Default priority for unknown or missing priority strings
const String defaultPriority = 'none';

// ignore: unintended_html_in_doc_comment
/// Helper function to parse the deadline from the List<String> format.
///
/// Handles cases where:
/// - The list is empty or has fewer than two elements.
/// - The date part is empty.
/// - The time part is empty.
///
/// Returns a DateTime object if a valid date is found, otherwise null.
///
/// **Interpretation Choices:**
/// - If only a date is provided, the time defaults to 00:00 (midnight).
/// - If only a time is provided (without a date), it cannot be parsed into a specific DateTime.
/// - If both are missing, it returns null.
DateTime? parseTodoDeadline(List<String> deadlineParts) {
  String? datePart;
  String? timePart;

  // Extract date and time parts safely
  if (deadlineParts.isNotEmpty) {
    datePart = deadlineParts[0].isNotEmpty ? deadlineParts[0] : null;
  }
  if (deadlineParts.length > 1) {
    timePart = deadlineParts[1].isNotEmpty ? deadlineParts[1] : null;
  }

  // Case 1: Both date and time are provided
  if (datePart != null && timePart != null) {
    final String dateTimeString = "$datePart $timePart";
    try {
      return DateFormat("dd-MM-yyyy HH:mm").parseStrict(dateTimeString);
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing full deadline "$dateTimeString": $e');
      }
      return null; // Failed to parse full date and time
    }
  }
  // Case 2: Only date is provided (time is missing or empty)
  else if (datePart != null && timePart == null) {
    // If only date is available, default time to 23:59 (end of day)
    final String dateTimeString = "$datePart 23:59"; // <--- CHANGE IS HERE
    try {
      return DateFormat("dd-MM-yyyy HH:mm").parseStrict(dateTimeString);
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing date-only deadline "$dateTimeString": $e');
      }
      return null; // Failed to parse date with default time
    }
  }
  // Case 3: Only time is provided (date is missing or empty) - Cannot form a valid DateTime
  // Case 4: Neither date nor time are provided / Invalid structure
  else {
    return null; // No sufficient information to form a valid DateTime
  }
}

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
    // Use the new helper function for parsing
    DateTime? deadlineA = parseTodoDeadline(a.deadline);
    DateTime? deadlineB = parseTodoDeadline(b.deadline);

    // Handle cases where deadlines might be invalid or missing
    // Tasks with deadlines always come before tasks without deadlines.
    // Among tasks with deadlines, closer deadlines come first.
    // Among tasks without deadlines, their relative order is maintained (or you could add another sort criteria).
    if (deadlineA == null && deadlineB == null) return 0; // Both invalid/missing, maintain original relative order
    if (deadlineA == null) return 1; // A is invalid/missing, B (valid) comes first
    if (deadlineB == null) return -1; // B is invalid/missing, A (valid) comes first

    return deadlineA.compareTo(deadlineB);
  });

  return sortedTodos;
}