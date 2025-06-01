part of 'user_stats_cubit.dart';

enum UserStatsStatus { initial, loading, success, error }

class UserStatsState extends Equatable {
  final int totalTasksCompleted;
  final double onTimePercentage;


  const UserStatsState({
    this.totalTasksCompleted = 0,
    this.onTimePercentage = 0.0,
  });

  UserStatsState copyWith({
    int? totalTasksCompleted,
    double? onTimePercentage,
  }) {
    return UserStatsState(
      totalTasksCompleted: totalTasksCompleted ?? this.totalTasksCompleted,
      onTimePercentage: onTimePercentage ?? this.onTimePercentage, // Changed type
    );
  }

  // --- JSON Serialization/Deserialization ---
  // These are crucial for HydratedBloc to save and restore state
  factory UserStatsState.fromJson(Map<String, dynamic> json) {
    return UserStatsState(
      totalTasksCompleted: json['totalTasksCompleted'] as int? ?? 0,
      onTimePercentage: (json['onTimePercentage'] as num?)?.toDouble() ?? 0.0, // Deserialize as double
      // Deserialize other fields from JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalTasksCompleted': totalTasksCompleted,
      'onTimePercentage': onTimePercentage, // Serialize as double
      // Serialize other fields to JSON
    };
  }

  @override
  List<Object?> get props => [
        totalTasksCompleted,
        onTimePercentage, // Changed
        // Add other properties here
      ];
}