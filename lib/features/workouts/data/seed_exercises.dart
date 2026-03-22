import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/exercise_model.dart';

Future<void> seedExercises() async {
  final firestore = FirebaseFirestore.instance;
  final collection = firestore.collection('exercises');

  // Check if exercises already exist to avoid duplicates/overwrite
  final snapshot = await collection.limit(1).get();
  if (snapshot.docs.isNotEmpty) {
    print("Database already seeded via check.");
    // Optional: return; // Uncomment to prevent re-seeding if data exists
    // For development, we might want to overwrite to update data.
  }

  final List<ExerciseModel> initialExercises = [
    ExerciseModel(
      id: 'pushup_001',
      name: 'Push Up',
      bodyPart: 'Chest',
      equipment: 'Bodyweight',
      difficulty: 'Beginner',
      instructions: [
        'Start in a plank position.',
        'Lower your body until your chest nearly touches the floor.',
        'Push back up to the starting position.',
      ],
      imageUrl: '',
    ),
    ExerciseModel(
      id: 'squat_001',
      name: 'Air Squat',
      bodyPart: 'Legs',
      equipment: 'Bodyweight',
      difficulty: 'Beginner',
      instructions: [
        'Stand with feet shoulder-width apart.',
        'Lower your hips back and down as if sitting in a chair.',
        'Keep your chest up and back straight.',
        'Return to standing.',
      ],
      imageUrl: '',
    ),
    ExerciseModel(
      id: 'lunge_001',
      name: 'Walking Lunge',
      bodyPart: 'Legs',
      equipment: 'Bodyweight',
      difficulty: 'Intermediate',
      instructions: [
        'Step forward with one leg.',
        'Lower your hips until both knees are bent at 90 degrees.',
        'Push off the front foot to step into the next lunge.',
      ],
      imageUrl: '',
    ),
    ExerciseModel(
      id: 'plank_001',
      name: 'Forearm Plank',
      bodyPart: 'Core',
      equipment: 'Bodyweight',
      difficulty: 'Beginner',
      instructions: [
        'Rest on your forearms and toes.',
        'Keep your body in a straight line from head to heels.',
        'Hold the position.',
      ],
      imageUrl: '',
    ),
    ExerciseModel(
      id: 'burpee_001',
      name: 'Burpee',
      bodyPart: 'Cardio',
      equipment: 'Bodyweight',
      difficulty: 'Intermediate',
      instructions: [
        'Start standing, then drop into a squat.',
        'Kick your feet back into a plank.',
        'Perform a push-up.',
        'Jump your feet back to your hands and jump up.',
      ],
      imageUrl: '',
    ),
    ExerciseModel(
      id: 'db_press_001',
      name: 'Dumbbell Bench Press',
      bodyPart: 'Chest',
      equipment: 'Dumbbell',
      difficulty: 'Intermediate',
      instructions: [
        'Lie on a bench with a dumbbell in each hand.',
        'Press the weights up over your chest.',
        'Lower them slowly to the sides of your chest.',
      ],
      imageUrl: '',
    ),
    ExerciseModel(
      id: 'db_row_001',
      name: 'Dumbbell Row',
      bodyPart: 'Back',
      equipment: 'Dumbbell',
      difficulty: 'Intermediate',
      instructions: [
        'Place one knee and hand on a bench.',
        'Pull the dumbbell up towards your hip.',
        'Lower it back down with control.',
      ],
      imageUrl: '',
    ),
    ExerciseModel(
      id: 'shoulder_press_001',
      name: 'Seated Shoulder Press',
      bodyPart: 'Shoulders',
      equipment: 'Dumbbell',
      difficulty: 'Intermediate',
      instructions: [
        'Sit on a bench with back support.',
        'Press dumbbells overhead until arms are extended.',
        'Lower them back to shoulder height.',
      ],
      imageUrl: '',
    ),
    ExerciseModel(
      id: 'deadlift_001',
      name: 'Barbell Deadlift',
      bodyPart: 'Back',
      equipment: 'Barbell',
      difficulty: 'Advanced',
      instructions: [
        'Stand with feet hip-width apart, barbell over mid-foot.',
        'Hinge at hips to grip the bar.',
        'Keep back flat and lift the bar by extending hips and knees.',
        'Lower back down with control.',
      ],
      imageUrl: '',
    ),
    ExerciseModel(
      id: 'jumping_jacks_001',
      name: 'Jumping Jacks',
      bodyPart: 'Cardio',
      equipment: 'Bodyweight',
      difficulty: 'Beginner',
      instructions: [
        'Stand feet together, arms at sides.',
        'Jump feet apart and raise arms overhead.',
        'Jump back to starting position.',
      ],
      imageUrl: '',
    ),
    ExerciseModel(
      id: 'bicep_curl_001',
      name: 'Dumbbell Bicep Curl',
      bodyPart: 'Arms',
      equipment: 'Dumbbell',
      difficulty: 'Beginner',
      instructions: [
        'Stand holding dumbbells at your sides.',
        'Curl the weights up towards your shoulders.',
        'Lower them back down slowly.',
      ],
      imageUrl: '',
    ),
    ExerciseModel(
      id: 'tricep_dip_001',
      name: 'Tricep Dip',
      bodyPart: 'Arms',
      equipment: 'Bodyweight',
      difficulty: 'Intermediate',
      instructions: [
        'Use parallel bars or a bench.',
        'Lower your body by bending elbows.',
        'Push back up to straighten arms.',
      ],
      imageUrl: '',
    ),
  ];

  final batch = firestore.batch();

  for (var exercise in initialExercises) {
    var docRef = collection.doc(exercise.id);
    batch.set(docRef, exercise.toJson());
  }

  await batch.commit();
  print("Seeding complete: ${initialExercises.length} exercises added.");
}
