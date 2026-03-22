import 'package:cloud_firestore/cloud_firestore.dart';
import '../../home/domain/workout_activity.dart';

class CustomWorkout {
  final String id;
  final String name;
  final List<WorkoutActivity> activities;
  final DateTime createdAt;

  CustomWorkout({
    required this.id,
    required this.name,
    required this.activities,
    required this.createdAt,
  });

  factory CustomWorkout.fromJson(Map<String, dynamic> json, String id) {
    return CustomWorkout(
      id: id,
      name: json['name'] as String,
      activities: (json['activities'] as List)
          .map((e) => WorkoutActivity.fromJson(e))
          .toList(),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'activities': activities.map((e) => e.toJson()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
