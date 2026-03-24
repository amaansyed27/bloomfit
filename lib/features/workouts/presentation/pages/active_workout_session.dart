import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/exercise_model.dart';
import 'package:bloomfit/features/home/domain/workout_activity.dart';
import 'workout_appraisal_screen.dart';
import '../../data/web_companion_provider.dart';
import '../../data/web_companion_service.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ActiveWorkoutSession extends ConsumerStatefulWidget {
  final List<WorkoutActivity> activities;
  final List<ExerciseModel> allExercises;
  final String workoutTitle;
  final String pathNodeId;

  const ActiveWorkoutSession({
    super.key,
    required this.activities,
    required this.allExercises,
    required this.workoutTitle,
    required this.pathNodeId,
  });

  @override
  ConsumerState<ActiveWorkoutSession> createState() =>
      _ActiveWorkoutSessionState();
}

class _WorkoutStep {
  final WorkoutActivity activity;
  final ExerciseModel exercise;
  final int setIndex;
  final int totalSets;
  final int originalActivityIndex;
  _WorkoutStep(
    this.activity,
    this.exercise,
    this.setIndex,
    this.totalSets,
    this.originalActivityIndex,
  );
}

class _ActiveWorkoutSessionState extends ConsumerState<ActiveWorkoutSession> {
  late PageController _pageController;
  List<_WorkoutStep> _steps = [];
  int _currentStepIndex = 0;

  // Workout Timer
  Timer? _workoutTimer;
  int _elapsedSeconds = 0;
  bool _isPaused = false;

  // Exercise Specific State
  Timer? _exerciseTimer; // For duration exercises (plank/cardio)
  int _remainingSeconds = 0;
  bool _isExerciseTimerRunning = false;

  // Data to save
  final List<Map<String, dynamic>> _completedSessionData = [];

  // Web Companion Sync
  StreamSubscription? _companionSubscription;
  int _liveReps = 0;
  String _liveFeedback = "";

  String getGlbPathForExercise(String exerciseName) {
    final name = exerciseName.toLowerCase();
    if (name.contains('squat')) return 'assets/models/squats.glb';
    if (name.contains('jump')) return 'assets/models/jumping_jacks.glb';
    if (name.contains('push')) return 'assets/models/pushup.glb';
    if (name.contains('plank')) return 'assets/models/plank.glb';
    if (name.contains('curl')) return 'assets/models/bicep_curl.glb';
    if (name.contains('sit') || name.contains('crunch'))
      return 'assets/models/sit_up.glb';
    if (name.contains('knee') || name.contains('run'))
      return 'assets/models/running.glb';
    if (name.contains('burpee')) return 'assets/models/burpee.glb';
    return 'assets/models/cheer.glb'; // Fallback
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    int maxSets = 0;
    for (var act in widget.activities) {
      if ((act.sets ?? 1) > maxSets) {
        maxSets = act.sets ?? 1;
      }
    }

    for (int s = 0; s < maxSets; s++) {
      for (int i = 0; i < widget.activities.length; i++) {
        final act = widget.activities[i];
        int actSets = act.sets ?? 1;
        if (s < actSets) {
          final ex = widget.allExercises.firstWhere(
            (e) => e.id == act.exerciseId,
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
          _steps.add(_WorkoutStep(act, ex, s, actSets, i));
        }
      }
    }

    _startWorkoutTimer();
    _initCurrentActivity();
    _startCompanionListener();
  }

  void _showHelpSheet(ExerciseModel ex) {
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
                      const SizedBox(height: 24),
                      const Text(
                        "How to perform",
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

  void _startCompanionListener() {
    final sessionId = ref.read(webCompanionSessionProvider);
    if (sessionId != null) {
      _companionSubscription = ref
          .read(webCompanionServiceProvider)
          .listenToSession(sessionId)
          .listen((doc) {
            if (doc.exists && doc.data() != null) {
              final data = doc.data() as Map<String, dynamic>;
              final reps = data['currentReps'] ?? 0;
              final feedback = data['formFeedback'] ?? "";

              if (reps != _liveReps || feedback != _liveFeedback) {
                setState(() {
                  _liveReps = reps;
                  _liveFeedback = feedback;
                });
              }
            }
          });
    }
  }

  void _initCurrentActivity() {
    if (_steps.isEmpty) return;
    final step = _steps[_currentStepIndex];
    final activity = step.activity;

    _liveReps = 0;
    _liveFeedback = "";

    // If duration based
    if (activity.durationSeconds != null && activity.durationSeconds! > 0) {
      _remainingSeconds = activity.durationSeconds!;
      _isExerciseTimerRunning = false;
      _exerciseTimer?.cancel();
    }

    // Sync with Web Companion
    final sessionId = ref.read(webCompanionSessionProvider);
    if (sessionId != null) {
      ref
          .read(webCompanionServiceProvider)
          .updateLiveSession(sessionId, activity, step.exercise);
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
        }
      });
    }
    setState(() {
      _isExerciseTimerRunning = !_isExerciseTimerRunning;
    });
  }

