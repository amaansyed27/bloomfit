import 'package:bloomfit/features/home/domain/path_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/workouts/data/exercise_repository.dart';
import '../../../workouts/presentation/pages/active_workout_overview.dart';
import 'package:flutter_animate/flutter_animate.dart';

class VerticalTimelinePath extends ConsumerWidget {
  final List<PathNodeData> nodes;

  const VerticalTimelinePath({super.key, required this.nodes});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch exercises to allow navigation
    final exercisesAsync = ref.watch(exercisesStreamProvider);

    return ListView.builder(
      padding: const EdgeInsets.only(top: 20, bottom: 100, left: 20, right: 20),
      itemCount: nodes.length,
      itemBuilder: (context, index) {
        final node = nodes[index];
        final isLast = index == nodes.length - 1;
        final isFirst = index == 0;

        return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Timeline Line & Node
                  SizedBox(
                    width: 40,
                    child: Column(
                      children: [
                        // Top Line
                        Expanded(
                          child: Container(
                            width: 3,
                            decoration: BoxDecoration(
                              color: isFirst
                                  ? Colors.transparent
                                  : (node.state == PathNodeState.done ||
                                        node.state == PathNodeState.active)
                                  ? Colors.green
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        // Node Indicator
                        Container(
                          width: 28, // Slightly larger
                          height: 28,
                          decoration: BoxDecoration(
                            color: _getNodeColor(node.state),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2.5,
                            ), // Thicker border
                            boxShadow: [
                              if (node.state == PathNodeState.active)
                                BoxShadow(
                                  color: const Color(
                                    0xFFFF6B6B,
                                  ).withValues(alpha: 0.5),
                                  blurRadius: 12,
                                  spreadRadius: 3,
                                ),
                              if (node.state == PathNodeState.done)
                                BoxShadow(
                                  color: Colors.green.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              _getNodeIcon(node.state, node.type),
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        // Bottom Line
                        Expanded(
                          child: Container(
                            width: 3,
                            decoration: BoxDecoration(
                              color: isLast
                                  ? Colors.transparent
                                  : (node.state == PathNodeState.done)
                                  ? Colors.green
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  // 2. Card Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            if (node.state == PathNodeState.locked) return;

                            if (node.type == NodeType.rest) {
                              showDialog(
                                context: context,
                                builder: (c) => AlertDialog(
                                  icon: const Icon(
                                    Icons.nightlight_round,
                                    size: 48,
                                    color: Colors.blueGrey,
                                  ),
                                  title: const Text("Rest Day"),
                                  content: const Text(
                                    "Take today to recover! Light stretching or a walk is recommended.",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(c),
                                      child: const Text("Enjoy"),
                                    ),
                                  ],
                                ),
                              );
                              return;
                            }

                            // Navigation Logic
                            exercisesAsync.whenData((allExercises) {
                              if (node.activities.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "No activities found for this day. Try 'Repair App Data' in Profile.",
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    margin: EdgeInsets.only(
                                      bottom: 80,
                                      left: 16,
                                      right: 16,
                                    ),
                                  ),
                                );
                              } else {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => ActiveWorkoutOverview(
                                        activities: node.activities,
                                        allExercises: allExercises,
                                        workoutTitle: node.title,
                                        pathNodeId: node.id,
                                      ),
                                    ),
                                  );
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: node.state == PathNodeState.active
                                  ? Border.all(
                                      color: const Color(0xFFFF6B6B),
                                      width: 2,
                                    )
                                  : Border.all(color: Colors.transparent),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Type Icon
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _getTypeColor(
                                      node.type,
                                    ).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    _getTypeIcon(node.type),
                                    color: _getTypeColor(node.type),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Text Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        node.title,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              node.state == PathNodeState.locked
                                              ? Colors.grey
                                              : const Color(0xFF212121),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _getStatusText(node.state),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              node.state == PathNodeState.active
                                              ? const Color(0xFFFF6B6B)
                                              : Colors.grey,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (node.type == NodeType.rest)
                                        Text(
                                          "Active Recovery",
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.blueGrey[400],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                // Right Arrow
                                if (node.state != PathNodeState.locked)
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.chevron_right_rounded,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
            .animate()
            .fadeIn(duration: 400.ms, delay: (index * 50).ms)
            .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad);
      },
    );
  }

  Color _getNodeColor(PathNodeState state) {
    switch (state) {
      case PathNodeState.done:
        return Colors.green;
      case PathNodeState.active:
        return const Color(0xFFFF6B6B);
      case PathNodeState.locked:
        return Colors.grey[300]!;
    }
  }

  IconData _getNodeIcon(PathNodeState state, NodeType type) {
    if (state == PathNodeState.done) return Icons.check;
    if (state == PathNodeState.locked) return Icons.lock;
    if (type == NodeType.rest) return Icons.nightlight_round;
    return Icons.circle; // Active dot
  }

  Color _getTypeColor(NodeType type) {
    switch (type) {
      case NodeType.strength:
        return const Color(0xFF5C6BC0);
      case NodeType.cardio:
        return const Color(0xFFFF6B6B);
      case NodeType.yoga:
        return const Color(0xFFFFB74D);
      case NodeType.rest:
        return const Color(0xFF90A4AE); // Blue Grey for Rest
    }
  }

  IconData _getTypeIcon(NodeType type) {
    switch (type) {
      case NodeType.strength:
        return Icons.fitness_center;
      case NodeType.cardio:
        return Icons.local_fire_department;
      case NodeType.yoga:
        return Icons.self_improvement;
      case NodeType.rest:
        return Icons.bed_rounded;
    }
  }

  String _getStatusText(PathNodeState state) {
    switch (state) {
      case PathNodeState.done:
        return "Completed";
      case PathNodeState.active:
        return "In Progress";
      case PathNodeState.locked:
        return "Locked";
    }
  }
}
