import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/exercise_model.dart';
import 'package:bloomfit/features/home/domain/workout_activity.dart';
import 'workout_appraisal_screen.dart';
import '../../data/web_companion_provider.dart';
import '../../data/web_companion_service.dart';

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
  ConsumerState<ActiveWorkoutSession> createState() => _ActiveWorkoutSessionState();
}

class _ActiveWorkoutSessionState extends ConsumerState<ActiveWorkoutSession> {
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

  // Web Companion Sync
  StreamSubscription? _companionSubscription;
  int _liveReps = 0;
  String _liveFeedback = "";

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startWorkoutTimer();
    _initCurrentActivity();
    _startCompanionListener();
  }

  void _startCompanionListener() {
    final sessionId = ref.read(webCompanionSessionProvider);
    if (sessionId != null) {
      _companionSubscription = ref.read(webCompanionServiceProvider).listenToSession(sessionId).listen((doc) {
        if (doc.exists && doc.data() != null) {
          final data = doc.data() as Map<String, dynamic>;
          final reps = data['currentReps'] ?? 0;
          final feedback = data['formFeedback'] ?? "";
          
          if (reps != _liveReps || feedback != _liveFeedback) {
            setState(() {
              _liveReps = reps;
              _liveFeedback = feedback;
            });
            
            // Auto complete sets based on reps
            final activity = widget.activities[_currentExerciseIndex];
            final targetReps = activity.reps ?? 12;
            if (_liveReps > 0 && targetReps > 0) {
               // Calculate how many full sets are completed
               int completedSetsCount = _liveReps ~/ targetReps;
               setState(() {
                 for(int i = 0; i < _completedSets.length; i++) {
                   _completedSets[i] = i < completedSetsCount;
                 }
               });
            }
          }
        }
      });
    }
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

    // Sync with Web Companion
    final sessionId = ref.read(webCompanionSessionProvider);
    if (sessionId != null) {
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
      ref.read(webCompanionServiceProvider).updateLiveSession(sessionId, activity, exercise);
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

  bool get _isCurrentExerciseComplete {
    if (_isExerciseTimerRunning || _remainingSeconds > 0 && widget.activities[_currentExerciseIndex].durationSeconds != null) {
      // If duration based, timer must be 0
      return _remainingSeconds == 0;
    } else {
      // If reps based, all sets must be checked
      return !_completedSets.contains(false);
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
                const Text("Skip Exercise", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text("Why are you skipping this exercise?", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 24),
                _buildSkipReasonTile("Too Heavy"),
                _buildSkipReasonTile("Too Tired"),
                _buildSkipReasonTile("Pain or Injury"),
                _buildSkipReasonTile("No Equipment"),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildSkipReasonTile(String reason) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(reason, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {
        Navigator.pop(context); // Close bottom sheet
        _processSkip(reason);
      },
    );
  }

  void _processSkip(String reason) {
    final activity = widget.activities[_currentExerciseIndex];
    final exercise = widget.allExercises.firstWhere(
      (e) => e.id == activity.exerciseId,
      orElse: () => ExerciseModel(id: '?', name: 'Unknown', bodyPart: '', difficulty: '', instructions: [], imageUrl: '', equipment: ''),
    );

    // Save as skipped
    _completedSessionData.add({
      'exerciseId': activity.exerciseId,
      'name': exercise.name,
      'setsCompleted': 0,
      'totalSets': _completedSets.length, // or 1 if duration
      'skipped': true,
      'skipReason': reason,
      'notes': activity.notes,
    });

    if (_currentExerciseIndex < widget.activities.length - 1) {
      // Don't show rest overlay if skipping, just move on
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

  void _nextExercise() {
    if (!_isCurrentExerciseComplete) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text("Complete all sets before moving on!"))
       );
       return;
    }

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
                     setStateDialog(() { restSeconds--; });
                  } else {
                     timer.cancel();
                     if (context.mounted) Navigator.pop(context); // Close dialog
                  }
               });
            }

            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text("Take a Rest", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_formatTime(restSeconds), style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, fontFamily: 'monospace', color: Color(0xFFFF6B6B))),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                       setStateDialog(() { restSeconds += 30; });
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
                  child: const Text("Skip Rest", style: TextStyle(color: Colors.grey, fontSize: 16)),
                )
              ],
            );
          }
        );
      }
    ).then((_) {
       // When dialog closes (timer finished or skipped), move to next exercise IF not between sets
       restTimer?.cancel();
       if (mounted && !isBetweenSets) {
         setState(() {
           _currentExerciseIndex++;
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

  String _getSetProgressText(int setIndex, int targetReps) {
    if (_liveReps > 0 && targetReps > 0) {
      int completedSetsCount = _liveReps ~/ targetReps;
      if (setIndex < completedSetsCount) {
        return "$targetReps / $targetReps reps";
      } else if (setIndex == completedSetsCount) {
        int activeReps = _liveReps % targetReps;
        return "$activeReps / $targetReps reps";
      } else {
        return "0 / $targetReps reps";
      }
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
                  if (index != _currentExerciseIndex) {
                    return const SizedBox.shrink();
                  }

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
                          child: Stack(
                            children: [
                              if (currentExercise.imageUrl.isEmpty)
                                const Center(
                                  child: Icon(
                                    Icons.fitness_center,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                ),
                              if (_liveFeedback.isNotEmpty)
                                Positioned(
                                  bottom: 16,
                                  left: 16,
                                  right: 16,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.computer, color: Colors.greenAccent, size: 20),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _liveFeedback,
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Text(
                                          "$_liveReps",
                                          style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 20),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
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
                                    final isCurrentlyChecked = _completedSets[i];
                                    setState(() {
                                      _completedSets[i] = !isCurrentlyChecked;
                                    });
                                    
                                    // If we just checked it (and it's not the last set), trigger a set rest
                                    if (!isCurrentlyChecked && i < _completedSets.length - 1) {
                                       _showRestOverlay(isBetweenSets: true);
                                    }
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
                                              _getSetProgressText(i, activity.reps ?? 12),
                                              style: TextStyle(
                                                color: _completedSets[i] ? Colors.green[700] : Colors.grey[600],
                                                fontWeight: _completedSets[i] ? FontWeight.bold : FontWeight.normal,
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: _isCurrentExerciseComplete ? _nextExercise : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Complete all sets to unlock the next exercise."))
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isCurrentExerciseComplete ? const Color(0xFF212121) : Colors.grey[300],
                    foregroundColor: _isCurrentExerciseComplete ? Colors.white : Colors.grey[600],
                    minimumSize: const Size(double.infinity, 60),
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
