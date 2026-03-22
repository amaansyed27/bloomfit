import 'package:bloomfit/features/home/domain/workout_activity.dart';
import 'package:bloomfit/features/workouts/data/custom_workout_repository.dart';
import 'package:bloomfit/features/workouts/domain/custom_workout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'custom_workout_repository_test.mocks.dart';

@GenerateMocks([
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  QuerySnapshot,
  QueryDocumentSnapshot,
])
void main() {
  late CustomWorkoutRepository repository;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockUsersCollection;
  late MockDocumentReference<Map<String, dynamic>> mockUserDoc;
  late MockCollectionReference<Map<String, dynamic>> mockWorkoutsCollection;
  late MockDocumentReference<Map<String, dynamic>> mockWorkoutDoc;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockUsersCollection = MockCollectionReference();
    mockUserDoc = MockDocumentReference();
    mockWorkoutsCollection = MockCollectionReference();
    mockWorkoutDoc = MockDocumentReference();

    // Mock the chain: firestore.collection('users').doc(uid).collection('custom_workouts').doc(id)
    when(mockFirestore.collection('users')).thenReturn(mockUsersCollection);
    when(mockUsersCollection.doc(any)).thenReturn(mockUserDoc);
    when(
      mockUserDoc.collection('custom_workouts'),
    ).thenReturn(mockWorkoutsCollection);
    when(mockWorkoutsCollection.doc(any)).thenReturn(mockWorkoutDoc);

    repository = CustomWorkoutRepository(mockFirestore);
  });

  group('CustomWorkoutRepository', () {
    final testWorkout = CustomWorkout(
      id: 'workout_123',
      name: 'Test Workout',
      activities: [
        WorkoutActivity(exerciseId: 'ex_1', sets: 3, reps: 10, notes: 'Test'),
      ],
      createdAt: DateTime.now(),
    );
    const userId = 'user_abc';

    test('saveWorkout calls set on the correct document reference', () async {
      // Arrange
      when(mockWorkoutDoc.set(any)).thenAnswer((_) async => {});

      // Act
      await repository.saveWorkout(userId, testWorkout);

      // Assert
      verify(mockFirestore.collection('users')).called(1);
      verify(mockUsersCollection.doc(userId)).called(1);
      verify(mockUserDoc.collection('custom_workouts')).called(1);
      verify(mockWorkoutsCollection.doc(testWorkout.id)).called(1);
      verify(mockWorkoutDoc.set(any)).called(1);
    });

    test(
      'deleteWorkout calls delete on the correct document reference',
      () async {
        // Arrange
        when(mockWorkoutDoc.delete()).thenAnswer((_) async => {});

        // Act
        await repository.deleteWorkout(userId, testWorkout.id);

        // Assert
        verify(mockWorkoutsCollection.doc(testWorkout.id)).called(1);
        verify(mockWorkoutDoc.delete()).called(1);
      },
    );
  });
}
