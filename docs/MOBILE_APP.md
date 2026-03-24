# Mobile Application (The BloomFit Hub)

This document details the frontend architecture, features, UI/UX philosophy, and 3D modeling implementation of the core BloomFit mobile application.

## 1. Overview
The BloomFit mobile app is the central hub of the ecosystem, built entirely in **Flutter** (Dart) for high-performance, cross-platform compatibility. It serves as the user's personal AI trainer, workout manager, and performance tracker.

## 2. UI/UX Philosophy
BloomFit's design language revolves around **"Decluttered Focus."** Working out is strenuous; the app should not add cognitive load. 
*   **Minimalist Color Palette:** Soft gradients (Lavender Blush to White) mixed with stark, high-contrast action buttons (Red/Pink for primary actions, Teal/Green for success).
*   **Single-Set Focus (Circuit Flow):** Instead of overwhelming the user with a scrolling list of 10 exercises and 30 checkboxes, the app uses a flattened Circuit Engine. The screen displays exactly **one set of one exercise at a time** (e.g., "Set 2 of 3 • 12 Reps").
*   **Progressive Disclosure:** Complex information (like detailed text instructions) is hidden behind simple `?` (Help) buttons, keeping the main interface focused strictly on the countdown timer or the rep counter.

## 3. Key Features

### A. The AI Journey
The primary tab of the app is a vertical, scrollable node map (similar to Duolingo or Candy Crush).
*   Powered by Google's **Gemini 1.5 Flash**, the app dynamically generates a multi-day workout path based on the user's explicit goals and experience level.
*   **Dynamic Rerouting:** If a user skips a "Heavy Squat" exercise and selects "Pain or Injury" as the reason, the AI will restructure the future nodes to avoid heavy leg workouts and focus on recovery or upper body.

### B. The Workout Hub (Custom Crafter)
Users who want full control can craft their own workouts.
*   **3D Previews:** Before adding an exercise to a custom routine, users can tap it to open a bottom sheet. This loads a full 3D animated model of the exercise, allowing the user to inspect the exact biomechanics before committing.
*   **Analytics Dashboard:** A beautiful top-level dashboard aggregates historical data (Accuracy %, Total Workouts, Total Minutes) fetched from Firestore.

### C. Active Workout Engine
The core execution screen where the user actually works out.
*   Supports both **Duration-based** (e.g., 60s Plank) and **Rep-based** (e.g., 12x Pushups) exercises.
*   **Rest Enforcement:** Automatically triggers an un-skippable (but adjustable) 30-second rest overlay between exercises to enforce proper hypertrophy/endurance recovery intervals.
*   **Companion Integration:** Houses the "Connect Web Companion" handshake UI.

### D. Health Connect Integration
*   The profile screen integrates directly with the Android `Health Connect` API to pull the user's daily step count and active calories burned, unifying external activity with their BloomFit sessions.

## 4. 3D Coaching Models
A standout feature of the mobile app is the embedded 3D animated coaches.

*   **Technology:** Uses the `model_viewer_plus` Flutter package, which wraps Google's `<model-viewer>` web component.
*   **The Assets:** We utilize `.glb` (GL Transmission Format) files exported from Adobe Mixamo. These feature a high-quality human character with baked-in, motion-captured biomechanical animations (Squats, Pushups, Lunges, etc.).
*   **Offline Support:** To ensure the app loads instantly even on poor gym Wi-Fi, the heavy `.glb` files (up to 48MB each) are bundled locally inside the APK (`assets/models/`). 
*   **Implementation:** The `getGlbPathForExercise` utility dynamically maps the current exercise string (e.g., "jumping jacks") to the correct local asset path. The model auto-plays its animation loop directly above the workout timer.
