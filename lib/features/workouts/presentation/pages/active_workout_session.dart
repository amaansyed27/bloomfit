import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/models/exercise_model.dart';
import 'package:bloomfit/features/home/domain/workout_activity.dart';
import 'workout_appraisal_screen.dart';

class ActiveWorkoutSession extends StatefulWidget {
  final List<WorkoutActivity> activities;
  final List<ExerciseModel> allExercises;
  final String workoutTitle;

  const ActiveWorkoutSession({
    super.key,
    required this.activities,
    required this.allExercises,
    required this.workoutTitle,
  });

  @override
  State<ActiveWorkoutSession> createState() => _ActiveWorkoutSessionState();
}

class _ActiveWorkoutSessionState extends State<ActiveWorkoutSession> {
  late PageController _pageController;
  int _currentExerciseIndex = 0;

  // Workout Timer
  Timer? _workoutTimer;
  int _elapsedSeconds = 0;
  bool _isPaused = false;

  // Exercise Specific State
  List<bool> _completedSets = [];
  Timer? _exerciseTimer; // For duration exercises (plank/cardio)
  int _remainingSeconds = 0;
  bool _isExerciseTimerRunning = false;

  // Data to save
  final List<Map<String, dynamic>> _completedSessionData = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startWorkoutTimer();
    _initCurrentActivity();
  }

  void _initCurrentActivity() {
    final activity = widget.activities[_currentExerciseIndex];
    final setCounts = activity.sets ?? 3;
    _completedSets = List.filled(setCounts, false);

    // If duration based
    if (activity.durationSeconds != null && activity.durationSeconds! > 0) {
      _remainingSeconds = activity.durationSeconds!;
      _isExerciseTimerRunning = false;
      _exerciseTimer?.cancel();
    }
  }

  void _startWorkoutTimer() {
    _workoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
  }

  void _toggleExerciseTimer() {
    if (_isExerciseTimerRunning) {
      _exerciseTimer?.cancel();
    } else {
      _exerciseTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (_remainingSeconds > 0) {
          setState(() {
            _remainingSeconds--;
          });
        } else {
          t.cancel();
          _isExerciseTimerRunning = false;
          // Auto-complete first set if it's a duration exercise
          if (_completedSets.isNotEmpty) {
            setState(() {
              _completedSets[0] = true;
            });
          }
        }
      });
    }
    setState(() {
      _isExerciseTimerRunning = !_isExerciseTimerRunning;
    });
  }

  void _nextExercise() {
    final activity = widget.activities[_currentExerciseIndex];
    final exercise = widget.allExercises.firstWhere(
      (e) => e.id == activity.exerciseId,
      orElse: () => ExerciseModel(
        id: '?',
        name: 'Unknown',
        bodyPart: '',
        difficulty: '',
        instructions: [],
        imageUrl: '',
        equipment: '',
      ),
    );

    // Save data
    _completedSessionData.add({
      'exerciseId': activity.exerciseId,
      'name': exercise.name,
      'setsCompleted': _completedSets.where((s) => s).length,
      'totalSets': _completedSets.length,
      'notes': activity.notes,
    });

    if (_currentExerciseIndex < widget.activities.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _initCurrentActivity();
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishWorkout();
    }
  }

  Future<void> _finishWorkout() async {
    _workoutTimer?.cancel();
    _exerciseTimer?.cancel();

    // Navigate to Appraisal Screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => WorkoutAppraisalScreen(
          durationSeconds: _elapsedSeconds,
          exerciseData: _completedSessionData,
          workoutName: widget.workoutTitle,
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    // Show confirmation dialog
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Pause Workout?"),
        content: const Text("Choose an option to exit."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'resume'),
            child: const Text("Resume"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'discard'),
            child: const Text(
              "Discard (Delete)",
              style: TextStyle(color: Colors.red),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'finish'),
            child: const Text("Finish Early (Save)"),
          ),
        ],
      ),
    );

    if (result == 'discard') return true;
    if (result == 'finish') {
      _finishWorkout();
      return false;
    }
    return false;
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  @override
  void dispose() {
    _workoutTimer?.cancel();
    _exerciseTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalSteps = widget.activities.length;
    final activity = widget.activities[_currentExerciseIndex];
    final isDuration =
        activity.durationSeconds != null && activity.durationSeconds! > 0;

    final currentExercise = widget.allExercises.firstWhere(
      (e) => e.id == activity.exerciseId,
      orElse: () => ExerciseModel(
        id: '?',
        name: 'Loading...',
        bodyPart: '',
        difficulty: '',
        instructions: [],
        imageUrl: '',
        equipment: '',
      ),
    );

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        appBar: AppBar(
          title: Column(
            children: [
              Text(
                widget.workoutTitle,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              Text(
                _formatTime(_elapsedSeconds),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _onWillPop,
          ),
          actions: [
            IconButton(
              icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
              onPressed: () {
                setState(() {
                  _isPaused = !_isPaused;
                });
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: (_currentExerciseIndex + 1) / totalSteps,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFFF6B6B),
                  ),
                  minHeight: 6,
                ),
              ),
            ),

            // Exercise Card (Swipeable logic handled by Next button for now to enforce flow)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Lock swipe
                itemCount: totalSteps,
                itemBuilder: (context, index) {
                  // Re-fetch correct data for the index (though we mainly use state)
                  // We use _currentExerciseIndex state for logic, this builder is just for slide transition
                  if (index != _currentExerciseIndex)
                    return const SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Image / Animation Placeholder
                        Container(
                          height: 220,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                            image: currentExercise.imageUrl.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(
                                      currentExercise.imageUrl,
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: currentExercise.imageUrl.isEmpty
                              ? const Center(
                                  child: Icon(
                                    Icons.fitness_center,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: 24),

                        Text(
                          currentExercise.name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        if (activity.notes != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.lightbulb,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    activity.notes!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.brown[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const Spacer(),

                        // Interaction Area
                        if (isDuration) ...[
                          Text(
                            _formatTime(_remainingSeconds),
                            style: const TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _toggleExerciseTimer,
                            icon: Icon(
                              _isExerciseTimerRunning
                                  ? Icons.pause
                                  : Icons.play_arrow,
                            ),
                            label: Text(
                              _isExerciseTimerRunning ? "Pause" : "Start",
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6B6B),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ] else ...[
                          // Sets List
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              children: List.generate(_completedSets.length, (
                                i,
                              ) {
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      _completedSets[i] = !_completedSets[i];
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    margin: const EdgeInsets.only(bottom: 4),
                                    decoration: BoxDecoration(
                                      color: _completedSets[i]
                                          ? const Color(0xFFE8F5E9)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Set ${i + 1}",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: _completedSets[i]
                                                ? Colors.green[800]
                                                : Colors.grey[800],
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "${activity.reps ?? 12} reps",
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Icon(
                                              _completedSets[i]
                                                  ? Icons.check_circle
                                                  : Icons.circle_outlined,
                                              color: _completedSets[i]
                                                  ? Colors.green
                                                  : Colors.grey[300],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                        const Spacer(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: _nextExercise,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF212121),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currentExerciseIndex < totalSteps - 1
                        ? "Next Exercise"
                        : "Finish Workout",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
