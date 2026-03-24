# API & Services Reference

This document outlines the core services, repositories, and external APIs integrated into the BloomFit ecosystem.

## 1. Firebase Cloud Services

### `web_companion_service.dart`
Handles the real-time bidirectional synchronization between the Flutter App and the React Web Companion.
*   **`createSession(String userId)`**: Initializes a new session with a random 4-digit code.
*   **`listenToSession(String sessionId)`**: Subscribes to changes in `live_sessions/{sessionId}` to receive `currentReps` and `formFeedback` from the React app.
*   **`updateLiveSession(String sessionId, WorkoutActivity activity, ExerciseModel exercise)`**: Pushes the active exercise details, target reps, and text `instructions` to the web app so the user can follow along on their laptop screen.
*   **`endLiveSession(String sessionId)`**: Marks the session as inactive.

### `path_generation_service.dart`
The intelligence engine that connects to Google's Gemini AI.
*   **`generatePathForUser(UserProfile profile)`**: Collects the user's `primaryGoal`, `experienceLevel`, and historical skipped exercises to build a comprehensive prompt. Sends the prompt to `gemini-1.5-flash` and parses the returned JSON string into a structured list of `PathNode` objects, saved directly to Firestore.

### `workout_history_repository.dart`
*   **`saveSession(String userId, ...)`**: Commits the completed workout data (duration, exercises completed, skipped exercises, accuracy score) to the `users/{uid}/history` subcollection for statistical tracking.

---

## 2. External Hardware & Sensors

### `health_service.dart`
Integrates with the Android Health Connect API.
*   **`fetchStepsAndCalories()`**: Requests permission to read `StepsRecord` and `ActiveCaloriesBurnedRecord` for the current day. Aggregates the data and updates the user's profile dashboard. Requires physical device execution (cannot run on standard emulators without Health Connect installed).

---

## 3. The React Web Companion (mocap-web)

### `src/hooks/useMediaPipe.ts`
The core computer vision pipeline.
*   **Initialization**: Downloads the `pose_landmarker_lite.task` model asynchronously.
*   **Execution**: Continuously feeds frames from the `HTMLVideoElement` into the `PoseLandmarker.detectForVideo()` method.
*   **Output**: Yields normalized 3D landmarks (x, y, z) representing 33 body joints.

### `src/utils/exerciseLogic.ts`
The biomechanical analysis engine.
*   **`calculateAngle(a, b, c)`**: Uses vector mathematics to determine the angle between three 3D joints (e.g., Hip, Knee, Ankle).
*   **`evaluateSquat(landmarks)`**: Checks if the user is in frame. Measures knee flexion. If the knee angle drops below 90 degrees, it registers a "down" state. When the user returns to >160 degrees, it registers an "up" state, increments the rep counter, and provides form feedback (e.g., "Go lower!", "Good depth!").
