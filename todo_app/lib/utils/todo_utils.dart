import 'package:flutter/foundation.dart';
import 'package:todo_app/data/todo.dart'; // Import your Todo model
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

// REMINDER PARSING LOGIC
enum TimeUnit{
  minute,
  hour,
  day,
  week,
  month,
}

class Reminder{
  final int value;
  final TimeUnit unit;

  const Reminder(this.value, this.unit);
  
  @override
  String toString() {
    final unitName = _getUnitName(value, unit);
    return value == 0 ? 'None' : '$value $unitName before';
  }

  @override
  bool operator == (Object other) {
    if (identical(this, other)) return true;
    return other is Reminder && 
           other.value == value &&
           other.unit == unit;
  }

  @override
  int get hashCode => value.hashCode ^ unit.hashCode;

  static String _getUnitName(int value, TimeUnit unit) {
    switch (unit) {
      case TimeUnit.minute:
        return value == 1 ? 'minute' : 'minutes';
      case TimeUnit.hour:
        return value == 1 ? 'hour' : 'hours';
      case TimeUnit.day:
        return value == 1 ? 'day' : 'days';
      case TimeUnit.week:
        return value == 1 ? 'week' : 'weeks';
      case TimeUnit.month:
        return value == 1 ? 'month' : 'months';
    }
  }
}

const List<Reminder> predefinedReminders = [
  Reminder(0, TimeUnit.day), // None
  Reminder(1, TimeUnit.day), // 1 day before
  Reminder(2, TimeUnit.day), // 2 days before
  Reminder(1, TimeUnit.week), // 1 week before
  Reminder(2, TimeUnit.week), // 2 weeks before
  Reminder(1, TimeUnit.month), // 1 month before
  Reminder(3, TimeUnit.month), // 3 months before
  Reminder(6, TimeUnit.month), // 6 months before
];

// Returns a list of predefined reminder strings.
List<String> get predefinedReminderStrings => 
  predefinedReminders.map((reminder) => reminder.toString()).toList();

// Parses a reminder string into a Reminder object.
Reminder? parseReminderString (String reminderText){
  if(reminderText.isEmpty || reminderText.toLowerCase() == 'none') {
    return const Reminder(0, TimeUnit.day); 
  }

  try {
    // Check predefined reminders first
    for(final reminder in predefinedReminders) {
      if (reminder.toString().toLowerCase() == reminderText.toLowerCase()) {
        return reminder;
      }
    }

    // Parse custom format
    final regex = RegExp(r'(\d+)\s+(minute|minutes|hour|hours|day|days|week|weeks|month|months)\s+before$',
      caseSensitive: false,
    );
    final match = regex.firstMatch(reminderText.toLowerCase());

    if(match != null){
      final value = int.parse(match.group(1)!);
      final unitString = match.group(2)!;

      TimeUnit? unit;
      if(unitString.startsWith('minute')) {
        unit = TimeUnit.minute;
      } else if (unitString.startsWith('hour')) {
        unit = TimeUnit.hour;
      } else if (unitString.startsWith('day')) {
        unit = TimeUnit.day;
      } else if (unitString.startsWith('week')) {
        unit = TimeUnit.week;
      } else if (unitString.startsWith('month')) {
        unit = TimeUnit.month;
      }else{
        return null;
      }

      return Reminder(value, unit);
    }

    return null;

  }catch (e) {
    if (kDebugMode) {
      print('Error parsing reminder string: $reminderText - $e');
    }
    return null; // Return null if parsing fails
  }
}

// Converts a Reminder object to a DataTime  based on task's deadline.
DateTime? convertReminderToDataTime(Reminder? reminder, DateTime deadline) {
  if(reminder == null || reminder.value == 0){
    return null;
  }

  try{
    switch (reminder.unit) {
      case TimeUnit.minute:
        return deadline.subtract(Duration(minutes: reminder.value));
      case TimeUnit.hour:
        return deadline.subtract(Duration(hours: reminder.value));
      case TimeUnit.day:
        return deadline.subtract(Duration(days: reminder.value));
      case TimeUnit.week:
        return deadline.subtract(Duration(days: reminder.value * 7));
      case TimeUnit.month:
        // Assuming 30 days in a month for simplicity
        return deadline.subtract(Duration(days: reminder.value * 30));
    }

  }catch (e){
    if (kDebugMode) {
      print('Error converting reminder to DateTime: $reminder - $e');
    }
    return null;
  }
}