  bool get _isCurrentExerciseComplete {
    if (_steps.isEmpty) return true;
    final step = _steps[_currentStepIndex];
    if (_isExerciseTimerRunning ||
        (_remainingSeconds > 0 &&
            step.activity.durationSeconds != null &&
            step.activity.durationSeconds! > 0)) {
      // If duration based, timer must be 0
      return _remainingSeconds == 0;
    } else {
      // If reps based, single set is done manually by pressing Next
      return true;
    }
  }

  void _skipExercise() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Skip Exercise",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Why are you skipping this exercise?",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                _buildSkipReasonTile("Too Heavy"),
                _buildSkipReasonTile("Too Tired"),
                _buildSkipReasonTile("Pain or Injury"),
                _buildSkipReasonTile("No Equipment"),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkipReasonTile(String reason) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(reason, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: () {
        Navigator.pop(context); // Close bottom sheet
        _processSkip(reason);
      },
    );
  }

  void _processSkip(String reason) {
    if (_steps.isEmpty) return;
    final step = _steps[_currentStepIndex];
    final activity = step.activity;
    final exercise = step.exercise;

    // Save as skipped
    _completedSessionData.add({
      'exerciseId': activity.exerciseId,
      'name': exercise.name,
      'setsCompleted': 0,
      'totalSets': 1, // Single flattened set
      'skipped': true,
      'skipReason': reason,
      'notes': activity.notes,
    });

    if (_currentStepIndex < _steps.length - 1) {
      // Don't show rest overlay if skipping, just move on
      setState(() {
        _currentStepIndex++;
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

  void _nextExercise() {
    if (!_isCurrentExerciseComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Complete all sets before moving on!")),
      );
      return;
    }

    if (_steps.isEmpty) return;
    final step = _steps[_currentStepIndex];
    final activity = step.activity;
    final exercise = step.exercise;

    // Save data
    _completedSessionData.add({
      'exerciseId': activity.exerciseId,
      'name': exercise.name,
      'setsCompleted': 1,
      'totalSets': 1,
      'notes': activity.notes,
    });

    if (_currentStepIndex < _steps.length - 1) {
      _showRestOverlay();
    } else {
      _finishWorkout();
    }
  }

  void _showRestOverlay({bool isBetweenSets = false}) {
    int restSeconds = 30; // Default 30 seconds
    Timer? restTimer;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            if (restTimer == null) {
              restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
                if (restSeconds > 0) {
                  setStateDialog(() {
                    restSeconds--;
                  });
                } else {
                  timer.cancel();
                  if (context.mounted) Navigator.pop(context); // Close dialog
                }
              });
            }

            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: const Text(
                "Take a Rest",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(restSeconds),
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      color: Color(0xFFFF6B6B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      setStateDialog(() {
                        restSeconds += 30;
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Add 30s"),
                  ),
                ],
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                TextButton(
                  onPressed: () {
                    restTimer?.cancel();
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Skip Rest",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      // When dialog closes (timer finished or skipped), move to next exercise IF not between sets
      restTimer?.cancel();
      if (mounted && !isBetweenSets) {
        setState(() {
          _currentStepIndex++;
          _initCurrentActivity();
        });
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _finishWorkout() async {
    _workoutTimer?.cancel();
    _exerciseTimer?.cancel();

    final sessionId = ref.read(webCompanionSessionProvider);
    if (sessionId != null) {
      ref.read(webCompanionServiceProvider).endLiveSession(sessionId);
    }

    // Navigate to Appraisal Screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => WorkoutAppraisalScreen(
          durationSeconds: _elapsedSeconds,
          exerciseData: _completedSessionData,
          workoutName: widget.workoutTitle,
          pathNodeId: widget.pathNodeId,
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
            onPressed: () {
              Navigator.pop(context, 'discard');
            },
            child: const Text(
              "Discard (Delete)",
              style: TextStyle(color: Colors.red),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, 'finish');
            },
            child: const Text("Finish Early (Save)"),
          ),
        ],
      ),
    );

    if (result == 'discard') {
      if (mounted) Navigator.of(context).pop();
      return false;
    }
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

  String _getSetProgressText(int targetReps) {
    if (_liveReps > 0 && targetReps > 0) {
      int activeReps = _liveReps;
      if (activeReps > targetReps) activeReps = targetReps;
      return "$activeReps / $targetReps reps";
    }
    return "$targetReps reps";
  }

  @override
  void dispose() {
    _workoutTimer?.cancel();
    _exerciseTimer?.cancel();
    _companionSubscription?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_steps.isEmpty)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final totalSteps = _steps.length;
    final step = _steps[_currentStepIndex];
    final activity = step.activity;
    final currentExercise = step.exercise;
    final isDuration =
        activity.durationSeconds != null && activity.durationSeconds! > 0;

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
                  value: (_currentStepIndex + 1) / totalSteps,
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
                  // We use _currentStepIndex state for logic, this builder is just for slide transition
                  if (index != _currentStepIndex) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // 3D Model Viewer Placeholder
                        Container(
                          height: 180,
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
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: ModelViewer(
                                  src: getGlbPathForExercise(
                                    currentExercise.name,
                                  ),
                                  alt: currentExercise.name,
                                  autoPlay: true,
                                  autoRotate: false,
                                  cameraControls: true,
                                  disableZoom: true,
                                  backgroundColor: Colors.transparent,
                                ),
                              ),
                              if (_liveFeedback.isNotEmpty)
                                Positioned(
                                  bottom: 16,
                                  left: 16,
                                  right: 16,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.computer,
                                          color: Colors.greenAccent,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _liveFeedback,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "$_liveReps",
                                          style: const TextStyle(
                                            color: Colors.greenAccent,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        currentExercise.name,
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.help_outline,
                                        color: Color(0xFFFF6B6B),
                                      ),
                                      onPressed: () =>
                                          _showHelpSheet(currentExercise),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                if (activity.notes != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withValues(
                                        alpha: 0.1,
                                      ),
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

                                const SizedBox(height: 24),

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
                                      _isExerciseTimerRunning
                                          ? "Pause"
                                          : "Start",
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
                                  // Simplified Reps display
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 24,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: Colors.grey[200]!,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Set ${step.setIndex + 1} of ${step.totalSets}",
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _getSetProgressText(
                                            activity.reps ?? 12,
                                          ),
                                          style: const TextStyle(
                                            fontSize: 48,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF212121),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: _isCurrentExerciseComplete
                      ? _nextExercise
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Complete all sets to unlock the next exercise.",
                              ),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isCurrentExerciseComplete
                        ? const Color(0xFF212121)
                        : Colors.grey[300],
                    foregroundColor: _isCurrentExerciseComplete
                        ? Colors.white
                        : Colors.grey[600],
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentStepIndex < totalSteps - 1
                            ? "Complete Set"
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
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _skipExercise,
                  child: const Text(
                    "Skip this Exercise",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
