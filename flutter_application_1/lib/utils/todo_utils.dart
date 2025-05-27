import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/data/todo.dart'; // Import your Todo model
import 'package:intl/intl.dart'; // No longer strictly needed for deadline parsing here, but might be for other formatting elsewhere.

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

// --- REMOVE THE parseTodoDeadline FUNCTION ALTOGETHER ---

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
    // Directly access the DateTime? deadline property
    DateTime? deadlineA = a.deadline;
    DateTime? deadlineB = b.deadline;

    // Handle cases where deadlines might be null
    // Tasks with deadlines always come before tasks without deadlines.
    // Among tasks with deadlines, closer deadlines come first.
    // Among tasks without deadlines, their relative order is maintained.
    if (deadlineA == null && deadlineB == null) return 0; // Both null, maintain original relative order
    if (deadlineA == null) return 1; // A is null, B (non-null) comes first
    if (deadlineB == null) return -1; // B is null, A (non-null) comes first

    return deadlineA.compareTo(deadlineB);
  });

  return sortedTodos;
}


// Helper to parse date and time strings into a DateTime object
// This is where you'll add the 23:59 default logic.
DateTime? parseDateTimeFromStrings(String dateString, String timeString) {
  if (dateString.isEmpty) {
    return null; // No date, so no deadline.
  }

  try {
    // Parse the date part
    final DateFormat dateFormat = DateFormat('dd-MM-yyyy');
    DateTime parsedDate = dateFormat.parseStrict(dateString);

    if (timeString.isEmpty) {
      // If time is unspecified, default to 23:59 as per user instruction.
      return DateTime(
        parsedDate.year,
        parsedDate.month,
        parsedDate.day,
        23, // Hour: 23
        59, // Minute: 59
      );
    } else {
      // If time is specified, parse it
      final DateFormat timeFormat = DateFormat('HH:mm');
      DateTime parsedTime = timeFormat.parseStrict(timeString);

      // Combine date and time
      return DateTime(
        parsedDate.year,
        parsedDate.month,
        parsedDate.day,
        parsedTime.hour,
        parsedTime.minute,
      );
    }
  } catch (e) {
    // Handle parsing errors (e.g., invalid date/time format)
    if (kDebugMode) {
      print("Error parsing date/time: $e");
    }
    return null; // Return null if parsing fails
  }
}

//TODO: Reminder Parser String to DateTime? Probably needs also the Deadline DateTime? as a parameter and also the Repeat Parameter
/// Parses a reminder string into a DateTime.
/// This is a simplified example. Your actual reminder logic might be more complex.
/// For instance, "5 minutes before deadline", "tomorrow morning", etc.
/// For now, if the string is empty or 'None', it returns null.
/// Otherwise, it assumes the string itself is a valid DateTime string or
/// you need to implement more sophisticated parsing based on your reminder options.
DateTime? parseReminderString(String remindText) {
  if (remindText.isEmpty || remindText.toLowerCase() == 'none') {
    return null;
  }
  // This is a placeholder. You need to implement actual parsing logic here
  // based on what _remindController.text contains.
  // E.g., if it's a specific date/time string:
  try {
    return DateFormat('dd-MM-yyyy HH:mm').parseStrict(remindText);
  } catch (e) {
    if (kDebugMode) {
      print('Error parsing reminder string: $remindText, $e');
    }
    return null;
  }
}

// You might also need a function to format DateTime back to string for display,
// if _deadlineDateController.text and _deadlineTimeController.text are populated
// from existing DateTime objects.
String formatDateTimeToDateString(DateTime? dateTime) {
  if (dateTime == null) return '';
  return DateFormat('dd-MM-yyyy').format(dateTime);
}

String formatDateTimeToTimeString(DateTime? dateTime) {
  if (dateTime == null) return '';
  return DateFormat('HH:mm').format(dateTime);
}

String formatDateTimeToRemindString(DateTime? dateTime) {
  if (dateTime == null) return '';
  // This could be more sophisticated based on your reminder UX
  return DateFormat('dd-MM-yyyy HH:mm').format(dateTime);
}