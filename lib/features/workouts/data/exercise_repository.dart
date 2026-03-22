import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/exercise_model.dart';

class ExerciseRepository {
  final FirebaseFirestore _firestore;

  ExerciseRepository(this._firestore);

  Stream<List<ExerciseModel>> watchExercises() {
    return _firestore.collection('exercises').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ExerciseModel.fromJson(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<List<ExerciseModel>> getExercises() async {
    final snapshot = await _firestore.collection('exercises').get();
    return snapshot.docs.map((doc) {
      return ExerciseModel.fromJson(doc.data(), doc.id);
    }).toList();
  }
}

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return ExerciseRepository(FirebaseFirestore.instance);
});

final exercisesStreamProvider = StreamProvider<List<ExerciseModel>>((ref) {
  final repository = ref.watch(exerciseRepositoryProvider);
  return repository.watchExercises();
});
