import 'models/workout_model.dart';

final List<WorkoutModel> premadeWorkouts = [
  WorkoutModel(
    id: 'full_body_ignite',
    title: 'Full Body Ignite',
    description: 'A high-energy routine targeting all major muscle groups.',
    difficulty: 'Beginner',
    duration: '20 min',
    colorHex: 0xFFFF6B6B,
    exerciseIds: ['pushup_001', 'squat_001', 'plank_001', 'jumping_jacks_001'],
  ),
  WorkoutModel(
    id: 'strength_builder',
    title: 'Strength Builder',
    description: 'Focus on compound movements to build raw power.',
    difficulty: 'Intermediate',
    duration: '45 min',
    colorHex: 0xFF4ECDC4,
    exerciseIds: [
      'deadlift_001',
      'db_press_001',
      'db_row_001',
      'shoulder_press_001',
    ],
  ),
  WorkoutModel(
    id: 'core_cardio_blitz',
    title: 'Core & Cardio Blitz',
    description:
        'Burn calories and tighten your core with this fast-paced session.',
    difficulty: 'Advanced',
    duration: '15 min',
    colorHex: 0xFFFFD93D,
    exerciseIds: ['burpee_001', 'plank_001', 'jumping_jacks_001', 'lunge_001'],
  ),
  WorkoutModel(
    id: 'hiit_explosion',
    title: 'HIIT Explosion',
    description: 'Max effort intervals for maximum fat burn.',
    difficulty: 'Advanced',
    duration: '25 min',
    colorHex: 0xFFFF6B6B,
    exerciseIds: [
      'jumping_jacks_001',
      'burpee_001',
      'mountain_climber_001',
      'high_knees_001',
    ],
  ),
  WorkoutModel(
    id: 'bodyweight_basics',
    title: 'Bodyweight Basics',
    description: 'Master the fundamentals with no equipment needed.',
    difficulty: 'Beginner',
    duration: '30 min',
    colorHex: 0xFF4ECDC4,
    exerciseIds: ['squat_001', 'pushup_001', 'lunge_001', 'plank_001'],
  ),
];
