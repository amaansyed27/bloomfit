import 'exercise_model.dart';

class WorkoutModel {
  final String id;
  final String title;
  final String description;
  final String difficulty;
  final String duration;
  final int colorHex;
  final List<String> exerciseIds; // IDs to fetch from repo
  // We might also want to hold the actual ExerciseModels after fetching
  final List<ExerciseModel>? exercises;

  WorkoutModel({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.duration,
    required this.colorHex,
    required this.exerciseIds,
    this.exercises,
  });
}
