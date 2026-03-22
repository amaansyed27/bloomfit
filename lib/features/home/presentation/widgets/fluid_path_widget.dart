import 'package:bloomfit/features/home/domain/path_models.dart';
import 'package:flutter/material.dart';
import 'path_node.dart';
import 'dart:math' as math;

class FluidPathWidget extends StatefulWidget {
  final List<PathNodeData> nodes;

  const FluidPathWidget({super.key, required this.nodes});

  @override
  State<FluidPathWidget> createState() => _FluidPathWidgetState();
}

class _FluidPathWidgetState extends State<FluidPathWidget> {
  final double _nodeSpacing = 120.0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Scroll to active node after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToActiveNode();
    });
  }

  void _scrollToActiveNode() {
    final activeIndex = widget.nodes.indexWhere(
      (node) => node.state == PathNodeState.active,
    );
    if (activeIndex != -1 && _scrollController.hasClients) {
      final double targetOffset =
          (activeIndex * _nodeSpacing) -
          (MediaQuery.of(context).size.height / 2) +
          100;
      _scrollController.animateTo(
        targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double totalHeight =
        widget.nodes.length * _nodeSpacing + 200; // Extra padding

    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      child: SizedBox(
        height: totalHeight,
        child: Stack(
          children: [
            // 1. The Path (Line)
            Positioned.fill(
              child: CustomPaint(
                painter: _PathPainter(
                  nodes: widget.nodes,
                  nodeSpacing: _nodeSpacing,
                ),
              ),
            ),

            // 2. The Nodes (Interactive Widgets)
            ...List.generate(widget.nodes.length, (index) {
              final node = widget.nodes[index];
              final Offset pos = _calculateNodePosition(
                index,
                MediaQuery.of(context).size.width,
              );

              return Positioned(
                left: pos.dx - 40, // Center the 80x80 node (approx)
                top: pos.dy - 40,
                child: PathNode(
                  state: node.state,
                  title: node.title,
                  icon: _getIconForType(node.type),
                  onTap: () {
                    // print("Tapped node ${node.id}");
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Offset _calculateNodePosition(int index, double screenWidth) {
    final double centerX = screenWidth / 2;
    final double y =
        (index * _nodeSpacing) + 100.0; // Start with some top padding
    final double xOffset =
        100.0 * math.sin(index * 0.8); // Sine wave amplitude and frequency
    return Offset(centerX + xOffset, y);
  }

  IconData _getIconForType(NodeType type) {
    switch (type) {
      case NodeType.strength:
        return Icons.fitness_center;
      case NodeType.cardio:
        return Icons.directions_run;
      case NodeType.yoga:
        return Icons.self_improvement;
      case NodeType.rest:
        return Icons.nightlight_round;
    }
  }
}

class _PathPainter extends CustomPainter {
  final List<PathNodeData> nodes;
  final double nodeSpacing;

  _PathPainter({required this.nodes, required this.nodeSpacing});

  @override
  void paint(Canvas canvas, Size size) {
    if (nodes.isEmpty) return;

    // Pastel Gradient Shader
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final Gradient gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFFFFE0E0), // Pastel Pink
        const Color(0xFFE0F7FA), // Pastel Blue
      ],
    );

    Paint paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth =
          16.0 // Thick soft line
      ..strokeCap = StrokeCap.round;

    Path backgroundPath = Path();

    // Calculate points
    final List<Offset> points = List.generate(nodes.length, (index) {
      double width = size.width;
      double centerX = width / 2;
      double y = (index * nodeSpacing) + 100.0;
      double xOffset = 100.0 * math.sin(index * 0.8);
      return Offset(centerX + xOffset, y);
    });

    if (points.isEmpty) return;

    backgroundPath.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      Offset p1 = points[i];
      Offset p2 = points[i + 1];

      // Control points for cubic bezier to smooth out the sine wave connection
      // Vertical control points
      Offset c1 = Offset(p1.dx, p1.dy + nodeSpacing / 2);
      Offset c2 = Offset(p2.dx, p2.dy - nodeSpacing / 2);

      backgroundPath.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
    }

    canvas.drawPath(backgroundPath, paint);
  }

  @override
  bool shouldRepaint(covariant _PathPainter oldDelegate) {
    return oldDelegate.nodes != nodes;
  }
}
