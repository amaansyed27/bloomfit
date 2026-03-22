import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/spring_button.dart';
import '../../data/auth_repository.dart';
import '../../../onboarding/presentation/onboarding_screen.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    // Auto-scroll from Welcome (Page 0) to Features (Page 1) after 2.5 seconds
    _autoScrollTimer = Timer(const Duration(milliseconds: 2500), () {
      if (_pageController.hasClients && _currentPage == 0) {
        _pageController.animateToPage(
          1,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _features = [
    {
      "type": "welcome",
      "title": "Welcome to\nBloomFit",
      "subtitle": "Your personal AI fitness companion.",
      "image": "assets/logo/logo_transparent_medium.png",
      "color": const Color(0xFFFF6B6B),
      "bg": Colors.white,
    },
    {
      "type": "feature",
      "title": "Tailored Workouts",
      "subtitle": "Plans that adapt to your goals and pace.",
      "icon": Icons
          .fitness_center_rounded, // Changed to Icon for consistency if image fails, or use image if available
      "bg": const Color(0xFFFFF0F0),
      "color": const Color(0xFFFF6B6B),
    },
    {
      "type": "feature",
      "title": "Smart Tracking",
      "subtitle": "Monitor your progress with detailed analytics.",
      "icon": Icons.show_chart_rounded,
      "color": const Color(0xFF4ECDC4),
      "bg": const Color(0xFFE0F7FA),
    },
    {
      "type": "feature",
      "title": "Gamified Fitness",
      "subtitle": "Earn XP, maintain streaks, and level up!",
      "icon": Icons.emoji_events_rounded,
      "color": const Color(0xFFFFD93D),
      "bg": const Color(0xFFFFFDE7),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _features.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildPage(_features[index]);
                },
              ),
            ),

            // Bottom Section with Indicators and Buttons
            Container(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Page Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _features.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? const Color(0xFFFF6B6B)
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Primary Action: Get Started
                  SpringButton(
                    onTap: _navigateToOnboarding,
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B6B),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFFFF6B6B,
                            ).withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          "Get Started",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Secondary Action: I have an account
                  SpringButton(
                    onTap: () async {
                      try {
                        await ref
                            .read(authRepositoryProvider)
                            .signInWithGoogle();
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey[200]!, width: 2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Ideally replace with a proper Google Logo asset
                          const Icon(
                            Icons.g_mobiledata,
                            size: 28,
                            color: Colors.black87,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "I have an account",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(Map<String, dynamic> item) {
    final isWelcome = item['type'] == 'welcome';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image / Icon
          if (isWelcome)
            Hero(
              tag: 'app_logo',
              child: Image.asset(
                item['image'],
                height: 300, // Larger logic for Welcome Screen
                fit: BoxFit.contain,
              ),
            )
          else if (item.containsKey('image'))
            Image.asset(
              item['image'],
              height: 250,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => _buildFallbackIcon(item),
            )
          else
            _buildFallbackIcon(item),

          const SizedBox(height: 48),

          // Title
          Text(
            item['title'],
            style: TextStyle(
              fontSize: isWelcome ? 36 : 28, // Larger title for Welcome
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
              height: 1.2,
              letterSpacing: isWelcome ? -0.5 : 0,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Subtitle
          Text(
            item['subtitle'],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackIcon(Map<String, dynamic> item) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(color: item['bg'], shape: BoxShape.circle),
      child: Icon(item['icon'] ?? Icons.star, size: 80, color: item['color']),
    );
  }

  void _navigateToOnboarding() {
    // Navigate directly to Onboarding
    // We will handle the "Not Authenticated" state in the Onboarding Finalize step if needed
    // or just allow the user to explore and sign up later.
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const OnboardingScreenWrapper()));
  }
}

class OnboardingScreenWrapper extends ConsumerWidget {
  const OnboardingScreenWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const OnboardingScreen();
  }
}
