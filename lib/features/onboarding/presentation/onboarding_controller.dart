import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bloomfit/features/onboarding/data/onboarding_repository.dart';
import 'package:bloomfit/features/onboarding/domain/user_profile.dart';

class OnboardingState {
  final int currentStep;
  final Gender? gender;
  final int? age;
  final double? weight;
  final double? height;
  final double? targetWeight;
  final ExperienceLevel? experienceLevel;
  final Goal? primaryGoal;
  final List<String> equipment;
  final int daysPerWeek;
  final int durationMinutes;
  final int planDurationMonths;
  final bool isSubmitting;

  OnboardingState({
    this.currentStep = 0,
    this.gender,
    this.age,
    this.weight,
    this.height,
    this.targetWeight,
    this.experienceLevel,
    this.primaryGoal,
    this.equipment = const [],
    this.daysPerWeek = 3,
    this.durationMinutes = 30,
    this.planDurationMonths = 1,
    this.isSubmitting = false,
  });

  OnboardingState copyWith({
    int? currentStep,
    Gender? gender,
    int? age,
    double? weight,
    double? height,
    double? targetWeight,
    ExperienceLevel? experienceLevel,
    Goal? primaryGoal,
    List<String>? equipment,
    int? daysPerWeek,
    int? durationMinutes,
    int? planDurationMonths,
    bool? isSubmitting,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      targetWeight: targetWeight ?? this.targetWeight,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      primaryGoal: primaryGoal ?? this.primaryGoal,
      equipment: equipment ?? this.equipment,
      daysPerWeek: daysPerWeek ?? this.daysPerWeek,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      planDurationMonths: planDurationMonths ?? this.planDurationMonths,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class OnboardingController extends Notifier<OnboardingState> {
  late final OnboardingRepository _repository;

  @override
  OnboardingState build() {
    _repository = ref.read(onboardingRepositoryProvider);
    return OnboardingState();
  }

  void nextStep() {
    state = state.copyWith(currentStep: state.currentStep + 1);
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void setGoal(Goal goal) {
    state = state.copyWith(primaryGoal: goal);
  }

  void setStats({
    int? age,
    double? weight,
    double? height,
    Gender? gender,
    double? targetWeight,
  }) {
    state = state.copyWith(
      age: age,
      weight: weight,
      height: height,
      gender: gender,
      targetWeight: targetWeight,
    );
  }

  void setExperience(ExperienceLevel level) {
    state = state.copyWith(experienceLevel: level);
  }

  void setLogistics({int? days, int? duration, List<String>? equipment}) {
    state = state.copyWith(
      daysPerWeek: days,
      durationMinutes: duration,
      equipment: equipment,
    );
  }

  void setPlanDuration(int months) {
    state = state.copyWith(planDurationMonths: months);
  }

  Future<void> submitProfile(
    String uid,
    String email,
    String? displayName,
  ) async {
    state = state.copyWith(isSubmitting: true);
    try {
      final profile = UserProfile(
        uid: uid,
        email: email,
        displayName: displayName,
        gender: state.gender,
        age: state.age,
        weight: state.weight,
        height: state.height,
        targetWeight: state.targetWeight,
        experienceLevel: state.experienceLevel ?? ExperienceLevel.rookie,
        primaryGoal: state.primaryGoal ?? Goal.getFitter,
        equipment: state.equipment,
        daysPerWeek: state.daysPerWeek,
        durationMinutes: state.durationMinutes,
        planDurationMonths: state.planDurationMonths,
      );

      await _repository.saveUserProfile(profile);
    } catch (e) {
      // Re-throw or handle error appropriately in UI
      rethrow;
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }
}

final onboardingProvider =
    NotifierProvider<OnboardingController, OnboardingState>(() {
      return OnboardingController();
    });
