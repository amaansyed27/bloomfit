import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/domain/workout_activity.dart';
import 'models/exercise_model.dart';

class WebCompanionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateLiveSession(
      String sessionId, WorkoutActivity activity, ExerciseModel exercise) async {
    await _firestore.collection('live_sessions').doc(sessionId).set({
      'exerciseId': activity.exerciseId,
      'exerciseName': exercise.name,
      'targetReps': activity.reps ?? 0,
      'targetDuration': activity.durationSeconds ?? 0,
      'status': 'active',
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> endLiveSession(String sessionId) async {
    await _firestore.collection('live_sessions').doc(sessionId).set({
      'status': 'ended',
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<DocumentSnapshot> listenToSession(String sessionId) {
    return _firestore.collection('live_sessions').doc(sessionId).snapshots();
  }
}

final webCompanionServiceProvider = Provider((ref) => WebCompanionService());