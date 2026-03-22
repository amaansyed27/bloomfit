import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:numberpicker/numberpicker.dart';
import '../onboarding_controller.dart';

class OnboardingLogisticsPage extends ConsumerWidget {
  const OnboardingLogisticsPage({super.key});

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
            "Logistics",
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          Text(
            "Days per week: ${state.daysPerWeek}",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          NumberPicker(
            value: state.daysPerWeek,
            minValue: 1,
            maxValue: 7,
            onChanged: (value) => notifier.setLogistics(days: value),
            axis: Axis.horizontal,
          ),

          const SizedBox(height: 32),

          Text(
            "Minutes per workout: ${state.durationMinutes}",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          NumberPicker(
            value: state.durationMinutes,
            minValue: 10,
            maxValue: 120,
            step: 5,
            onChanged: (value) => notifier.setLogistics(duration: value),
            axis: Axis.horizontal,
          ),
        ],
      ),
    );
  }
}
