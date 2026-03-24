# Motion Capture Companion (mocap-web)

This document provides specialized instructions and details for the **BloomFit Web Companion**, powered by React, Three.js, and Google MediaPipe.

---

## 1. Core Responsibilities

The Web Companion is a lightweight, strictly client-side web application designed to run on a user's laptop or tablet. Its primary purpose is to act as a **"Smart Mirror"** while the user performs exercises prescribed by the BloomFit mobile app.

It offloads the heavy machine learning processing from the phone's hardware, providing zero-latency, full-body 3D skeletal tracking right in the browser.

---

## 2. Technical Stack & Dependencies

*   **React 18**: Core UI framework.
*   **Vite**: Fast, modern build tool.
*   **Tailwind CSS**: Utility-first styling for the sleek dark-mode UI.
*   **Lucide React**: Vector icons.
*   **Google MediaPipe Tasks Vision (`@mediapipe/tasks-vision`)**: The state-of-the-art machine learning model (`pose_landmarker_lite.task`) that detects 33 3D body landmarks at 30+ frames per second.
*   **Three.js / React Three Fiber (`@react-three/fiber`)**: Renders the dynamic stick-figure avatar overlay matching the user's movements, and loads the 3D `.glb` Coach models.
*   **Firebase/Firestore (`firebase`)**: Provides the sub-100ms real-time data bridge between the mobile app and the web companion.

---

## 3. How It Works (The Data Pipeline)

### 3.1. Initialization & Pairing
1.  On load, the app generates a random 4-digit code (e.g., `8492`).
2.  It creates a document in Firestore at `live_sessions/8492` with `status: "idle"`.
3.  The user enters this code into the mobile app. The mobile app updates the document with `status: "active"`, along with the `exerciseName` (e.g., "Squat"), `targetReps`, and `instructions`.
4.  The React app's `onSnapshot` listener detects this change and updates the UI instantly, displaying the exercise name and step-by-step instructions.

### 3.2. The Computer Vision Loop (`Avatar.tsx` / `useMediaPipe.ts`)
1.  The user grants webcam access.
2.  The raw `<video>` feed is hidden but continuously fed into the `PoseLandmarker.detectForVideo()` method.
3.  MediaPipe outputs an array of 33 normalized landmarks (X, Y, Z coordinates).
4.  These landmarks are passed to the `useFrame` hook in React Three Fiber, which dynamically positions and rotates 3D cylinders (bones) and spheres (joints) to draw a real-time skeleton overlay over the user's video feed.

### 3.3. Biomechanical Analysis (`exerciseLogic.ts`)
1.  The app uses the active `exerciseName` to determine which logic block to run.
2.  For a **Squat**, it calculates the angle between the **Hip**, **Knee**, and **Ankle** landmarks using vector mathematics.
    *   If the angle is `> 160°`, the user is standing.
    *   If the angle drops `< 90°`, it sets a flag `isSquatting = true` and updates `formFeedback` to "Good depth!".
    *   If the user returns to `> 160°` while `isSquatting == true`, it registers a completed rep, increments `currentReps`, and resets the flag.
3.  The `currentReps` and `formFeedback` are instantly written back to the Firestore `live_sessions` document, which the mobile app is actively listening to.

---

## 4. Expanding the Mocap Logic (For Developers)

If you wish to add tracking for a new exercise (e.g., "Jumping Jacks"):

1.  Open `src/utils/exerciseLogic.ts`.
2.  Add a new `evaluateJumpingJack(landmarks, state)` function.
3.  Use the MediaPipe landmark indices (e.g., `11` and `12` for shoulders, `15` and `16` for wrists, `27` and `28` for ankles).
4.  Calculate the distance between the wrists and the distance between the ankles.
5.  If both distances exceed a threshold (hands up, feet apart), mark the "open" state. When they return (hands down, feet together), increment the rep.
6.  Call this new function inside the main evaluation loop when `exerciseName.toLowerCase().includes('jump')`.
