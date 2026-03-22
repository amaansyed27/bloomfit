import 'package:flutter/material.dart';
import '../../../home/domain/workout_activity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/exercise_repository.dart';
import '../../data/premade_workouts_data.dart';
import '../pages/active_workout_overview.dart';

class PremadeWorkoutsView extends ConsumerWidget {
  const PremadeWorkoutsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercisesAsync = ref.watch(exercisesStreamProvider);

    return exercisesAsync.when(
      data: (allExercises) {
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: premadeWorkouts.length,
          itemBuilder: (context, index) {
            final workout = premadeWorkouts[index];
            return GestureDetector(
              onTap: () {
                // Filter exercises for this workout
                final workoutExercises = allExercises
                    .where((ex) => workout.exerciseIds.contains(ex.id))
                    .toList();

                if (workoutExercises.isNotEmpty) {
                  // Create valid WorkoutActivities from simple IDs
                  final activities = workoutExercises
                      .map(
                        (e) => WorkoutActivity(
                          exerciseId: e.id,
                          sets: 3,
                          reps: 12,
                          notes: "Premade workout set",
                        ),
                      )
                      .toList();

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ActiveWorkoutOverview(
                        activities: activities,
                        allExercises: allExercises,
                        workoutTitle: workout.title,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Error: Exercises not found for this workout.",
                      ),
                    ),
                  );
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Icon Box
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Color(workout.colorHex).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        Icons
                            .fitness_center, // Generic for now, can add icon to model
                        color: Color(workout.colorHex),
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workout.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF212121),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _Badge(
                                text: workout.duration,
                                icon: Icons.timer,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 12),
                              _Badge(
                                text: workout.difficulty,
                                icon: Icons.bar_chart,
                                color: Color(workout.colorHex),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Play Button
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF6B6B)),
      ),
      error: (err, stack) =>
          Center(child: Text("Error loading workouts: $err")),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;

  const _Badge({required this.text, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
