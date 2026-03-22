import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'onboarding_controller.dart';

import '../../../core/widgets/spring_button.dart';
import 'pages/goal_page.dart';
import 'pages/stats_page.dart';
import 'pages/experience_page.dart';
import 'pages/logistics_page.dart';
import 'pages/duration_page.dart';
import 'pages/finalize_page.dart';
import '../../authentication/presentation/pages/sign_up_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 600),
      curve: Curves.fastLinearToSlowEaseIn, // "Liquid" feel
    );
    ref.read(onboardingProvider.notifier).nextStep();
  }

  void _prevPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 600),
      curve: Curves.fastLinearToSlowEaseIn,
    );
    ref.read(onboardingProvider.notifier).previousStep();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: LinearProgressIndicator(
                value: (state.currentStep + 1) / 6,
                backgroundColor: const Color(0xFFEEEEEE),
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(10),
                minHeight: 8,
              ),
            ),

            // Content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics:
                    const NeverScrollableScrollPhysics(), // Disable swipe to enforce flow
                children: [
                  _buildGoalSection(),
                  _buildStatsSection(),
                  _buildExperienceSection(),
                  _buildLogisticsSection(),
                  _buildDurationSection(),
                  _buildFinalizeSection(),
                ],
              ),
            ),

            // Controls
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (state.currentStep > 0)
                    TextButton(
                      onPressed: _prevPage,
                      child: Text(
                        'Back',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    )
                  else
                    const SizedBox.shrink(),

                  if (state.currentStep == 5) ...[
                    // Finalize Step
                    if (state.isSubmitting)
                      const CircularProgressIndicator()
                    else
                      SpringButton(
                        onTap: _goToSignUp,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48, // Wider button
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B6B), // Coral Red
                            borderRadius: BorderRadius.circular(
                              16,
                            ), // Match Welcome Screen
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFFFF6B6B,
                                ).withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Text(
                            'Start Journey',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                  ] else ...[
                    // Normal Step
                    SpringButton(
                      onTap: _nextPage,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B6B), // Coral Red
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFFFF6B6B,
                              ).withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Next',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goToSignUp() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SignUpScreen()));
  }

  Widget _buildGoalSection() => const OnboardingGoalPage();
  Widget _buildStatsSection() => const OnboardingStatsPage();
  Widget _buildExperienceSection() => const OnboardingExperiencePage();
  Widget _buildLogisticsSection() => const OnboardingLogisticsPage();
  Widget _buildDurationSection() => const OnboardingDurationPage();
  Widget _buildFinalizeSection() => const OnboardingFinalizePage();
}
