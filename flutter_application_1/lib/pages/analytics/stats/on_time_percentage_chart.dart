import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/pages/analytics/stats/user_stats_cubit.dart';
import 'dart:math' as math;

/// A widget that displays the on-time task completion percentage as a pie chart.
class OnTimePercentageChart extends StatelessWidget {
  const OnTimePercentageChart({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserStatsCubit, UserStatsState>(
      builder: (context, state) {
        // Format the percentage for display
        final String formattedPercentage =
            '${(state.onTimePercentage * 100).toStringAsFixed(1)}%';

        return Card(
          margin: const EdgeInsets.all(16.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'On-Time Completion Percentage (Last 30 Days)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 20),
                // CustomPaint widget to draw the pie chart
                SizedBox(
                  width: 150,
                  height: 150,
                  child: CustomPaint(
                    painter: PieChartPainter(
                      onTimePercentage: state.onTimePercentage,
                    ),
                    child: Center(
                      // Display the percentage text in the center of the chart
                      child: Text(
                        formattedPercentage,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Legend for the pie chart
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem(Colors.green, 'On-Time'),
                    const SizedBox(width: 20),
                    _buildLegendItem(Colors.redAccent, 'Late/Incomplete'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Helper method to build a legend item for the chart.
  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ],
    );
  }
}

/// CustomPainter for drawing the pie chart.
class PieChartPainter extends CustomPainter {
  final double onTimePercentage;

  PieChartPainter({required this.onTimePercentage});

  @override
  void paint(Canvas canvas, Size size) {
    // Define the center and radius of the circle
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2);

    // Paint for the on-time segment (green)
    final onTimePaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    // Paint for the late/incomplete segment (red)
    final latePaint = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.fill;

    // Calculate angles in radians
    final double startAngle = -math.pi / 2; // Start from the top (12 o'clock)
    final double onTimeSweepAngle = 2 * math.pi * onTimePercentage;
    final double lateSweepAngle = 2 * math.pi * (1.0 - onTimePercentage);

    // Draw the on-time segment
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      onTimeSweepAngle,
      true, // Use center to fill the pie slice
      onTimePaint,
    );

    // Draw the late/incomplete segment
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle + onTimeSweepAngle, // Start after the on-time segment
      lateSweepAngle,
      true, // Use center to fill the pie slice
      latePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Only repaint if the onTimePercentage changes
    return (oldDelegate as PieChartPainter).onTimePercentage != onTimePercentage;
  }
}