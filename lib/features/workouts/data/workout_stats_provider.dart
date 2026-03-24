import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkoutStats {
  final int totalWorkouts;
  final int averageAccuracy;
  final int totalDurationSeconds;

  WorkoutStats({
    required this.totalWorkouts,
    required this.averageAccuracy,
    required this.totalDurationSeconds,
  });
}

final workoutStatsProvider = StreamProvider<WorkoutStats>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value(WorkoutStats(totalWorkouts: 0, averageAccuracy: 0, totalDurationSeconds: 0));

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('history')
      .snapshots()
      .map((snapshot) {
    if (snapshot.docs.isEmpty) {
      return WorkoutStats(totalWorkouts: 0, averageAccuracy: 0, totalDurationSeconds: 0);
    }

    int totalWorkouts = snapshot.docs.length;
    int totalAccuracy = 0;
    int totalDuration = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      totalAccuracy += (data['accuracy'] as num?)?.toInt() ?? 0;
      totalDuration += (data['durationSeconds'] as num?)?.toInt() ?? 0;
    }

    return WorkoutStats(
      totalWorkouts: totalWorkouts,
      averageAccuracy: totalAccuracy ~/ totalWorkouts,
      totalDurationSeconds: totalDuration,
    );
  });
});
