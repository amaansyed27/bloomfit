import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/custom_workout_repository.dart';
import '../pages/active_workout_overview.dart';
// import '../../data/models/exercise_model.dart';
import '../../data/exercise_repository.dart'; // To fetch full exercise details if needed
import '../../../authentication/data/user_repository.dart';
import '../../data/workout_stats_provider.dart';

class SavedWorkoutsView extends ConsumerWidget {
  const SavedWorkoutsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(userCustomWorkoutsProvider);
    final allExercisesAsync = ref.watch(exercisesStreamProvider);
    final statsAsync = ref.watch(workoutStatsProvider);

    return Column(
      children: [
        // Analytics Dashboard Header
        statsAsync.when(
          data: (stats) {
            return Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B6B).withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.analytics, color: Colors.white, size: 24),
                      SizedBox(width: 8),
                      Text(
                        "Performance Analytics",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatItem("Accuracy", "${stats.averageAccuracy}%"),
                      _buildStatItem("Workouts", "${stats.totalWorkouts}"),
                      _buildStatItem(
                        "Time",
                        "${(stats.totalDurationSeconds / 60).round()}m",
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),

        // Saved Workouts List
        Expanded(
          child: workoutsAsync.when(
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
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
                                      pathNodeId: '', // Custom workout
                                    ),
                                  ),
                                );
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () {
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
                                              .read(
                                                customWorkoutRepositoryProvider,
                                              )
                                              .deleteWorkout(
                                                user.uid,
                                                workout.id,
                                              );
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
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
