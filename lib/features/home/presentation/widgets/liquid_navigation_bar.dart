import 'package:flutter/material.dart';

class LiquidNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const LiquidNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Floating Pill Design
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35), // Pill shape
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavBarIcon(
              icon: Icons.map_rounded,
              index: 0,
              isSelected: currentIndex == 0,
              onTap: onTap,
            ),
            _NavBarIcon(
              icon: Icons.fitness_center_rounded, // Workouts
              index: 1,
              isSelected: currentIndex == 1,
              onTap: onTap,
            ),
            _NavBarIcon(
              icon: Icons.people_rounded, // Social
              index: 2,
              isSelected: currentIndex == 2,
              onTap: onTap,
            ),
            _NavBarIcon(
              icon: Icons.person_rounded,
              index: 3,
              isSelected: currentIndex == 3,
              onTap: onTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBarIcon extends StatelessWidget {
  final IconData icon;
  final int index;
  final bool isSelected;
  final Function(int) onTap;

  const _NavBarIcon({
    required this.icon,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        width: isSelected ? 50 : 40,
        height: isSelected ? 50 : 40,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFF6B6B)
              : Colors.transparent, // Pastel Primary
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected
              ? Colors.white
              : const Color(0xFF9E9E9E), // Grey 500
          size: 24,
        ),
      ),
    );
  }
}
