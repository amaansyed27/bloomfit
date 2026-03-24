# Motion Capture & Rep Counter (mocap-web)

This document explores the mechanics, privacy infrastructure, and rep-counting intelligence behind the BloomFit Web Companion.

## 1. Overview of the Web Companion
The **mocap-web** companion serves one singular purpose: to observe, analyze, and correct your exercise form in real-time. It is built as a lightweight, lightning-fast **React (Vite/TypeScript)** application that runs natively in a desktop or tablet browser.

## 2. Privacy-First Motion Capture
One of the core tenants of BloomFit is **Privacy**. Users often feel uncomfortable or socially anxious when exercising in front of others or having cameras record them in their homes.
*   **Edge-Computed Processing:** BloomFit solves this by executing the entire motion capture pipeline *on the client's device*.
*   **Google MediaPipe Vision Tasks:** The application downloads a tiny (`pose_landmarker_lite.task`) machine learning model. The user's webcam feed is fed directly into this local model.
*   **No Video Uploads:** At no point does a single frame of video ever leave the user's laptop. It is not saved, it is not sent to a cloud server, and it is not viewable by anyone else. The only data transmitted over the internet are lightweight numbers (e.g., "Reps: 5, Knee Angle: 85°").

## 3. How the Skeletal Overlay Works
To provide the user with confidence that the AI "sees" them, the web companion draws a 3D skeletal overlay directly on top of the webcam feed.

*   **MediaPipe Output:** The MediaPipe model outputs a `NormalizedLandmark` array. This contains 33 (x, y, z) coordinates representing the human body (e.g., Landmark 11 is the left shoulder, 23 is the left knee).
*   **React Three Fiber (R3F):** We use `three.js` inside a React `<Canvas>` to render this data.
*   **Joints & Bones:** The `useFrame` hook continuously iterates over the 33 landmarks. For each landmark, it renders a small `<sphereGeometry>` (a joint). For specific connections (e.g., Shoulder to Elbow), it calculates the distance and rotation matrix between the two 3D coordinates and renders a stretched `<cylinderGeometry>` (a bone).

## 4. The Rep Counter Engine
The intelligence of the Web Companion lives inside `src/utils/exerciseLogic.ts`.

### 4.1. The Math (`calculateAngle`)
The foundation of the rep counter is measuring joint angles. To find the angle of the user's knee, the app calculates the vector angle between the **Hip**, **Knee**, and **Ankle** landmarks using the dot product and arccosine mathematics.

### 4.2. Exercise Evaluation Logic
The app dynamically switches its analysis logic based on the `exerciseName` it receives from the mobile app's Firestore document.

**Example: The Squat (`evaluateSquat`)**
1.  **Visibility Check:** First, the engine verifies that the required landmarks (hips, knees, ankles) are within the camera frame with a high confidence score (`visibility > 0.6`).
2.  **Angle Calculation:** It calculates the angle of the left and right knees.
3.  **State Machine:**
    *   **State 1 (Standing):** The knee angle is near 180° (straight). The state variable `isSquatting` is false.
    *   **State 2 (Descending):** As the knee angle decreases, the app monitors the depth.
    *   **State 3 (The Bottom):** If the knee angle drops below a threshold (e.g., `< 90°` or `< 100°`), the app flips the `isSquatting` flag to true. It updates the `formFeedback` to **"Good depth!"**.
    *   **State 4 (The Ascent):** If the user's knee angle returns above a higher threshold (e.g., `> 160°`) *and* `isSquatting` is true, the user has completed a full rep.
4.  **Action:** The app increments `currentReps` by +1 and resets `isSquatting` to false.

### 4.3. Form Correction Feedback
If the user performs a "half-rep" (descending to 120° and standing back up), the `isSquatting` flag never flips to true. The rep is ignored, and the `formFeedback` dynamically updates to **"Go lower!"** or **"Knees too far forward!"** based on secondary calculations.

## 5. Connecting the Dots
Once `currentReps` increments or `formFeedback` changes, the custom React hook `useSyncLiveSession` immediately pushes this tiny data packet to Firestore (`live_sessions/{code}`). The Flutter app, listening on the other end, instantly updates its big UI counter from "0" to "1".
