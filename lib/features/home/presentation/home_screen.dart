import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../authentication/data/auth_repository.dart';
import '../../authentication/data/user_repository.dart'; // Added for User Stats
import '../../workouts/presentation/pages/workout_hub_screen.dart';
import '../../workouts/presentation/pages/active_workout_session.dart';
import '../../workouts/data/web_companion_provider.dart';
import '../../workouts/data/web_companion_service.dart';
import '../../workouts/data/models/exercise_model.dart';
import '../domain/workout_activity.dart';
import '../data/path_repository.dart';
import '../data/path_generation_service.dart';
import 'widgets/vertical_timeline_path.dart';
import '../../onboarding/domain/user_profile.dart'; // Added for Enums
import '../../workouts/data/seed_exercises_large.dart'; // CORRECT IMPORT

import '../data/health_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Re-run seed on Home load to ensure data exists (post-auth)
    _seedDatabase();
  }

  Future<void> _seedDatabase({bool force = false}) async {
    await seedStart(force: force);
  }

  void _showEditProfileDialog(UserProfile user) {
    Goal selectedGoal = user.primaryGoal;
    ExperienceLevel selectedExp = user.experienceLevel;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Edit Profile"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<Goal>(
                    initialValue: selectedGoal,
                    decoration: const InputDecoration(labelText: "Goal"),
                    items: Goal.values.map((g) {
                      return DropdownMenuItem(
                        value: g,
                        child: Text(g.name.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => selectedGoal = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<ExperienceLevel>(
                    initialValue: selectedExp,
                    decoration: const InputDecoration(labelText: "Experience"),
                    items: ExperienceLevel.values.map((e) {
                      return DropdownMenuItem(
                        value: e,
                        child: Text(e.name.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => selectedExp = val);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await ref.read(userRepositoryProvider).updateProfile({
                      'primaryGoal': selectedGoal.name,
                      'experienceLevel': selectedExp.name,
                    });
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showWebCompanionDialog() {
    final TextEditingController codeController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Connect Web Companion"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Enter the 4-digit pairing code from mocap-web running on your laptop."),
              const SizedBox(height: 16),
              TextField(
                controller: codeController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: InputDecoration(
                  labelText: "Pairing Code",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final code = codeController.text.trim();
                if (code.length == 4) {
                  // Set connected session provider
                  ref.read(webCompanionSessionProvider.notifier).setSession(code);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Connected to session $code!")),
                    );
                  }
                }
              },
              child: const Text("Connect"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch User Profile for Stats
    final userAsync = ref.watch(userProfileProvider);
    final streak = userAsync.value?.streak ?? 0;
    final xp = userAsync.value?.xp ?? 0;
    final displayName = userAsync.value?.displayName ?? "BloomFit User";
    final level = userAsync.value?.level ?? 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFFF0F5), // Lavender Blush
                    Colors.white,
                  ],
                ),
              ),
            ),
          ),

          // Main Content
          IndexedStack(
            index: _currentIndex,
            children: [
              _buildPathView(),
              const WorkoutHubScreen(),
              // REMOVED SOCIAL TAB
              _buildProfileView(displayName, level, streak, xp),
            ],
          ),

          // Floating HUD (Top)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16, // Dynamic top padding
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE0F7FA),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Color(0xFF00ACC1),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            "Level $level",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _HeaderPill(
                        icon: Icons.local_fire_department,
                        text: "$streak",
                        color: const Color(0xFFFF6B6B),
                      ),
                      const SizedBox(width: 8),
                      _HeaderPill(
                        icon: Icons.bolt,
                        text: "$xp",
                        color: const Color(0xFFFFD93D),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        elevation: 0,
        indicatorColor: const Color(0xFFFF6B6B).withOpacity(0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.timeline_rounded),
            selectedIcon: Icon(
              Icons.timeline_rounded,
              color: Color(0xFFFF6B6B),
            ),
            label: 'Journey',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(
              Icons.fitness_center_rounded,
              color: Color(0xFFFF6B6B),
            ),
            label: 'Workouts',
          ),
          // REMOVED SOCIAL TAB
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: Color(0xFFFF6B6B)),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildPathView() {
    // 1. Ensure initialization is complete (only re-runs on UID change)
    final initAsync = ref.watch(pathInitializationProvider);

    return Padding(
      padding: const EdgeInsets.only(top: 130.0), // Add padding to clear HUD
      child: initAsync.when(
        data: (_) {
          // 2. Once initialized, watch the data stream
          final pathAsync = ref.watch(pathNodesProvider);
          return pathAsync.when(
            data: (nodes) {
              if (nodes.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.sentiment_dissatisfied,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No plan generated yet.",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          // Or just rebuild? ref.invalidate(pathInitializationProvider);
                          ref.invalidate(pathInitializationProvider);
                        },
                        child: const Text("Retry Generation"),
                      ),
                    ],
                  ),
                );
              }
              return VerticalTimelinePath(nodes: nodes);
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF6B6B)),
            ),
            error: (err, stack) => Center(child: Text("Error: $err")),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFFF6B6B)),
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text("Failed to initialize path: $err"),
              TextButton(
                onPressed: () => ref.invalidate(pathInitializationProvider),
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileView(String name, int level, int streak, int xp) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24.0, 100.0, 24.0, 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFFE0F7FA),
              child: Icon(Icons.person, size: 50, color: Color(0xFF00ACC1)),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              "Level $level • $xp XP",
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            _ProfileStatCard(
              icon: Icons.local_fire_department,
              label: "Streak",
              value: "$streak Days",
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            ref.watch(todayStepsProvider).when(
                  data: (steps) => _ProfileStatCard(
                    icon: Icons.directions_walk,
                    label: "Today's Steps",
                    value: "$steps",
                    color: Colors.green,
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const SizedBox.shrink(),
                ),
            const SizedBox(height: 16),
            ref.watch(todayCaloriesProvider).when(
                  data: (cals) => _ProfileStatCard(
                    icon: Icons.monitor_heart,
                    label: "Active Calories",
                    value: "${cals.toStringAsFixed(0)} kcal",
                    color: Colors.redAccent,
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    final user = ref.read(userProfileProvider).value;
                    if (user != null) _showEditProfileDialog(user);
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text("Edit Profile"),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _showWebCompanionDialog(),
                  icon: const Icon(Icons.computer),
                  label: const Text("Web Companion"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                final code = ref.read(webCompanionSessionProvider);
                if (code != null) {
                  final exercise = ExerciseModel(id: "squat_001", name: "Squat (Demo Mode)", bodyPart: "Legs", difficulty: "Easy", instructions: [], imageUrl: "", equipment: "");
                  final activity = WorkoutActivity(exerciseId: "squat_001", sets: 1, reps: 5, notes: "Demo");
                  
                  ref.read(webCompanionServiceProvider).updateLiveSession(
                    code,
                    activity,
                    exercise
                  );
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Triggered Squat Demo on Web!")));

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ActiveWorkoutSession(
                        workoutTitle: "Web Companion Demo",
                        activities: [activity],
                        allExercises: [exercise],
                        pathNodeId: '',
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Connect to Web Companion first!")));
                }
              },
              icon: const Icon(Icons.play_circle_filled),
              label: const Text("Trigger PC Demo"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // Force re-seed manually if needed
                _seedDatabase(force: true).then((_) async {
                  // Delete existing path to force regeneration
                  final user = ref.read(userProfileProvider).value;
                  if (user != null) {
                    // Show Loading
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Regenerating Plan... Please Wait"),
                      ),
                    );

                    await ref
                        .read(pathGenerationServiceProvider)
                        .deletePathForUser(user.uid);
                    // Trigger generation
                    await ref
                        .read(pathGenerationServiceProvider)
                        .generatePathForUser(user);
                  }

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "New Plan Ready! Pull to refresh if needed.",
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                });
              },
              icon: const Icon(Icons.autorenew),
              label: const Text("Regenerate Workout Plan"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B6B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(authRepositoryProvider).signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[50],
                foregroundColor: Colors.red,
              ),
              child: const Text("Sign Out"),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ProfileStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey[600])),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _HeaderPill({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF212121),
            ),
          ),
        ],
      ),
    );
  }
}
