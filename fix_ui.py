import re

with open('lib/features/workouts/presentation/pages/active_workout_session.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Add _WorkoutStep class
content = content.replace(
    'class _ActiveWorkoutSessionState extends ConsumerState<ActiveWorkoutSession> {',
    '''class _WorkoutStep {
  final WorkoutActivity activity;
  final ExerciseModel exercise;
  final int setIndex;
  final int totalSets;
  final int originalActivityIndex;
  _WorkoutStep(this.activity, this.exercise, this.setIndex, this.totalSets, this.originalActivityIndex);
}

class _ActiveWorkoutSessionState extends ConsumerState<ActiveWorkoutSession> {'''
)

# 2. State variables
content = re.sub(
    r'  late PageController _pageController;\n  int _currentExerciseIndex = 0;\n\n  // Workout Timer',
    '''  late PageController _pageController;
  List<_WorkoutStep> _steps = [];
  int _currentStepIndex = 0;

  // Workout Timer''',
    content
)

content = content.replace('  List<bool> _completedSets = [];\n', '')

# 3. initState
content = re.sub(
    r'  @override\n  void initState\(\) \{[\s\S]*?  \}\n',
    '''  @override
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
          final ex = widget.allExercises.firstWhere((e) => e.id == act.exerciseId, orElse: () => ExerciseModel.empty());
          _steps.add(_WorkoutStep(act, ex, s, actSets, i));
        }
      }
    }

    _startWorkoutTimer();
    _initCurrentActivity();
    _startCompanionListener();
  }\n''',
    content
)

# 4. _initCurrentActivity
content = re.sub(
    r'  void _initCurrentActivity\(\) \{[\s\S]*?  \}\n',
    '''  void _initCurrentActivity() {
    if (_steps.isEmpty) return;
    final step = _steps[_currentStepIndex];
    final activity = step.activity;
    
    _liveReps = 0;
    _liveFeedback = "";

    if (activity.durationSeconds != null && activity.durationSeconds! > 0) {
      _remainingSeconds = activity.durationSeconds!;
      _isExerciseTimerRunning = false;
      if (_exerciseTimer != null) _exerciseTimer!.cancel();
    }

    final sessionId = ref.read(webCompanionSessionProvider);
    if (sessionId != null) {
      ref.read(webCompanionServiceProvider).updateLiveSession(sessionId, activity, step.exercise);
    }
  }\n''',
    content
)

# 5. Companion listener auto-complete removal
content = re.sub(
    r'                // Auto complete sets based on reps[\s\S]*?\}\n              \}\n            \}\n          \}\);\n    \}',
    '''              }
            }
          });
    }''',
    content
)

# 6. toggle exercise timer completion removal
content = re.sub(
    r'          // Auto-complete first set if it.s a duration exercise\n          if \(_completedSets\.isNotEmpty\) \{\n            setState\(\(\) \{\n              _completedSets\[0\] = true;\n            \}\);\n          \}',
    '',
    content
)

# 7. _isCurrentExerciseComplete
content = re.sub(
    r'  bool get _isCurrentExerciseComplete \{[\s\S]*?  \}\n',
    '''  bool get _isCurrentExerciseComplete {
    if (_steps.isEmpty) return true;
    final step = _steps[_currentStepIndex];
    if (_isExerciseTimerRunning || (_remainingSeconds > 0 && step.activity.durationSeconds != null && step.activity.durationSeconds! > 0)) {
      return _remainingSeconds == 0;
    } else {
      return true;
    }
  }\n''',
    content
)

# 8. Skip / Next indices
content = content.replace('_currentExerciseIndex', '_currentStepIndex')
content = content.replace('widget.activities.length', '_steps.length')

content = re.sub(
    r'    final activity = widget\.activities\[_currentStepIndex\];[\s\S]*?    \);\n',
    '''    final step = _steps[_currentStepIndex];
    final activity = step.activity;
    final exercise = step.exercise;\n''',
    content,
    count=2
)

content = re.sub(
    r"    // Save as skipped\n    _completedSessionData\.add\(\{[\s\S]*?\}\);\n",
    '''    // Save as skipped
    _completedSessionData.add({
      'exerciseId': activity.exerciseId,
      'name': exercise.name,
      'setsCompleted': 0,
      'totalSets': 1,
      'skipped': true,
      'skipReason': reason,
      'notes': activity.notes,
    });\n''',
    content
)

content = re.sub(
    r"    // Save data\n    _completedSessionData\.add\(\{[\s\S]*?\}\);\n",
    '''    // Save data
    _completedSessionData.add({
      'exerciseId': activity.exerciseId,
      'name': exercise.name,
      'setsCompleted': 1,
      'totalSets': 1,
      'notes': activity.notes,
    });\n''',
    content
)

content = re.sub(
    r'  String _getSetProgressText\(int setIndex, int targetReps\) \{[\s\S]*?\}\n',
    '''  String _getSetProgressText(int targetReps) {
    if (_liveReps > 0) {
      int displayReps = _liveReps;
      if (displayReps > targetReps) displayReps = targetReps;
      return "${displayReps} / ${targetReps} Reps";
    }
    return "${targetReps} Reps";
  }\n''',
    content
)

# 9. Build method start
content = re.sub(
    r'  @override\n  Widget build\(BuildContext context\) \{[\s\S]*?    final isDuration =[\s\S]*?activity\.durationSeconds! > 0;\n\n    final currentExercise =[\s\S]*?\}\);\n',
    '''  @override
  Widget build(BuildContext context) {
    if (_steps.isEmpty) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final totalSteps = _steps.length;
    final step = _steps[_currentStepIndex];
    final activity = step.activity;
    final currentExercise = step.exercise;
    final isDuration = activity.durationSeconds != null && activity.durationSeconds! > 0;\n''',
    content
)

# 10. Replace Sets UI
sets_start = content.find('                                ] else ...[')
sets_end = content.find('                                const SizedBox(height: 24),\n                              ],\n                            ),\n                          ),\n                        ),')

if sets_start != -1 and sets_end != -1:
    to_replace = content[sets_start:sets_end]
    replacement = '''                                ] else ...[
                                  // Simplified Reps display
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 24),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(color: Colors.grey[200]!),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
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
                                          _getSetProgressText(activity.reps ?? 12),
                                          style: const TextStyle(
                                            fontSize: 48,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF212121),
                                          ),
                                        ),
  
