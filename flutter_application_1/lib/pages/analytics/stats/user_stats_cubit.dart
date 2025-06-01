import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/data/todo.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart'; // Add this import for @visibleForTesting if used

part 'user_stats_state.dart';

class UserStatsCubit extends HydratedCubit<UserStatsState> {
  UserStatsCubit() : super(const UserStatsState());

  /// Increments the total number of tasks completed.
  void incrementTotalTasksCompleted() {
    emit(state.copyWith(totalTasksCompleted: state.totalTasksCompleted + 1));
  }

  /// Decrements the total number of tasks completed.
  /// Ensures the count does not go below zero.
  void decrementTotalTasksCompleted() {
    if (state.totalTasksCompleted > 0) {
      emit(state.copyWith(totalTasksCompleted: state.totalTasksCompleted - 1));
    }
  }

  /// Calculates the percentage of tasks completed on time in the last 30 days.
  /// The percentage is between 0.0 and 1.0.
  void calculateOnTimePercentage(List<Todo> todos) {
    // A helper function to normalize a DateTime to its day start (midnight UTC)
    DateTime normalizeDate(DateTime dateTime) {
      // Use UTC for consistency across timezones for day boundaries
      return DateTime.utc(dateTime.year, dateTime.month, dateTime.day);
    }

    final today = normalizeDate(DateTime.now());
    final thirtyDaysAgo = today.subtract(const Duration(days: 29)); // Inclusive of today, so 30 days total

    int totalTasksInPeriod = 0;
    int onTimeTasksInPeriod = 0;

    // Filter tasks that have an actual completion date and fall within the last 30 days
    final List<Todo> relevantCompletedTasks = todos
        .where((todo) =>
            todo.isDone &&
            todo.actualCompletionDate != null &&
            normalizeDate(todo.actualCompletionDate!).isAfter(thirtyDaysAgo.subtract(const Duration(days: 1)))) // isAfter ensures it's >= thirtyDaysAgo
        .toList();

    for (var task in relevantCompletedTasks) {
      totalTasksInPeriod++;
      if (task.wasCompletedOnTime) {
        onTimeTasksInPeriod++;
      }
    }

    double percentage = 0.0;
    if (totalTasksInPeriod > 0) {
      percentage = onTimeTasksInPeriod / totalTasksInPeriod;
    }

    emit(state.copyWith(onTimePercentage: percentage));
  }



  @override
  UserStatsState? fromJson(Map<String, dynamic> json) {
    try {
      return UserStatsState.fromJson(json);
    } catch (e) {
      if (kDebugMode) {
        print('Error deserializing UserStatsState: $e');
      }
      return const UserStatsState(); // Return default state on error
    }
  }

  @override
  Map<String, dynamic>? toJson(UserStatsState state) {
    try {
      return state.toJson();
    } catch (e) {
      if (kDebugMode) {
        print('Error serializing UserStatsState: $e');
      }
      return null; // Return null on error so HydratedBloc doesn't save bad state
    }
  }
}