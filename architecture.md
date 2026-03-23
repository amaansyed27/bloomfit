# BloomFit Architecture & Build Overview

## 1. 3D Model & Motion Capture Web Engine (`mocap-web`)
The motion capture companion application is a separate web-based viewer that interacts alongside the main mobile application.

### Core 3D & Vision Libraries
- **Three.js**: The underlying raw WebGL 3D rendering engine.
- **React Three Fiber (`@react-three/fiber`)**: A React-based renderer for Three.js that allows building 3D scene graphs using JSX components.
- **Drei (`@react-three/drei`)**: A supplementary library providing pre-built helpers, controls, and abstractions for React Three Fiber.
- **Google MediaPipe (`@mediapipe/tasks-vision`)**: Used for real-time skeletal/pose tracking and detection. It analyzes the user's webcam feed to map their physical geometry onto the 3D model.

### Build & Tech Stack (Web)
- **Framework**: React 19 + TypeScript.
- **Bundler**: Vite (Provides ultra-fast HMR and optimized production builds).
- **Styling**: Tailwind CSS v4 (`@tailwindcss/vite`).
- **Database Connection**: Firebase (`firebase` v10) to sync real-time session state with the mobile application.

---

## 2. BloomFit Mobile App (Flutter)
The main client is a mobile application built focusing on performance, smooth animations, and AI-driven workout tailoring.

### Mobile Tech Stack & Architecture
- **Framework**: Flutter (Dart).
- **State Management**: Riverpod (`flutter_riverpod`). Provides an ironclad, declarative global state, specifically handling the complex states of active workout sessions and node generation.
- **Routing**: GoRouter (`go_router`) for declarative routing and deep linking.
- **AI & Logic Engine**: `firebase_ai` is used to communicate with Gemini. The app runs a "Statistical Fitness Engine" (SFE) that pipes accuracy, intensity (RPE), skips, and muscle fatigue into the Gemini prompt to dynamically adjust future workout nodes.
- **Health/Fitness Syncing**: Uses the `health` package to synchronize workout data with Apple Health and Google Health Connect.

### Mobile Build Details
- **Entry & Env**: Environment variables injected via `.env` (`flutter_dotenv`).
- **Styling**: `google_fonts` combined with localized `flutter_animate` components for high-quality UX micro-animations (e.g. `Confetti` for success states).

---

## 3. Overall System Communication (The Bridge)
The Mobile app and the Web Mocap app perform a "Companion Dance" architecture.
1. The **Flutter App** initiates a workout session and pushes the targeted exercises and baseline constraints to **Firestore**.
2. The user mounts their laptop/tablet and opens **mocap-web**, which listens to the same Firebase Authentication / Firestore scope.
3. **MediaPipe** continuously tracks the user's form against the active exercise. 
4. Form accuracy, sets completed, and real-time joint feedback are visually represented via the **React Three Fiber** model.
5. The statistics are saved back to Firestore, where the Flutter app's **Statistical Fitness Engine** ingests them to re-evaluate the user's overall muscle fatigue, proficiency, and next AI pathway node.