// Converts a reminder DateTime back to the closest Reminder object
// based on the difference from the deadline.
Reminder convertDataTimeToReminder(DateTime? reminderDateTime, DateTime deadline) {
  if (reminderDateTime == null) {
    return const Reminder(0, TimeUnit.day);
  }

  try{
    final difference = deadline.difference(reminderDateTime);

    if (difference.inMinutes <= 0) {
      return const Reminder(0, TimeUnit.day);
    }

    // Convert to different units and find the closest match
    final minutes = difference.inMinutes;
    final hours = difference.inHours;
    final days = difference.inDays;
    final weeks = (days / 7).round();
    final months = (days / 30).round(); // Assuming 30 days in a month for simplicity

    // Priority: exact matches first, then closest match
    
    // Check for exact hour matches (if less than a day)
    if(days == 0 && minutes > 60) {
      return Reminder(hours, TimeUnit.hour);
    }

    // Check for exact minute matches (if less than an hour)
    if(hours == 0 && minutes > 0) {
      return Reminder(minutes, TimeUnit.minute);
    }

    // Check for exact day matches
    if (days > 0 && days<7) {
      return Reminder(days, TimeUnit.day);
    }

    // Check for week matches
    if(weeks > 0 && weeks < 5 && (days % 7) <= 1){ // allow 1 day tolerance
      return Reminder(weeks, TimeUnit.week);
    }

    if(months > 0 && days >= 28){
      final monthDiff = (days - months * 30).abs();
      if(monthDiff <= 2){ // allow 2 days tolerance
        return Reminder(months, TimeUnit.month);
      }
    }

    // Fallback: choose the most appropriate unit
    if (days >= 30){
      return Reminder(months, TimeUnit.month);
    }else if (days >= 7){
      return Reminder(weeks, TimeUnit.week);
    }else if (days > 0){
      return Reminder(days, TimeUnit.day);
    }else if (hours > 0){
      return Reminder(hours, TimeUnit.hour);
    }else{
      return Reminder(minutes, TimeUnit.minute);
    }

  }catch (e) {
    if (kDebugMode) {
      print('Error converting DateTime to reminder: $reminderDateTime - $e');
    }
    return const Reminder(0, TimeUnit.day); // Fallback to no reminder
  }
}


DateTime? convertReminderStringToDateTime(String reminderText, DateTime deadline){
  final reminder = parseReminderString(reminderText);
  return convertReminderToDataTime(reminder, deadline);
}

String convertDateTimeToString(DateTime? reminderDateTime, DateTime deadline){
  final reminder = convertDataTimeToReminder(reminderDateTime, deadline);
  return reminder.toString();
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
  if (dateTime == null) return 'None';
  // This could be more sophisticated based on your reminder UX
  return DateFormat('dd-MM-yyyy HH:mm').format(dateTime);
}

DateTime? formateDeadlineToDateTime(String date, String time){
  if(date.isEmpty || time.isEmpty){
    if(kDebugMode){
      print("Error: Date or Time is empty. Date: '$date', Time: '$time' ");
    }
    return null;
  }

  date = date.trim();
  time = time.trim();

  if(date.isEmpty || time.isEmpty){
    if(kDebugMode){
      print("Error: Date or Time is empty after trimming. Date: '$date', Time: '$time' ");
    }

    return null;
  }
  
  try{
    // if time is empty, set it to a default time - 09:00
    if(time.isEmpty){
      time = '09:00';
    }

    String combined = '$date $time';
    if(kDebugMode){
      print("Attempting to parse: '$combined ' ");
    }
    return DateFormat('dd-MM-yyyy HH:mm').parse(combined);
  }catch (e){
    if(kDebugMode){
      print("Error parsing datetime: '$date $time' , Error: $e");
    }
    return null;
  }
  
}