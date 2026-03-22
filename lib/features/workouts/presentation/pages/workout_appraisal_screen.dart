import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/workout_history_repository.dart';
import '../../../authentication/data/user_repository.dart';

class WorkoutAppraisalScreen extends ConsumerStatefulWidget {
  final int durationSeconds;
  final List<Map<String, dynamic>> exerciseData;
  final String workoutName;

  const WorkoutAppraisalScreen({
    super.key,
    required this.durationSeconds,
    required this.exerciseData,
    required this.workoutName,
  });

  @override
  ConsumerState<WorkoutAppraisalScreen> createState() =>
      _WorkoutAppraisalScreenState();
}

class _WorkoutAppraisalScreenState
    extends ConsumerState<WorkoutAppraisalScreen> {
  late ConfettiController _confettiController;
  double _intensity = 3; // 1-5
  double _breathing = 3; // 1-5

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return "${minutes}m ${secs}s";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Workout Complete!",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.workoutName,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),

                  // Summary Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _SummaryItem(
                          label: "Duration",
                          value: _formatTime(widget.durationSeconds),
                          icon: Icons.timer,
                        ),
                        _SummaryItem(
                          label: "Exercises",
                          value: "${widget.exerciseData.length}",
                          icon: Icons.fitness_center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Feedback Section
                  const Text(
                    "How was the intensity?",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: _intensity,
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: _getIntensityLabel(_intensity),
                    activeColor: const Color(0xFFFF6B6B),
                    onChanged: (v) => setState(() => _intensity = v),
                  ),
                  Text(
                    _getIntensityLabel(_intensity),
                    style: TextStyle(
                      color: const Color(0xFFFF6B6B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    "How was your breathing?",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: _breathing,
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: _getBreathingLabel(_breathing),
                    activeColor: Colors.blueAccent,
                    onChanged: (v) => setState(() => _breathing = v),
                  ),
                  Text(
                    _getBreathingLabel(_breathing),
                    style: const TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const Spacer(),

                  ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    shouldLoop: false,
                    colors: const [
                      Colors.green,
                      Colors.blue,
                      Colors.pink,
                      Colors.orange,
                      Colors.purple,
                    ],
                  ),

                  ElevatedButton(
                    onPressed: () async {
                      // Save feedback data to Firestore
                      try {
                        await ref
                            .read(workoutHistoryRepositoryProvider)
                            .saveWorkoutSession(
                              workoutName: widget.workoutName,
                              durationSeconds: widget.durationSeconds,
                              exerciseData: widget.exerciseData,
                              intensity: _intensity,
                              breathing: _breathing,
                            );

                        // Update User Stats (XP and Streak)
                        await ref
                            .read(userRepositoryProvider)
                            .updateUserStats(50, 1); // 50 XP, +1 Streak

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Workout Saved! +50 XP"),
                            ),
                          );
                          // Pop until we hit the main screen (VerticalTimelinePath)
                          Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error saving workout: $e")),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text("Finish & Save"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getIntensityLabel(double v) {
    if (v <= 1) return "Too Easy";
    if (v <= 2) return "Light";
    if (v <= 3) return "Perfect";
    if (v <= 4) return "Hard";
    return "Extreme";
  }

  String _getBreathingLabel(double v) {
    if (v <= 1) return "Normal";
    if (v <= 2) return "Slightly Elevated";
    if (v <= 3) return "Moderate";
    if (v <= 4) return "Heavy";
    return "Out of Breath";
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[400], size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
