import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'models/exercise_model.dart';

Future<void> seedStart({bool force = false}) async {
  final firestore = FirebaseFirestore.instance;
  final collection = firestore.collection('exercises');

  if (!force) {
    // Check if we have a significant number of exercises already
    final snapshot = await collection.limit(50).get();
    if (snapshot.docs.length >= 40) {
      debugPrint("Database already appears to be seeded with large dataset.");
      return;
    }
  }

  final List<ExerciseModel> exercises = [
    // --- CHEST ---
    ExerciseModel(
      id: 'pushup_001',
      name: 'Push Up',
      bodyPart: 'Chest',
      equipment: 'Bodyweight',
      difficulty: 'Beginner',
      instructions: ['Plank position', 'Lower chest to floor', 'Push back up'],
      imageUrl: '',
    ),
    ExerciseModel(
      id: 'db_bench_001',
      name: 'Dumbbell Bench Press',
      bodyPart: 'Chest',
      equipment: 'Dumbbell',
      difficulty: 'Intermediate',
      instructions: ['Lie on bench', 'Press DBs up', 'Lower smoothly'],
      imageUrl: '',
    ),
    ExerciseModel(
      id: 'chest_dip_001',
      name: 'Chest Dip',
      bodyPart: 'Chest',
      equipment: 'Bodyweight',
      difficulty: 'Intermediate',
      instructions: ['Lean forward on bars', 'Lower body', 'Push up'],
      imageUrl: '',
    ),
    ExerciseModel(
      id: 'incline_pushup_001',
      name: 'Incline Push Up',
      bodyPart: 'Chest',
      equipment: 'Box/Bench',
      difficulty: 'Beginner',
      instructions: ['Hands on bench', 'Perform pushup', 'Keep core tight'],
      imageUrl: '',
    ),
    ExerciseModel(
      id: 'db_fly_001',
      name: 'Dumbbell Fly',
      bodyPart: 'Chest',
      equipment: 'Dumbbell',
      difficulty: 'Intermediate',
      instructions: ['Lie on bench', 'Open arms wide', 'Bring DBs together'],
      imageUrl: '',
    ),

    // --- BACK ---
    ExerciseModel(
      id: 'pullup_001',
      name: 'Pull Up',
      bodyPart: 'Back',
      equipment: 'Pull-up Bar',
      difficulty: 'Advanced',
      instructions: ['Hang from bar', 'Pull chin over bar', 'Lower fully'],
      imageUrl: '',
    ),
    ExerciseModel(
      id: 'db_row_001',
      name: 'One-Arm Dumbbell Row',
      bodyPart: 'Back',
      equipment: 'Dumbbell',
      difficulty: 'Intermediate',
      instructions: ['Knee on bench', 'Pull DB to hip', 'Lower controlled'],
      imageUrl: '',
    ),
    ExerciseModel(
      id: 'lat_pulldown_001',
      name: 'Lat Pulldown',
      bodyPart: 'Back',
      equipment: 'Machine/Band',
      difficulty: 'Beginner',
      instructions: ['Grip bar wide', 'Pull to chest', 'Release up'],
      imageUrl: '',
    ),
    ExerciseModel(
      id: 'superman_001',
      name: 'Superman',
      bodyPart: 'Back',
      equipment: 'Bodyweight',
      difficulty: 'Beginner',
      instructions: ['Lie on stomach', 'Lift arms and legs', 'Hold top'],
      imageUrl: '',
    ),
    ExerciseModel(
      id: 'inverted_row_001',
      name: 'Inverted Row',
      bodyPart: 'Back',
      equipment: 'Bar/Rings',
      difficulty: 'Intermediate',
      instructions: [
        'Hang under bar',
        'Pull chest to bar',
        'Keep body straight',
      ],
      imageUrl: '',
    ),

    // --- LEGS ---
    ExerciseModel(
      id: 'squat_001',
      name: 'Air Squat',
      bodyPart: 'Legs',
      equipment: 'Bodyweight',
      difficulty: 'Beginner',
      instructions: ['Feet shoulder width', 'Sit back and down', 'Stand up'],
      imageUrl: '',
    ),
    ExerciseModel(
      id: 'goblet_squat_001',
      name: 'Goblet Squat',
      bodyPart: 'Legs',
      equipment: 'Dumbbell/Kettlebell',
      difficulty: 'Intermediate',
      instructions: ['Hold weight at chest', 'Squat deep', 'Keep chest up'],
      imageUrl: '',
    ),
    ExerciseModel(
      id: 'lunge_001',
      name: 'Walking Lunge',
      bodyPart: 'Legs',
      equipment: 'Bodyweight',
      difficulty: 'Intermediate',
      instructions: ['Step forward', 'Drop back knee', 'Push to next step'],
      imageUrl: '',
    ),
    ExerciseModel(
      id: 'glute_bridge_001',
      name: 'Glute Bridge',
      bodyPart: 'Legs',
      equipment: 'Bodyweight',
      difficulty: 'Beginner',
      instructions: ['Lie on back', 'Lift hips high', 'Squeeze glutes'],
      imageUrl: '',
    ),
    ExerciseModel(
      id: 'rdl_001',
      name: 'Romanian Deadlift',
      bodyPart: 'Legs',
      equipment: 'Dumbbell/Barbell',
      difficulty: 'Intermediate',
      instructions: [
        'Hinge at hips',
        'Keep back flat',
        'Feel hamstring stretch',
      ],
      imageUrl: '',
    ),
    ExerciseModel(
      id: 'calf_raise_001',
      name: 'Calf Raise',
      bodyPart: 'Legs',
      equipment: 'Bodyweight',
      difficulty: 'Beginner',
      instructions: ['Stand on toes', 'Lower heels down', 'Repeat'],
      imageUrl: '',
    ),

    // --- SHOULDERS ---
    ExerciseModel(
      id: 'shoulder_press_001',
      name: 'Overhead Press',
      bodyPart: 'Shoulders',
      equipment: 'Dumbbell/Barbell',
      difficulty: 'Intermediate',
      instructions: ['Press weight overhead', 'Lock out arms', 'Lower to chin'],
      imageUrl: '',
    ),
    ExerciseModel(
      id: 'lateral_raise_001',
      name: 'Lateral Raise',
      bodyPart: 'Shoulders',
      equipment: 'Dumbbell',
      difficulty: 'Beginner',
      instructions: [
        'Lift DBs to side',
        'Elbows slightly bent',
        'Lower slowly',
      ],
      imageUrl: '',
    ),
    ExerciseModel(
      id: 'pike_pushup_001',
      name: 'Pike Push Up',
      bodyPart: 'Shoulders',
      equipment: 'Bodyweight',
      difficulty: 'Intermediate',
      instructions: ['Hips high forming V', 'Lower head to floor', 'Push back'],
      imageUrl: '',
    ),

    // --- ARMS ---
    ExerciseModel(
      id: 'bicep_curl_001',
      name: 'Bicep Curl',
      bodyPart: 'Arms',
      equipment: 'Dumbbell',
      difficulty: 'Beginner',
      instructions: ['Curl weight up', 'Squeeze bicep', 'Lower slowly'],
      imageUrl: '',
    ),
    ExerciseModel(
      id: 'tricep_dip_001',
      name: 'Bench Dip',
      bodyPart: 'Arms',
      equipment: 'Bench',
      difficulty: 'Beginner',
      instructions: ['Hands on bench behind', 'Lower hips', 'Extend arms'],
      imageUrl: '',
    ),
    ExerciseModel(
      id: 'diamond_pushup_001',
      name: 'Diamond Push Up',
      bodyPart: 'Arms',
      equipment: 'Bodyweight',
      difficulty: 'Advanced',
      instructions: ['Hands close together', 'Elbows in', 'Push up'],
      imageUrl: '',
    ),
    ExerciseModel(
      id: 'hammer_curl_001',
      name: 'Hammer Curl',
      bodyPart: 'Arms',
      equipment: 'Dumbbell',
      difficulty: 'Beginner',
      instructions: ['Palms facing in', 'Curl weight up', 'Lower slowly'],
      imageUrl: '',
    ),

    // --- CORE ---
    ExerciseModel(
      id: 'plank_001',
      name: 'Plank',
      bodyPart: 'Core',
      equipment: 'Bodyweight',
      difficulty: 'Beginner',
      instructions: ['Forearms on floor', 'Straight body line', 'Hold'],
      imageUrl: '',
    ),
    ExerciseModel(
      id: 'crunch_001',
      name: 'Crunch',
      bodyPart: 'Core',
      equipment: 'Bodyweight',
      difficulty: 'Beginner',
      instructions: ['Lie on back', 'Lift shoulders off floor', 'Lower'],
      imageUrl: '',
    ),
    ExerciseModel(
      id: 'leg_raise_001',
      name: 'Leg Raise',
      bodyPart: 'Core',
      equipment: 'Bodyweight',
      difficulty: 'Intermediate',
      instructions: [
        'Lie on back',
        'Lift legs to 90 deg',
        'Lower not touching floor',
      ],
      imageUrl: '',
    ),
    ExerciseModel(
      id: 'bicycle_crunch_001',
      name: 'Bicycle Crunch',
      bodyPart: 'Core',
      equipment: 'Bodyweight',
      difficulty: 'Intermediate',
      instructions: [
        'Elbow to opposite knee',
        'Rotate torso',
        'Alternate sides',
      ],
      imageUrl: '',
    ),
    ExerciseModel(
      id: 'russian_twist_001',
      name: 'Russian Twist',
      bodyPart: 'Core',
      equipment: 'Bodyweight/Weight',
      difficulty: 'Intermediate',
      instructions: ['Sit V-shape', 'Twist torso side to side', 'Touch floor'],
      imageUrl: '',
    ),

    // --- CARDIO / HIIT ---
    ExerciseModel(
      id: 'burpee_001',
      name: 'Burpee',
      bodyPart: 'Cardio',
      equipment: 'Bodyweight',
      difficulty: 'Advanced',
      instructions: ['Squat', 'Plank', 'Pushup', 'Jump up'],
      imageUrl: '',
    ),
    ExerciseModel(
      id: 'jumping_jack_001',
      name: 'Jumping Jacks',
      bodyPart: 'Cardio',
      equipment: 'Bodyweight',
      difficulty: 'Beginner',
      instructions: ['Jump feet wide', 'Arms overhead', 'Return'],
      imageUrl: '',
    ),
    ExerciseModel(
      id: 'mountain_climber_001',
      name: 'Mountain Climbers',
      bodyPart: 'Cardio',
      equipment: 'Bodyweight',
      difficulty: 'Intermediate',
      instructions: ['Plank position', 'Drive knees to chest', 'Fast pace'],
      imageUrl: '',
    ),
    ExerciseModel(
      id: 'high_knees_001',
      name: 'High Knees',
      bodyPart: 'Cardio',
      equipment: 'Bodyweight',
      difficulty: 'Beginner',
      instructions: ['Run in place', 'Knees up high', 'Fast pace'],
      imageUrl: '',
    ),
    ExerciseModel(
      id: 'jump_rope_001',
      name: 'Jump Rope',
      bodyPart: 'Cardio',
      equipment: 'Jump Rope',
      difficulty: 'Intermediate',
      instructions: ['Jump over rope', 'Land on toes', 'Keep rhythm'],
      imageUrl: '',
    ),

    // --- YOGA / STRETCH ---
    ExerciseModel(
      id: 'downward_dog_001',
      name: 'Downward Dog',
      bodyPart: 'Yoga',
      equipment: 'Mat',
      difficulty: 'Beginner',
      instructions: ['Hips high', 'Heels toward floor', 'Push through hands'],
      imageUrl: '',
    ),
    ExerciseModel(
      id: 'warrior_one_001',
      name: 'Warrior I',
      bodyPart: 'Yoga',
      equipment: 'Mat',
      difficulty: 'Beginner',
      instructions: ['Lunge forward', 'Arms overhead', 'Back heel down'],
      imageUrl: '',
    ),
    ExerciseModel(
      id: 'child_pose_001',
      name: 'Child Pose',
      bodyPart: 'Yoga',
      equipment: 'Mat',
      difficulty: 'Beginner',
      instructions: ['Knees wide', 'Sit on heels', 'Reach arms forward'],
      imageUrl: '',
    ),
    ExerciseModel(
      id: 'cobra_001',
      name: 'Cobra Pose',
      bodyPart: 'Yoga',
      equipment: 'Mat',
      difficulty: 'Beginner',
      instructions: ['Lie on stomach', 'Push chest up', 'Keep hips down'],
      imageUrl: '',
    ),
  ];

  final batch = firestore.batch();
  for (var exercise in exercises) {
    var docRef = collection.doc(exercise.id);
    batch.set(docRef, exercise.toJson());
  }
  await batch.commit();
  debugPrint("Large Seed Complete: ${exercises.length} exercises.");
}
