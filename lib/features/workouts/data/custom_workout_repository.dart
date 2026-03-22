import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../authentication/data/user_repository.dart';
import '../domain/custom_workout.dart';

class CustomWorkoutRepository {
  final FirebaseFirestore _firestore;

  CustomWorkoutRepository(this._firestore);

  Future<void> saveWorkout(String uid, CustomWorkout workout) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('custom_workouts')
        .doc(workout.id)
        .set(workout.toJson());
  }

  Stream<List<CustomWorkout>> watchUserWorkouts(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('custom_workouts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return CustomWorkout.fromJson(doc.data(), doc.id);
          }).toList();
        });
  }

  Future<void> deleteWorkout(String uid, String workoutId) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('custom_workouts')
        .doc(workoutId)
        .delete();
  }
}

final customWorkoutRepositoryProvider = Provider<CustomWorkoutRepository>((
  ref,
) {
  return CustomWorkoutRepository(FirebaseFirestore.instance);
});

final userCustomWorkoutsProvider = StreamProvider<List<CustomWorkout>>((ref) {
  final user = ref.watch(userProfileProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(customWorkoutRepositoryProvider).watchUserWorkouts(user.uid);
});
