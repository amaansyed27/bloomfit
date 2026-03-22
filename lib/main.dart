import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'features/authentication/data/auth_repository.dart';
import 'features/authentication/presentation/pages/welcome_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'firebase_options.dart';

import 'features/workouts/data/seed_exercises_large.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Seed the database if needed (auto-checks for existing data)
  try {
    // Note: This might fail if rules require auth and user isn't logged in.
    // For now, we catch the error so the app defaults to empty/loading instead of crashing.
    // In a real app, run this after login or via Admin SDK.
    await seedStart();
  } catch (e) {
    debugPrint("Seeding failed (likely auth permission): $e");
  }

  runApp(const ProviderScope(child: BloomFitApp()));
}

class BloomFitApp extends StatelessWidget {
  const BloomFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BloomFit',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStateAsync = ref.watch(authStateProvider);

    return authStateAsync.when(
      data: (user) {
        if (user != null) {
          // If user is logged in, go to Home
          // Ideally check if profile is set, but for now Home is fine.
          return const HomeScreen();
        } else {
          return const WelcomeScreen();
        }
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }
}
