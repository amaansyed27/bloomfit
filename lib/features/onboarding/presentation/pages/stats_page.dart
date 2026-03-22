import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:numberpicker/numberpicker.dart';
import '../onboarding_controller.dart';
import '../../domain/user_profile.dart';

class OnboardingStatsPage extends ConsumerWidget {
  const OnboardingStatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Tell us about yourself",
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Gender Selection
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _GenderButton(
                icon: Icons.male,
                label: "Male",
                isSelected: state.gender == Gender.male,
                onTap: () => notifier.setStats(gender: Gender.male),
              ),
              const SizedBox(width: 16),
              _GenderButton(
                icon: Icons.female,
                label: "Female",
                isSelected: state.gender == Gender.female,
                onTap: () => notifier.setStats(gender: Gender.female),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Age Picker
          Text(
            "Age: ${state.age ?? 25}",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          NumberPicker(
            value: state.age ?? 25,
            minValue: 10,
            maxValue: 100,
            onChanged: (value) => notifier.setStats(age: value),
            axis: Axis.horizontal,
          ),
        ],
      ),
    );
  }
}

class _GenderButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
