import 'package:flutter/material.dart';
import '../../../home/domain/workout_activity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/exercise_repository.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/exercise_model.dart';
import '../pages/active_workout_overview.dart';
import '../../domain/custom_workout.dart';
import '../../data/custom_workout_repository.dart';
import '../../../authentication/data/user_repository.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../../utils/exercise_model_utils.dart';

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge({required this.text, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class WorkoutCrafterView extends ConsumerStatefulWidget {
  const WorkoutCrafterView({super.key});

  @override
  ConsumerState<WorkoutCrafterView> createState() => _WorkoutCrafterViewState();
}

class _WorkoutCrafterViewState extends ConsumerState<WorkoutCrafterView> {
  // Filter States
  String _selectedBodyPart = "All";
  String _selectedDifficulty = "All";
  bool _equipmentNeeded = true;

  // Selection State
  final List<ExerciseModel> _selectedExercises = [];

  final List<String> _bodyParts = [
    "All",
    "Chest",
    "Back",
    "Legs",
    "Arms",
    "Shoulders",
    "Core",
    "Cardio",
  ];

  final List<String> _difficulties = [
    "All",
    "Beginner",
    "Intermediate",
    "Advanced",
  ];

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(exercisesStreamProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: _selectedExercises.isNotEmpty
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton.extended(
                  heroTag: 'save_workout',
                  onPressed: () {
                    _showSaveDialog(context, ref);
                  },
                  backgroundColor: Colors.white,
                  icon: const Icon(
                    Icons.save_rounded,
                    color: Color(0xFFFF6B6B),
                  ),
                  label: const Text(
                    "Save",
                    style: TextStyle(
                      color: Color(0xFFFF6B6B),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                FloatingActionButton.extended(
                  heroTag: 'start_workout',
                  onPressed: () {
                    // Create default activities
                    final activities = _selectedExercises
                        .map(
                          (e) => WorkoutActivity(
                            exerciseId: e.id,
                            sets: 3,
                            reps: 12,
                            notes: "Custom selection",
                          ),
                        )
                        .toList();

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ActiveWorkoutOverview(
                          activities: activities,
                          allExercises: _selectedExercises,
                          workoutTitle: "Custom Workout",
                          pathNodeId: '', // Custom workout
                        ),
                      ),
                    );
                  },
                  backgroundColor: const Color(0xFFFF6B6B),
                  icon: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                  ),
                  label: Text(
                    "Start (${_selectedExercises.length})",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            )
          : null,
      body: Column(
        children: [
          // 1. Filters Section
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            // margin: const EdgeInsets.only(top: 130), // Handled by Hub Screen now
            color: const Color(0xFFFAFAFA),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFilterSection(
                  "Body Part",
                  _bodyParts,
                  _selectedBodyPart,
                  (val) {
                    setState(() => _selectedBodyPart = val);
                  },
                ),
                const SizedBox(height: 12),
                _buildFilterSection(
                  "Difficulty",
                  _difficulties,
                  _selectedDifficulty,
                  (val) {
                    setState(() => _selectedDifficulty = val);
                  },
                ),
                const SizedBox(height: 12),
                // Equipment Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Include Equipment?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Switch(
                      value: _equipmentNeeded,
                      activeThumbColor: const Color(0xFFFF6B6B),
                      onChanged: (val) {
                        setState(() => _equipmentNeeded = val);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. Exercise List
          Expanded(
            child: exercisesAsync.when(
              data: (exercises) {
                final filtered = exercises.where((ex) {
                  final matchBody =
                      _selectedBodyPart == "All" ||
                      ex.bodyPart == _selectedBodyPart;
                  final matchDiff =
                      _selectedDifficulty == "All" ||
                      ex.difficulty == _selectedDifficulty;
                  final isBodyweight = ex.equipment == "Bodyweight";
                  final matchEquip = _equipmentNeeded ? true : isBodyweight;

                  return matchBody && matchDiff && matchEquip;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text(
                      "No exercises found",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 0,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final ex = filtered[index];
                    return _buildExerciseCard(ex);
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF6B6B)),
              ),
              error: (err, stack) => Center(child: Text("Error: $err")),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(ExerciseModel ex) {
    final isSelected = _selectedExercises.contains(ex);
    return GestureDetector(
      onTap: () {
        _showExercisePreview(context, ex);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFF6B6B).withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: const Color(0xFFFF6B6B), width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Placeholder Image
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: ex.imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(ex.imageUrl, fit: BoxFit.cover),
                    )
                  : const Icon(Icons.fitness_center, color: Colors.grey),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ex.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "${ex.bodyPart} • ${ex.difficulty}",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                isSelected
                    ? Icons.check_circle_rounded
                    : Icons.add_circle_outline_rounded,
                color: const Color(0xFFFF6B6B),
              ),
              onPressed: () {
                setState(() {
                  if (isSelected) {
                    _selectedExercises.remove(ex);
                  } else {
                    _selectedExercises.add(ex);
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showExercisePreview(BuildContext context, ExerciseModel ex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 16),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // 3D Model Viewer
              Container(
                height: 250,
                width: double.infinity,
                color: Colors.grey[50],
                child: ModelViewer(
                  src: getGlbPathForExercise(ex.name),
                  alt: ex.name,
                  autoPlay: true,
                  autoRotate: true,
                  cameraControls: true,
                  disableZoom: true,
                  backgroundColor: Colors.transparent,
                ),
              ),

              // Exercise Details
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ex.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _Badge(text: ex.bodyPart, color: Colors.blue),
                          const SizedBox(width: 8),
                          _Badge(text: ex.difficulty, color: Colors.orange),
                          const SizedBox(width: 8),
                          _Badge(text: ex.equipment, color: Colors.purple),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Instructions",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (ex.instructions.isEmpty)
                        const Text(
                          "No instructions available.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ...ex.instructions.asMap().entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFFF6B6B,
                                  ).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    "${entry.key + 1}",
                                    style: const TextStyle(
                                      color: Color(0xFFFF6B6B),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  entry.value,
                                  style: const TextStyle(height: 1.4),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterSection(
    String title,
    List<String> options,
    String selected,
    Function(String) onSelect,
  ) {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final option = options[index];
          final isSelected = option == selected;
          return GestureDetector(
            onTap: () => onSelect(option),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFF6B6B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFFF6B6B)
                      : Colors.grey[300]!,
                ),
              ),
              child: Center(
                // Center content vertically
                child: Text(
                  option,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSaveDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Save Workout"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "Workout Name (e.g. Monday Chest)",
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isEmpty) return;

                final user = ref.read(userProfileProvider).value;
                if (user == null) return;

                final activities = _selectedExercises
                    .map(
                      (e) => WorkoutActivity(
                        exerciseId: e.id,
                        sets: 3,
                        reps: 12,
                        notes: "Custom selection",
                      ),
                    )
                    .toList();

                final workout = CustomWorkout(
                  id: const Uuid().v4(),
                  name: name,
                  activities: activities,
                  createdAt: DateTime.now(),
                );

                await ref
                    .read(customWorkoutRepositoryProvider)
                    .saveWorkout(user.uid, workout);

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Saved '$name' to Library!")),
                  );
                  // Optional: Clear selection?
                  // setState(() => _selectedExercises.clear());
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }
}
