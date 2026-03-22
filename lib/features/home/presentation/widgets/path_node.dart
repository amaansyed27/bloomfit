import 'package:flutter/material.dart';

import '../../domain/path_models.dart';

class PathNode extends StatelessWidget {
  final PathNodeState state;
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const PathNode({
    super.key,
    required this.state,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: state == PathNodeState.locked ? null : onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Node Circle
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: state == PathNodeState.active ? 80 : 64,
            height: state == PathNodeState.active ? 80 : 64,
            padding: const EdgeInsets.all(5), // Inner spacing for ring effect
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getInnerColor(),
              ),
              child: Icon(
                state == PathNodeState.done ? Icons.check : icon,
                color: _getIconColor(),
                size: state == PathNodeState.active ? 32 : 24,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Title Label
          if (state != PathNodeState.locked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getInnerColor() {
    switch (state) {
      case PathNodeState.done:
        return const Color(0xFFE8F5E9); // Pastel Green
      case PathNodeState.active:
        return const Color(0xFFFFEBEE); // Pastel Red
      case PathNodeState.locked:
        return const Color(0xFFF5F5F5); // Grey 100
    }
  }

  Color _getIconColor() {
    switch (state) {
      case PathNodeState.done:
        return Colors.green;
      case PathNodeState.active:
        return const Color(0xFFFF6B6B);
      case PathNodeState.locked:
        return Colors.grey[400]!;
    }
  }
}
