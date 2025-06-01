import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../stats/user_stats_cubit.dart'; // Adjust path if necessary
import 'package:flutter_application_1/utils/theme.dart';

class TotalTasksCompletedWidget extends StatelessWidget {
  const TotalTasksCompletedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // BlocBuilder listens to changes in UserStatsCubit's state
    return BlocBuilder<UserStatsCubit, UserStatsState>(
      builder: (context, state) {
        return Card(
          margin: const EdgeInsets.all(16.0),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Total Tasks Completed',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: lightBlue,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${state.totalTasksCompleted}', // Display the actual number
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: lightBlue,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}