import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/custom_workout_repository.dart';
import '../pages/active_workout_overview.dart';
// import '../../data/models/exercise_model.dart';
import '../../data/exercise_repository.dart'; // To fetch full exercise details if needed
import '../../../authentication/data/user_repository.dart';

class SavedWorkoutsView extends ConsumerWidget {
  const SavedWorkoutsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(userCustomWorkoutsProvider);
    final allExercisesAsync = ref.watch(exercisesStreamProvider);

    return workoutsAsync.when(
      data: (workouts) {
        if (workouts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.bookmark_border_rounded,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  "No saved workouts yet.",
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Text(
                  "Create one in the Crafter tab!",
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: workouts.length,
          itemBuilder: (context, index) {
            final workout = workouts[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B6B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.fitness_center,
                    color: Color(0xFFFF6B6B),
                  ),
                ),
                title: Text(
                  workout.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "${workout.activities.length} Exercises",
                  style: TextStyle(color: Colors.grey[600]),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.green,
                      ),
                      onPressed: () {
                        // We need full ExerciseModels for the Active page
                        // For simplicity, we filter the allExercises list
                        // This might be slow if list is huge, but fine for now.
                        allExercisesAsync.whenData((allExercises) {
                          final activityIds = workout.activities
                              .map((a) => a.exerciseId)
                              .toSet();
                          final relevantExercises = allExercises
                              .where((e) => activityIds.contains(e.id))
                              .toList();

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ActiveWorkoutOverview(
                                activities: workout.activities,
                                allExercises: relevantExercises,
                                workoutTitle: workout.name,
                              ),
                            ),
                          );
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        // Confirm Delete
                        showDialog(
                          context: context,
                          builder: (c) => AlertDialog(
                            title: const Text("Delete Workout?"),
                            content: const Text(
                              "This action cannot be undone.",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(c),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {
                                  final user = ref
                                      .read(userProfileProvider)
                                      .value;
                                  if (user != null) {
                                    ref
                                        .read(customWorkoutRepositoryProvider)
                                        .deleteWorkout(user.uid, workout.id);
                                  }
                                  Navigator.pop(c);
                                },
                                child: const Text(
                                  "Delete",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text("Error: $e")),
    );
  }
}
