import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../onboarding/domain/user_profile.dart';

class UserRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  UserRepository(this._firestore, this._auth);

  Stream<UserProfile?> watchUserProfile() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);

    return _firestore.collection('users').doc(user.uid).snapshots().map((
      snapshot,
    ) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return UserProfile.fromMap(snapshot.data()!, snapshot.id);
    });
  }

  Future<void> updateUserStats({
    required int xpChange,
    Map<String, dynamic>? muscleFatigueUpdates,
    Map<String, dynamic>? proficiencyUpdates,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore.collection('users').doc(user.uid);
    
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      int currentStreak = data['streak'] ?? 0;
      Timestamp? lastWorkout = data['lastWorkoutDate'];

      final now = DateTime.now();
      int newStreak = currentStreak;

      if (lastWorkout != null) {
        final lastDate = lastWorkout.toDate();
        final difference = now.difference(lastDate).inDays;

        if (difference == 1) {
          // Worked out yesterday, increment streak
          newStreak += 1;
        } else if (difference > 1) {
          // Missed a day, reset streak
          newStreak = 1;
        }
        // If difference == 0, they already worked out today. Streak stays same.
      } else {
        // First workout ever
        newStreak = 1;
      }

      Map<String, dynamic> updates = {
        'xp': FieldValue.increment(xpChange),
        'streak': newStreak,
        'lastWorkoutDate': FieldValue.serverTimestamp(),
      };

      if (muscleFatigueUpdates != null) {
        updates['muscleFatigue'] = muscleFatigueUpdates;
      }
      if (proficiencyUpdates != null) {
        updates['exerciseProficiency'] = proficiencyUpdates;
      }

      transaction.update(docRef, updates);
    });
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _firestore.collection('users').doc(user.uid).update(data);
  }
}

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(FirebaseFirestore.instance, FirebaseAuth.instance);
});

final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final repo = ref.watch(userRepositoryProvider);
  return repo.watchUserProfile();
});
