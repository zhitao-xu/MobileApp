import 'package:flutter/material.dart';
import 'package:flutter_application_1/todo_bloc/todo_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/data/todo.dart'; // Assuming Todo model is located here
import 'dart:math' as math; // Import for math.max

/// A widget that displays a heatmap of daily task activity over the last 30 days.
/// The intensity of the green color indicates the number of tasks completed on that day.
class ActivityHeatmapWidget extends StatelessWidget {
  const ActivityHeatmapWidget({super.key});

  /// Helper function to normalize a DateTime to its day start (midnight UTC).
  /// This ensures that all timestamps for a given day are treated as the same date.
  DateTime _normalizeDate(DateTime dateTime) {
    return DateTime.utc(dateTime.year, dateTime.month, dateTime.day);
  }

  /// Determines the color of a heatmap square based on the activity count for that day
  /// and the maximum activity count observed across the 30-day period.
  Color _getColorForCount(int count, int maxCount) {
    // If no tasks were completed, use a light grey color.
    if (count == 0) {
      return Colors.grey[200]!;
    }

    // Define 4 levels of green intensity.
    final int numLevels = 4;
    // Calculate the step size for each color level based on the maximum count.
    // If maxCount is 0 (no tasks completed in the period), step is 1 to avoid division by zero.
    final double step = maxCount > 0 ? maxCount / numLevels : 1.0;

    // Assign colors based on which activity level the count falls into.
    if (count <= step) {
      return Colors.green[200]!; // Light green
    } else if (count <= 2 * step) {
      return Colors.green[400]!; // Medium green
    } else if (count <= 3 * step) {
      return Colors.green[600]!; // Darker green
    } else {
      return Colors.green[800]!; // Darkest green
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use BlocBuilder to listen to changes in the TodoState and rebuild the widget.
    return BlocBuilder<TodoBloc, TodoState>(
      builder: (context, todoState) {
        // Map to store the count of completed tasks for each day.
        final Map<DateTime, int> dailyActivityCounts = {};
        final today = _normalizeDate(DateTime.now());
        // Calculate the date 29 days ago to include today, making it a 30-day period.
        final thirtyDaysAgo = today.subtract(const Duration(days: 29));

        // Initialize activity counts for all 30 days to zero.
        // This ensures that even days with no activity are represented in the heatmap.
        for (int i = 0; i < 30; i++) {
          final day = today.subtract(Duration(days: i));
          dailyActivityCounts[_normalizeDate(day)] = 0;
        }

        // Iterate through all todos to populate the daily activity counts.
        for (var todo in todoState.todos) {
          // Only consider tasks that are marked as done and have a completion date.
          if (todo.isDone && todo.actualCompletionDate != null) {
            final completionDate = _normalizeDate(todo.actualCompletionDate!);
            // Check if the completion date falls within the last 30 days.
            // `isAfter(thirtyDaysAgo.subtract(const Duration(days: 1)))` ensures it's inclusive of thirtyDaysAgo.
            // `isBefore(today.add(const Duration(days: 1)))` ensures it's inclusive of today.
            if (completionDate.isAfter(thirtyDaysAgo.subtract(const Duration(days: 1))) &&
                completionDate.isBefore(today.add(const Duration(days: 1)))) {
              // Increment the count for the corresponding day.
              dailyActivityCounts.update(completionDate, (value) => value + 1,
                  ifAbsent: () => 1); // Should not be called if pre-initialized, but good for safety.
            }
          }
        }

        // Determine the maximum number of tasks completed on any single day
        // within the 30-day period. This is used for scaling the color intensity.
        int maxActivityCount = 0;
        if (dailyActivityCounts.isNotEmpty) {
          maxActivityCount = dailyActivityCounts.values.reduce(math.max);
        }

        // Sort the days to display them in chronological order in the heatmap.
        final List<DateTime> orderedDays = dailyActivityCounts.keys.toList()
          ..sort((a, b) => a.compareTo(b));

        return Card(
          margin: const EdgeInsets.all(16.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily Activity Heatmap (Last 30 Days)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 15),
                // Use a Wrap widget to display the heatmap squares.
                // Wrap automatically handles laying out children in rows and wrapping to the next line.
                Wrap(
                  spacing: 4.0, // Horizontal spacing between squares
                  runSpacing: 4.0, // Vertical spacing between rows of squares
                  children: orderedDays.map((day) {
                    final count = dailyActivityCounts[day] ?? 0;
                    final color = _getColorForCount(count, maxActivityCount);
                    // Format the date for the tooltip (e.g., "05/27").
                    final String formattedDate = '${day.month}/${day.day}';

                    return Tooltip(
                      message: '$formattedDate: $count tasks', // Tooltip shows date and task count
                      child: Container(
                        width: 30, // Fixed width for each square
                        height: 30, // Fixed height for each square
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(5), // Slightly rounded corners for squares
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 15),
                // Display a simple legend to explain the color intensity levels.
                _buildLegend(),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds the legend for the heatmap, explaining what each color intensity represents.
  Widget _buildLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Activity Levels:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            _legendColorBox(Colors.grey[200]!),
            const Text(' 0 tasks', style: TextStyle(fontSize: 12)),
            const SizedBox(width: 10),
            _legendColorBox(Colors.green[200]!),
            const Text(' Low', style: TextStyle(fontSize: 12)),
            const SizedBox(width: 10),
            _legendColorBox(Colors.green[400]!),
            const Text(' Medium', style: TextStyle(fontSize: 12)),
            const SizedBox(width: 10),
            _legendColorBox(Colors.green[600]!),
            const Text(' High', style: TextStyle(fontSize: 12)),
            const SizedBox(width: 10),
            _legendColorBox(Colors.green[800]!),
            const Text(' Very High', style: TextStyle(fontSize: 12)),
          ],
        ),
      ],
    );
  }

  /// Helper method to create a colored box for the legend.
  Widget _legendColorBox(Color color) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
