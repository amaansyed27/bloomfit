# State Management in BloomFit

This document explains how state is managed across the BloomFit ecosystem using `flutter_riverpod` for the mobile app and React Hooks for the Web Companion.

## 1. Mobile Application (Riverpod)

The mobile application heavily relies on Riverpod's declarative, unidirectional data flow to ensure the UI is always a pure function of the underlying application state.

### Core Providers

*   **`userProfileProvider` (StreamProvider)**: The absolute source of truth for the currently authenticated user's profile (XP, level, streak, goals). All profile dashboards and AI generation services watch this stream to update reactively.
*   **`pathInitializationProvider` (FutureProvider)**: A crucial initialization gatekeeper. It checks if the user has a generated `paths` collection in Firestore. If none exists, it triggers the Gemini `pathGenerationServiceProvider` to generate one *before* rendering the Journey timeline.
*   **`pathNodesProvider` (StreamProvider)**: Streams the sorted list of AI-generated `PathNode` objects to the Journey screen.
*   **`userCustomWorkoutsProvider` (StreamProvider)**: Retrieves all user-crafted custom workouts from the `custom_workouts` collection.
*   **`workoutStatsProvider` (StreamProvider)**: Aggregates historical workout data (Accuracy, Total Time, Completed Workouts) from the `history` collection to power the Performance Analytics dashboard on the Library tab.

### The Web Companion Provider
*   **`webCompanionSessionProvider` (StateNotifierProvider)**: Manages the 4-digit pairing code string. When non-null, the `ActiveWorkoutSession` automatically activates its real-time listener to the `webCompanionServiceProvider` and begins syncing the workout state.

## 2. Active Workout Engine (Circuit Flow)

The `ActiveWorkoutSession` screen manages complex, multi-layered state locally (using `StatefulWidget` and `setState`) because its lifecycle is highly volatile and tightly scoped to a single workout instance.

### Key Local State Variables
*   `_steps` (`List<_WorkoutStep>`): The flattened, interlaced "Circuit" created in `initState`.
*   `_currentStepIndex` (`int`): The pointer tracking exactly which exercise and set the user is currently performing.
*   `_isExerciseTimerRunning` / `_remainingSeconds`: Local variables controlling the UI countdown for duration-based exercises (e.g., Planks).
*   `_liveReps` / `_liveFeedback`: Sourced directly from the Web Companion's Firestore document stream, constantly triggering `setState` to update the big UI counter in real-time.

## 3. React Web Companion (React Hooks)

The web companion uses a combination of built-in React hooks and custom hooks for performance and video processing.

*   **`useState` / `useRef`**: Handles simple UI toggles (like permissions) and references to the DOM elements (`<video>`, `<canvas>`).
*   **`useMediaPipe`**: A custom hook that isolates the complex initialization, loading state, and continuous execution loop of the Google MediaPipe Pose Landmarker. It yields a raw array of `NormalizedLandmark[]`.
*   **`useSyncLiveSession`**: A custom hook that subscribes to the specific 4-digit `live_sessions` Firestore document. It manages two-way synchronization: pulling down the `exerciseName` and `instructions` from the phone, and pushing up the `currentReps` calculated by the biomechanical engine.
