# Backend Architecture & Integrations

This document covers the Firebase architecture, the Cloud Sync Engine, Gemini API interactions, and storage strategies behind the BloomFit ecosystem.

## 1. Overview of the Cloud Backend
BloomFit leverages a highly distributed, serverless architecture centered entirely around **Google Cloud Services (Firebase)**. This approach eliminates the need for managing a monolithic, RESTful API server. The mobile application and the React Web Companion both talk directly to the cloud.

## 2. Firebase Infrastructure

### Authentication
*   Uses **Firebase Authentication**.
*   Supports Email/Password creation, Google Sign-In, and Anonymous sessions (for users who want to try the app before committing).
*   A `userProfileProvider` in Riverpod dynamically watches the `authStateChanges()` stream to automatically redirect users to the onboarding flow or the main Home Screen based on their `uid`.

### Firestore Data Schema (The Nervous System)
*   **The `users/{uid}` Collection**: This is the core repository for all persistent data.
    *   **`users/{uid}/history`**: Every completed workout pushes a document here containing the duration, total volume (sets/reps), timestamp, and a calculated overall accuracy score (0-100%).
    *   **`users/{uid}/custom_workouts`**: A subcollection where users can craft, save, and delete their own custom routines.
    *   **`users/{uid}/paths`**: Where the Gemini AI deposits the generated nodes (the Journey).

## 3. The Companion Connection (The Bridge)

The most complex integration is the **Synchronous Bridge** between the Flutter mobile app and the React `mocap-web` companion. 

### The Handshake Protocol (`live_sessions`)
1.  **Initiation:** The React Web App generates a random 4-digit code (e.g., `8492`) using `Math.floor(1000 + Math.random() * 9000)`. It immediately creates a new document in the root `live_sessions/8492` Firestore collection and sets the `status` to `"idle"`.
2.  **Connection:** The user taps "Connect Web Companion" on their phone and enters the `8492` code.
3.  **The Payload:** The Flutter app writes its current `WorkoutActivity` and `ExerciseModel` details (the name of the exercise, the target reps, the duration, and an array of text `instructions`) into the `live_sessions/8492` document. It also changes the status to `"active"`.
4.  **Reaction:** The React Web App, using `onSnapshot` inside a custom hook, detects the status change and immediately populates its UI with the `exerciseName` (e.g., "Squat") and renders the step-by-step instructions.

### The Feedback Loop
While the user exercises, the Web Companion continuously calculates their joint angles. When a rep is completed, or a form correction is needed, it updates the `currentReps` and `formFeedback` fields in the `live_sessions/8492` document. The Flutter app's `ActiveWorkoutSession` screen listens to this exact document using a `StreamSubscription`. Any change instantly triggers a `setState` on the phone, updating the giant rep counter and feedback text in under 100 milliseconds.

## 4. Generative AI (Gemini 3 Flash)

BloomFit does not use hardcoded workout templates. It uses a **PathGenerationService** connected to Google's `gemini-1.5-flash` model.

### Prompt Engineering
The service constructs a massive, detailed prompt behind the scenes:
1.  It injects the user's `primaryGoal` (e.g., Weight Loss, Muscle Gain).
2.  It injects the user's `experienceLevel` (e.g., Beginner, Advanced).
3.  It pulls the user's recent `history` subcollection to find any exercises they skipped and the reason *why* they skipped it (e.g., "Squats - Pain or Injury").
4.  It instructs Gemini to generate a 3-day workout path, specifically telling it to replace any exercises the user skipped previously with alternatives (e.g., substituting Squats for Glute Bridges).

### Structured Output
We enforce a strict JSON schema on the Gemini response. The AI returns a highly organized array of `PathNode` objects, complete with `workoutTitle`, `activities` (exercise IDs, sets, reps), and localized `instructions`. The Flutter app parses this JSON directly into the Journey timeline UI.

## 5. Storage and Data Privacy

*   **No Video Storage:** The Web Companion only uses the webcam stream locally in the browser's memory (`HTMLVideoElement` -> `MediaPipe Tasks Vision`). The frames are immediately discarded. No video data is ever uploaded to Firebase Storage or recorded on the user's device.
*   **Minimal Metadata:** The only data passed through the cloud are lightweight strings and integers (`currentReps: 5`, `formFeedback: "Go lower!"`), ensuring absolute privacy and minimal bandwidth usage.
