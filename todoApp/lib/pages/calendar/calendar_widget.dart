import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/todo_utils.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_application_1/data/todo.dart';
import 'package:flutter_application_1/utils/calendar_utils.dart';
import 'package:flutter_application_1/utils/theme.dart';
import 'package:flutter_application_1/widget/todo/todo_card.dart'; // Import your new TodoCard widget
import 'package:flutter_bloc/flutter_bloc.dart'; // Import Bloc for dispatching events
import 'package:flutter_application_1/todo_bloc/todo_bloc.dart';

class CalendarWidget extends StatefulWidget {
  final List<Todo> tasks; // Pass your list of tasks to the calendar

  const CalendarWidget({super.key, required this.tasks});

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = kToday;
  DateTime? _selectedDay; // Day currently selected by the user
  List<Todo> _selectedDayTasks = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _updateSelectedDayTasks(_selectedDay!); // Initialize tasks for the current day
  }

  @override
  void didUpdateWidget(covariant CalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if the incoming tasks list is different from the old one
    // A simple length check is often sufficient for lists where items are added/removed.
    // For more complex changes (e.g., properties of existing tasks changing but list length staying same),
    // you might need a deeper comparison if it affects _getTasksForDay logic.
    if (widget.tasks.length != oldWidget.tasks.length ||
        !listEquals(widget.tasks, oldWidget.tasks)) { // Using listEquals from foundation.dart
      // If tasks have changed, re-update the tasks for the currently selected day.
      // Ensure _selectedDay is not null before using it.
      if (_selectedDay != null) {
        _updateSelectedDayTasks(_selectedDay!);
      }
    }
  }

  // Helper to get tasks for a given day
  List<Todo> _getTasksForDay(DateTime day) {
    return widget.tasks.where((todo) {
    // Directly use todo.deadline, which is already a DateTime?
    // No need for parseTodoDeadline here anymore.
    final DateTime? todoDeadline = todo.deadline;

    // If parsing was successful, compare the parsed date with the calendar day
    return todoDeadline != null &&
           todoDeadline.year == day.year &&
           todoDeadline.month == day.month &&
           todoDeadline.day == day.day;
    }).toList();
  }

  // Update tasks when a new day is selected
  void _updateSelectedDayTasks(DateTime selectedDay) {
    setState(() {
      final List<Todo> tasksForDay = _getTasksForDay(selectedDay);
      // Use the standalone sorting function
      _selectedDayTasks = sortTodosByPriorityAndDeadline(tasksForDay);
    });
  }

  // --- Bloc Interaction Methods for CalendarWidget ---
  void _removeTodo(Todo todo) {
    context.read<TodoBloc>().add(RemoveTodo(todo));
  }

  void _toggleTodoStatus(int index) {
    // This calls the AlterTodo event, which expects an index
    context.read<TodoBloc>().add(AlterTodo(index));
  }
  // --- End Bloc Interaction Methods ---

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          firstDay: kFirstDay,
          lastDay: kLastDay,
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) {
            // Use `selectedDayPredicate` to mark a day as selected
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            if (!isSameDay(_selectedDay, selectedDay)) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay; // update `_focusedDay` to make it scroll to the selected day
              });
              _updateSelectedDayTasks(selectedDay);
            }
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          eventLoader: _getTasksForDay, // This is crucial for the dots!
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (events.isNotEmpty) {
                return Positioned(
                  // Center the marker horizontally
                  left: 0,
                  right: 0,
                  
                  bottom: 10.0,
                  child: Align( // Use Align to actually center the marker itself
                    alignment: Alignment.bottomCenter,
                    child: _buildEventsMarker(date, events),
                  ),
                );
              }
              return null;
            },
          ),
          headerStyle: const HeaderStyle(
            // Set formatButtonVisible to false to hide the format button
            formatButtonVisible: false,
            titleCentered: true,
            // Set formatButtonShowsNext to false to ensure no other format buttons appear
            formatButtonShowsNext: false,
          ),
          calendarStyle: CalendarStyle(
            // Style for the "today" circle
            todayDecoration: BoxDecoration(
              color: transparentLightBlue, // Example: A semi-transparent orange
              shape: BoxShape.circle,
            ),
            todayTextStyle: const TextStyle(
              color: Colors.white, // Text color for today's date
              fontWeight: FontWeight.bold,
            ),

            // Style for the "selected day" circle
            selectedDecoration: const BoxDecoration(
              color: lightBlue, // Example: Solid orange
              shape: BoxShape.circle,
            ),
            selectedTextStyle: const TextStyle(
              color: Colors.white, // Text color for the selected date
              fontWeight: FontWeight.bold,
            ),

            // You can also style default days, weekend days, etc.
            defaultTextStyle: const TextStyle(color: black), // Default text color for days
            weekendTextStyle: const TextStyle(color: red), // Text color for weekend days
            outsideTextStyle: TextStyle(color: grey), // Text color for days outside the current month
          ),
        ),
        const SizedBox(height: 8.0),
        Expanded(
          child: _selectedDayTasks.isEmpty
              ? const Center(child: Text('No tasks due on this day.'))
              : ListView.builder(
                  itemCount: _selectedDayTasks.length,
                  itemBuilder: (context, index) {
                    final task = _selectedDayTasks[index];
                    
                    // Find the original index of this task in the overall tasks list
                    // This is crucial for TaskDetailsPage if it relies on that index.
                    // If TaskDetailsPage could take a Todo object or its ID, this would be simpler.
                    // Find the original index of this task in the overall tasks list (widget.tasks)
                    // This is IMPORTANT because AlterTodo (and UpdateTodo) in your Bloc
                    // rely on this original index.
                    final int originalIndex = widget.tasks.indexOf(task);

                    // Ensure originalIndex is valid. If a task isn't found, it's an error in logic.
                    // For safety, you might add a check or handle it, but it should ideally always be found.
                    if (originalIndex == -1) {
                      if (kDebugMode) {
                        print("Warning: Task not found in main tasks list (id: ${task.id}) for calendar display.");
                      }
                      // You might return a placeholder or skip this item.
                      return const SizedBox.shrink();
                    }

                    return TodoCard.forTodo(
                      key: ValueKey(task.id), // Use unique ID as key for stability
                      todo: task,
                      originalIndex: originalIndex, // Pass the index the Bloc expects
                      onDelete: () => _removeTodo(task), // Call the Bloc's RemoveTodo
                      onToggleCompletion: () => _toggleTodoStatus(originalIndex), // Call the Bloc's AlterTodo
                      showDate: false,
                    );
                    
                  },
                ),
        ),
      ],
    );
  }

  // Custom marker for events (the small dot)
  Widget _buildEventsMarker(DateTime date, List events) {
    // Determine the color based on whether the date is today or the selected day
    Color markerColor;
    if (isSameDay(date, _selectedDay) || isSameDay(date, kToday)) {
      markerColor = white; // Use white if it's the selected day or today
    } else {
      markerColor = darkBlue; // Otherwise, use darkBlue
    }

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: markerColor, // Use the determined color
      ),
      width: 5.0,
      height: 5.0,
    );
  }
}