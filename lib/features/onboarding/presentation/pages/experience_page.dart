import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/liquid_card.dart';
import '../onboarding_controller.dart';
import '../../domain/user_profile.dart';

class OnboardingExperiencePage extends ConsumerWidget {
  const OnboardingExperiencePage({super.key});

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
            "What's your experience level?",
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          LiquidCard(
            title: "Rookie",
            subtitle: "I'm just starting out",
            icon: Icons.star_border,
            isSelected: state.experienceLevel == ExperienceLevel.rookie,
            onTap: () => notifier.setExperience(ExperienceLevel.rookie),
          ),
          const SizedBox(height: 16),
          LiquidCard(
            title: "Casual",
            subtitle: "I workout sometimes",
            icon: Icons.star_half,
            isSelected: state.experienceLevel == ExperienceLevel.casual,
            onTap: () => notifier.setExperience(ExperienceLevel.casual),
          ),
          const SizedBox(height: 16),
          LiquidCard(
            title: "Pro",
            subtitle: "I'm a gym rat",
            icon: Icons.star,
            isSelected: state.experienceLevel == ExperienceLevel.pro,
            onTap: () => notifier.setExperience(ExperienceLevel.pro),
          ),
        ],
      ),
    );
  }
}
