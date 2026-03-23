import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/path_models.dart';
import '../domain/workout_activity.dart';
import 'path_generation_service.dart';
import '../../authentication/data/user_repository.dart';

class PathRepository {
  final FirebaseFirestore _firestore;
  final PathGenerationService _generationService;

  PathRepository(this._firestore, this._generationService);

  Stream<List<PathNodeData>> watchPathPlan(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('path_nodes')
        .orderBy('position')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            // Handle legacy exerciseIds or new activities
            List<WorkoutActivity> activities = [];
            if (data['activities'] != null) {
              activities = (data['activities'] as List)
                  .map((a) => WorkoutActivity.fromJson(a))
                  .toList();
            } else if (data['exerciseIds'] != null) {
              // Backward compatibility
              activities = (data['exerciseIds'] as List)
                  .map(
                    (id) => WorkoutActivity(
                      exerciseId: id.toString(),
                      sets: 3,
                      reps: 12,
                    ),
                  )
                  .toList();
            }

            return PathNodeData(
              id: doc.id,
              title: data['title'] ?? 'Workout',
              type: NodeType.values.byName(data['type'] ?? 'strength'),
              state: PathNodeState.values.byName(data['state'] ?? 'locked'),
              position: data['position'] ?? 0,
              activities: activities,
            );
          }).toList();
        });
  }

  Stream<int> watchHistoryCount(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('history')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<void> ensurePathExists(String uid, dynamic userProfile) async {
    // Check if path exists logic is handled inside generation service
    // But we need to call it.
    // We can call generation service.
    // Since we need UserProfile for generation, we pass it.
    await _generationService.generatePathForUser(userProfile);
  }

  Future<void> completeNode(String uid, String nodeId) async {
    final pathRef = _firestore.collection('users').doc(uid).collection('path_nodes');
    
    // Mark current node as done
    await pathRef.doc(nodeId).update({'state': 'done'});
    
    // Find next locked node and mark it active
    final nextNodeSnapshot = await pathRef
        .where('state', isEqualTo: 'locked')
        .orderBy('position')
        .limit(1)
        .get();
        
    if (nextNodeSnapshot.docs.isNotEmpty) {
      await pathRef.doc(nextNodeSnapshot.docs.first.id).update({'state': 'active'});
    }
  }
}

final pathRepositoryProvider = Provider<PathRepository>((ref) {
  return PathRepository(
    FirebaseFirestore.instance,
    ref.watch(pathGenerationServiceProvider),
  );
});

final pathPlanProvider = StreamProvider<List<PathNodeData>>((ref) {
  final user = ref.watch(userProfileProvider).value;
  if (user == null) return Stream.value([]);

  final repo = ref.watch(pathRepositoryProvider);
  // Removed side-effect: ensurePathExists is now handled by pathInitializationProvider
  return repo.watchPathPlan(user.uid);
});

final pathInitializationProvider = FutureProvider<void>((ref) async {
  // Only watch for UID changes (Login/Logout)
  // This prevents re-running generation when stats (XP/Streak) change.
  final uid = ref.watch(
    userProfileProvider.select((value) => value.value?.uid),
  );

  if (uid != null) {
    // Read the latest profile for generation parameters without listening
    final user = ref.read(userProfileProvider).value;
    if (user != null) {
      final repo = ref.read(pathRepositoryProvider);
      await repo.ensurePathExists(uid, user);
    }
  }
});

final historyCountProvider = StreamProvider<int>((ref) {
  final user = ref.watch(userProfileProvider).value;
  if (user == null) return Stream.value(0);

  return ref.watch(pathRepositoryProvider).watchHistoryCount(user.uid);
});

final pathNodesProvider = Provider<AsyncValue<List<PathNodeData>>>((ref) {
  return ref.watch(pathPlanProvider);
});
