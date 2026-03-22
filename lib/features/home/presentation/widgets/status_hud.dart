import 'package:flutter/material.dart';

class StatusHUD extends StatelessWidget {
  const StatusHUD({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: User Profile & Level
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F5F5), // Light Grey
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 20,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Lvl 5",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF212121), // High Contrast
                    ),
                  ),
                ],
              ),

              // Divider
              Container(
                width: 1,
                height: 20,
                color: Colors.grey[200],
                margin: const EdgeInsets.symmetric(horizontal: 10),
              ),

              // Right: Streak & XP
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.local_fire_department_rounded,
                    color: Color(0xFFFF6B6B),
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    "12",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.bolt_rounded,
                    color: Color(0xFFFFD93D),
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    "1450",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF212121),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
