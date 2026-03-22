import 'workout_activity.dart';

enum PathNodeState { locked, active, done }

enum NodeType { strength, cardio, yoga, rest }

class PathNodeData {
  final String id;
  final String title;
  final NodeType type;
  final PathNodeState state;
  final int position;
  final List<WorkoutActivity> activities; // Updated to use WorkoutActivity

  PathNodeData({
    required this.id,
    required this.title,
    required this.type,
    required this.state,
    required this.position,
    this.activities = const [],
  });
}
