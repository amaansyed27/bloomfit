# BloomFit: Phase-Based Task List

## Phase 1: Foundation & Project Setup
- [x] Initialize Flutter Project (BloomFit) <!-- id: 0 -->
    - [x] Create new Flutter app <!-- id: 1 -->
    - [x] Set up project structure (core, features, data, domain) <!-- id: 2 -->
    - [x] Add dependencies (firebase_core, flutter_riverpod, go_router, google_fonts) <!-- id: 3 -->
- [x] Configure Firebase Backend <!-- id: 4 -->
    - [x] Create Firebase Project & Apps (Android/iOS) <!-- id: 5 -->
    - [x] Enable Authentication (Google, Email/Password) <!-- id: 6 -->
    - [x] Enable Firestore Database <!-- id: 7 -->
- [x] Implement Design System <!-- id: 8 -->
    - [x] Create [AppTheme](file:///d:/Programming/02_University/epics/bloomfit/lib/core/theme/app_theme.dart#4-81) (Classy Playful, Physics-based Animations) <!-- id: 9 -->
    - [x] Add custom fonts (Outfit/Jakarta + Inter) <!-- id: 10 -->
    - [x] Create shared widgets (SpringButton, LiquidCard) <!-- id: 11 -->

## Phase 2: Onboarding Experience (The Hook)
- [x] Build Welcome / Intro Screen (Logo, App Features, Auth Entry) <!-- id: 25 -->
    - [x] Integrate Logo Assets (Abstract & Wordmark) <!-- id: 29 -->
    - [x] Refine "Get Started" & "I have an account" Button Styling <!-- id: 30 -->
- [x] Implement Authentication <!-- id: 26 -->
    - [x] Google Sign-In <!-- id: 27 -->
    - [x] Email/Password Sign-In (Placeholder/Structure Ready) <!-- id: 28 -->
- [x] Build Onboarding Screens <!-- id: 12 -->
    - [x] Welcome / Start Screen <!-- id: 13 -->
    - [x] Goal Selection (Weight Loss, Muscle, etc.) <!-- id: 14 -->
    - [x] User Stats Input (Age, Height, Weight - NumberPicker) <!-- id: 15 -->
    - [x] Experience Level (Rookie, Casual, Pro) <!-- id: 16 -->
    - [x] Logistics (Days/Week, Equipment) <!-- id: 17 -->
- [x] Implement State Management <!-- id: 18 -->
    - [x] Create [UserProfile](file:///d:/Programming/02_University/epics/bloomfit/lib/features/onboarding/domain/user_profile.dart#7-90) model <!-- id: 19 -->
    - [x] Build [OnboardingController](file:///d:/Programming/02_University/epics/bloomfit/lib/features/onboarding/presentation/onboarding_controller.dart#65-148) (Riverpod Notifier) <!-- id: 20 -->
    - [x] Save full user profile to Firestore `users/{uid}` <!-- id: 21 -->

## Phase 3: The Path (Home UI)
- [/] Build Home Screen Layout
    - [ ] Header (Streak Count, XP, Profile Pic)
    - [ ] Bottom Navigation (Path, Leaderboard, Quests, Profile)
- [ ] Develop "The Path" Widget
    - [ ] Create `PathPainter` for the winding road visual
    - [ ] Implement `PathNode` widget (Locked/Active/Done states)
    - [ ] Add scrolling mechanics (current node centered)
- [ ] Connect Path to Data
    - [ ] Stream user progress from Firestore
    - [ ] Logic to unlock next node upon workout completion

## Phase 4: Workout Engine
- [ ] Data Management <!-- id: 32 -->
    - [ ] Define `Exercise` and `Workout` models <!-- id: 33 -->
    - [ ] Create Seed Script for initial 50 exercises (JSON to Firestore) <!-- id: 34 -->
- [ ] Workout Generator <!-- id: 35 -->
    - [ ] Algorithm to select 5-7 exercises based on user profile <!-- id: 36 -->
    - [ ] Algorithm to scale reps/sets based on difficulty <!-- id: 37 -->
- [ ] Workout Player UI <!-- id: 38 -->
    - [ ] Intro Screen (Target Muscles Map) <!-- id: 39 -->
    - [ ] Exercise View (Video Loop, Timer, Rep Counter) <!-- id: 40 -->
    - [ ] Rest Timer Overlay <!-- id: 41 -->
    - [ ] Post-Set Feedback ("Too Easy/Hard") <!-- id: 42 -->

## Phase 5: Gamification & Polish
- [ ] Implement Gamification Logic <!-- id: 43 -->
    - [ ] XP Calculation & Update <!-- id: 44 -->
    - [ ] Streak Calculation (Daily check) <!-- id: 45 -->
    - [ ] "Level Up" Overlay Animation <!-- id: 46 -->
- [ ] Final Polish <!-- id: 47 -->
    - [ ] Splash Screen (Animated Logo) <!-- id: 48 -->
    - [ ] Haptic Feedback integration <!-- id: 49 -->
    - [ ] Sound Effects (Completion, Timer Beep) <!-- id: 50 -->
