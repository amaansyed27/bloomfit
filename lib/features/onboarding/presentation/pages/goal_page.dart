import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/liquid_card.dart';
import '../onboarding_controller.dart';
import '../../domain/user_profile.dart'; // Import Goal enum

class OnboardingGoalPage extends ConsumerWidget {
  const OnboardingGoalPage({super.key});

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
            "What's your main goal?",
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          LiquidCard(
            title: "Weight Loss",
            icon: Icons.local_fire_department,
            isSelected: state.primaryGoal == Goal.weightLoss,
            onTap: () => notifier.setGoal(Goal.weightLoss),
          ),
          const SizedBox(height: 16),
          LiquidCard(
            title: "Build Muscle",
            icon: Icons.fitness_center,
            isSelected: state.primaryGoal == Goal.buildMuscle,
            onTap: () => notifier.setGoal(Goal.buildMuscle),
          ),
          const SizedBox(height: 16),
          LiquidCard(
            title: "Get Fitter",
            icon: Icons.directions_run,
            isSelected: state.primaryGoal == Goal.getFitter,
            onTap: () => notifier.setGoal(Goal.getFitter),
          ),
          const SizedBox(height: 16),
          LiquidCard(
            title: "Stress Relief",
            icon: Icons.self_improvement,
            isSelected: state.primaryGoal == Goal.stressRelief,
            onTap: () => notifier.setGoal(Goal.stressRelief),
          ),
        ],
      ),
    );
  }
}
