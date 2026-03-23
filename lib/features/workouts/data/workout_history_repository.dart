import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkoutHistoryRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  WorkoutHistoryRepository(this._firestore, this._auth);

  Future<void> saveWorkoutSession({
    required String workoutName,
    required int durationSeconds,
    required List<Map<String, dynamic>> exerciseData,
    required double intensity,
    required double breathing,
    bool isJourneyPath = false,
    int accuracy = 100,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final historyRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('history');

    await historyRef.add({
      'workoutName': workoutName,
      'durationSeconds': durationSeconds, // Duration in seconds
      'exerciseData': exerciseData, // Detailed sets/reps
      'intensity': intensity,
      'breathing': breathing,
      'accuracy': accuracy,
      'isJourneyPath': isJourneyPath,
      'timestamp': FieldValue.serverTimestamp(),
      'completedAt': DateTime.now().toIso8601String(),
    });
  }
}

final workoutHistoryRepositoryProvider = Provider<WorkoutHistoryRepository>((
  ref,
) {
  return WorkoutHistoryRepository(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
  );
});
