import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/workout_history_repository.dart';
import '../../../authentication/data/user_repository.dart';
import '../../../home/data/path_generation_service.dart';

import '../../../home/data/path_repository.dart';

class WorkoutAppraisalScreen extends ConsumerStatefulWidget {
  final int durationSeconds;
  final List<Map<String, dynamic>> exerciseData;
  final String workoutName;
  final String pathNodeId;

  const WorkoutAppraisalScreen({
    super.key,
    required this.durationSeconds,
    required this.exerciseData,
    required this.workoutName,
    required this.pathNodeId,
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
  int _accuracy = 100;
  final List<Map<String, dynamic>> _skippedExercises = [];

  @override
  void initState() {
    super.initState();
    _calculateAccuracy();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _confettiController.play();
  }

  void _calculateAccuracy() {
    int totalPossibleSets = 0;
    int completedSets = 0;

    for (var ex in widget.exerciseData) {
      int tSets = ex['totalSets'] ?? 1; // Default to 1 for duration
      totalPossibleSets += tSets;

      if (ex['skipped'] == true) {
         _skippedExercises.add(ex);
      } else {
         completedSets += (ex['setsCompleted'] as int? ?? 0);
      }
    }

    if (totalPossibleSets > 0) {
      _accuracy = ((completedSets / totalPossibleSets) * 100).clamp(0, 100).toInt();
    }
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
                  SizedBox(
                    height: 120,
                    width: 120,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: _accuracy / 100,
                          strokeWidth: 12,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _accuracy >= 80 ? Colors.green : Colors.orange,
                          ),
                        ),
                        Center(
                          child: Text(
                            "$_accuracy%",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: _accuracy >= 80 ? Colors.green[700] : Colors.orange[800],
                            ),
                          ),
                        ),
                      ],
                    ),
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
                              accuracy: _accuracy,
                              isJourneyPath: widget.pathNodeId.isNotEmpty,
                            );

                        // Calc Fatigue and Proficiency updates
                        final currentProfile = ref.read(userProfileProvider).value;
                        Map<String, dynamic> fatigueUpdates = Map.from(currentProfile?.muscleFatigue ?? {});
                        Map<String, dynamic> proficiencyUpdates = Map.from(currentProfile?.exerciseProficiency ?? {});
                        
                        // Decay fatigue slightly
                        fatigueUpdates.updateAll((key, value) => ((value as num).toDouble() * 0.8).clamp(0.0, 100.0));
                        
                        for (var ex in widget.exerciseData) {
                          if (ex['skipped'] == true) continue;
                          
                          // Fatigue increase per body part
                          String bodyPart = ex['bodyPart'] ?? 'fullBody';
                          double currentFatigue = (fatigueUpdates[bodyPart] as num?)?.toDouble() ?? 0.0;
                          fatigueUpdates[bodyPart] = (currentFatigue + 15.0).clamp(0.0, 100.0);
                          
                          // Proficiency increase based on sets
                          String name = ex['name'] ?? 'unknown';
                          double curProf = (proficiencyUpdates[name] as num?)?.toDouble() ?? 0.0;
                          proficiencyUpdates[name] = (curProf + ((ex['setsCompleted'] as int? ?? 1) * 2.0)).clamp(0.0, 100.0);
                        }

                        // Update User Stats
                        await ref
                            .read(userRepositoryProvider)
                            .updateUserStats(
                                xpChange: 50, 
                                muscleFatigueUpdates: fatigueUpdates, 
                                proficiencyUpdates: proficiencyUpdates,
                            );

                        // Mark node as complete and unlock next
                        if (widget.pathNodeId.isNotEmpty) {
                          final userProfile = ref.read(userProfileProvider).value;
                          if (userProfile != null) {
                             await ref.read(pathRepositoryProvider).completeNode(userProfile.uid, widget.pathNodeId);
                          }
                        }

                        // ----- Trigger Path Recalculation if needed -----
                        if (widget.pathNodeId.isNotEmpty) {
                           final userProfile = ref.read(userProfileProvider).value;
                           if (userProfile != null) {
                              // We don't await this so it happens silently in the background
                              ref.read(pathGenerationServiceProvider).recalculateUpcomingNodes(
                                userProfile, 
                                _intensity,
                                _accuracy,
                                _skippedExercises,
                              );
                           }
                        }

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
