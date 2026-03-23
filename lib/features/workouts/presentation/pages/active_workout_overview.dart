import 'package:flutter/material.dart';

import '../../data/models/exercise_model.dart';
import 'package:bloomfit/features/home/domain/workout_activity.dart';
import 'active_workout_session.dart';

class ActiveWorkoutOverview extends StatelessWidget {
  final List<WorkoutActivity> activities;
  final List<ExerciseModel> allExercises;
  final String workoutTitle;
  final String pathNodeId;

  const ActiveWorkoutOverview({
    super.key,
    required this.activities,
    required this.allExercises,
    required this.workoutTitle,
    required this.pathNodeId,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate total stats
    final exerciseCount = activities.length;
    final totalSets = activities.fold(0, (sum, act) => sum + (act.sets ?? 3));
    final estimatedDuration = activities.fold(0, (sum, act) {
      if (act.durationSeconds != null && act.durationSeconds! > 0) {
        return sum + (act.durationSeconds! + 30); // activity + rest
      }
      return sum + ((act.sets ?? 3) * 60); // approx 1 min per set
    });

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text("Workout Overview"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  workoutTitle,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _StatBadge(
                      icon: Icons.fitness_center,
                      text: "$exerciseCount exercises",
                    ),
                    const SizedBox(width: 12),
                    _StatBadge(
                      icon: Icons.timer,
                      text: "${(estimatedDuration / 60).round()} min",
                    ),
                    const SizedBox(width: 12),
                    _StatBadge(icon: Icons.layers, text: "$totalSets sets"),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Exercise List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: activities.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final activity = activities[index];
                final exercise = allExercises.firstWhere(
                  (e) => e.id == activity.exerciseId,
                  orElse: () => ExerciseModel.empty(),
                );

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Number
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            "${index + 1}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exercise.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              activity.durationSeconds != null &&
                                      activity.durationSeconds! > 0
                                  ? "${activity.durationSeconds}s duration"
                                  : "${activity.sets ?? 3} sets × ${activity.reps ?? 12} reps",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Icon
                      if (exercise.imageUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            exercise.imageUrl,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.fitness_center,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Start Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => ActiveWorkoutSession(
                      activities: activities,
                      allExercises: allExercises,
                      workoutTitle: workoutTitle,
                      pathNodeId: pathNodeId,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B6B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              child: const Text(
                "Start Workout",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String text;

  const _StatBadge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey[700]),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}
