import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/liquid_card.dart';
import '../onboarding_controller.dart';

class OnboardingDurationPage extends ConsumerWidget {
  const OnboardingDurationPage({super.key});

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
            "How long should this plan last?",
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          LiquidCard(
            title: "1 Month (Quick Start)",
            icon: Icons.flash_on,
            isSelected: state.planDurationMonths == 1,
            onTap: () => notifier.setPlanDuration(1),
          ),
          const SizedBox(height: 16),
          LiquidCard(
            title: "2 Months (Balanced)",
            icon: Icons.balance,
            isSelected: state.planDurationMonths == 2,
            onTap: () => notifier.setPlanDuration(2),
          ),
          const SizedBox(height: 16),
          LiquidCard(
            title: "3 Months (Transformation)",
            icon: Icons.auto_graph,
            isSelected: state.planDurationMonths == 3,
            onTap: () => notifier.setPlanDuration(3),
          ),
        ],
      ),
    );
  }
}
