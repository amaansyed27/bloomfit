<div align="center">
  <img src="assets/logo/logo_transparent.png" alt="BloomFit Logo" width="400" />
</div>

<h1 align="center">BloomFit 🌸</h1>

<p align="center">
  <b>A Next-Generation, Privacy-First AI Fitness Ecosystem</b>
</p>

BloomFit is an intelligent, adaptive fitness platform designed to replace generic workout plans with personalized, generative progression. By combining a beautifully crafted Flutter mobile application with a robust React-based Web Motion Capture Companion, BloomFit provides real-time form correction, dynamic AI routing, and gamified health tracking—all from the privacy of your own home.

## 🌟 Core Features

*   **🧠 Gemini AI Workout Journeys**: Powered by Google's Gemini 1.5 Flash, the app generates multi-day, progressive workout paths tailored entirely to your goals, experience level, and past performance. If you struggle with an exercise or skip it due to injury, the AI dynamically reroutes your future path.
*   **💻 Real-Time Web Companion (Mocap)**: Connect your phone to your laptop browser via a secure 4-digit code. Using Google MediaPipe, the web app analyzes your webcam feed, tracks your skeletal joints in 3D, counts your reps, and provides live form feedback directly to your phone.
*   **🧍‍♂️ 3D Animated Coaching**: View ultra-smooth, 3D character animations (Mixamo `.glb` models) natively inside the app before and during your workout to ensure you know exactly how to perform the movement.
*   **⚡ Circuit-Style Workout Engine**: A deeply optimized UI that prevents clutter by guiding you through your workout one single set at a time, enforcing proper 30-second rest intervals between exercises.
*   **📊 Gamification & Analytics**: Earn XP, level up, and maintain streaks. View detailed performance dashboards showing your overall accuracy scores and total volume across your entire fitness journey.
*   **⌚ Health Connect Integration**: Seamlessly pulls your daily step count and active calories from Android Health Connect directly into your profile dashboard.

## 📚 Documentation Index

We have extensively documented the architecture, APIs, and future scope of the BloomFit ecosystem. Please refer to the `docs/` folder for deep dives into specific areas:

1.  [**Architecture & System Overview** (`docs/ARCHITECTURE.md`)](docs/ARCHITECTURE.md)
    *   High-level Mermaid diagrams, data flow, and Firestore database schema.
2.  [**Mobile Application** (`docs/MOBILE_APP.md`)](docs/MOBILE_APP.md)
    *   UI/UX philosophy, Circuit Engine details, and 3D modeling implementation.
3.  [**Motion Capture & Rep Counter** (`docs/MOCAP.md`)](docs/MOCAP.md)
    *   How the React Web Companion uses Google MediaPipe for edge-computed, privacy-first biomechanical analysis.
4.  [**Backend & Integrations** (`docs/BACKEND.md`)](docs/BACKEND.md)
    *   Firebase infrastructure, the synchronous Web Companion bridge, and Gemini AI prompt engineering.
5.  [**State Management** (`docs/STATE_MANAGEMENT.md`)](docs/STATE_MANAGEMENT.md)
    *   How Riverpod (Flutter) and React Hooks manage the complex, real-time application states.
6.  [**MVP Status & Future Scope** (`docs/FUTURE_SCOPE.md`)](docs/FUTURE_SCOPE.md)
    *   The community impact, addressing social stigmas around gyms in India/globally, and the roadmap for future features.

## 🛠️ Tech Stack

### Mobile Application (The Hub)
*   **Framework**: Flutter & Dart
*   **State Management**: Riverpod (`flutter_riverpod`)
*   **3D Rendering**: `model_viewer_plus`
*   **AI Engine**: `google_generative_ai` (Gemini 1.5 Flash)
*   **Health Data**: `health` package (Android Health Connect)

### Web Companion (Motion Capture)
*   **Framework**: React 18, TypeScript, Vite
*   **Computer Vision**: Google MediaPipe Pose (`@mediapipe/tasks-vision`)
*   **3D Graphics**: Three.js, React Three Fiber, Drei (`@react-three/fiber`)
*   **Styling**: Tailwind CSS, Lucide Icons

### Backend & Cloud
*   **Database**: Firebase Firestore
*   **Authentication**: Firebase Auth (Email/Password, Anonymous)

## 🚀 Getting Started

### Prerequisites
*   Flutter SDK (3.x.x)
*   Node.js (18+)
*   Android Studio / Xcode
*   A Firebase Project with Firestore and Auth enabled.

### 1. Mobile App Setup
1. Clone the repository.
2. Navigate to the root directory:
   ```bash
   cd bloomfit
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Create a `.env` file in the root directory and add your Gemini API Key:
   ```env
   GEMINI_API_KEY=your_google_ai_studio_api_key
   ```
5. Run the app on an Android/iOS emulator or physical device:
   ```bash
   flutter run
   ```

### 2. Web Companion Setup
1. Navigate to the web companion directory:
   ```bash
   cd mocap-web
   ```
2. Install Node dependencies:
   ```bash
   npm install
   ```
3. Create a `.env` file inside `mocap-web/` containing your Firebase Web config:
   ```env
   VITE_FIREBASE_API_KEY=your_key
   VITE_FIREBASE_AUTH_DOMAIN=your_domain
   VITE_FIREBASE_PROJECT_ID=your_id
   VITE_FIREBASE_STORAGE_BUCKET=your_bucket
   VITE_FIREBASE_MESSAGING_SENDER_ID=your_sender_id
   VITE_FIREBASE_APP_ID=your_app_id
   ```
4. Start the local development server:
   ```bash
   npm run dev
   ```

## 📖 How to Use the Web Companion
1. Open the **mocap-web** application in your laptop browser.
2. Grant camera permissions. A 4-digit "Pairing Code" will appear in the top right.
3. Open the **BloomFit Mobile App**, select a workout containing a supported exercise (like Squats or Jumping Jacks).
4. Tap **Connect Web Companion** above the Start button.
5. Enter the 4-digit code.
6. Press Start. Step back from your laptop, and watch the app instantly count your reps and correct your form!

## 🤝 Contributing
This project was built as a 3rd-year university EPICS (Engineering Projects in Community Service) final presentation. Contributions, forks, and educational uses are highly encouraged.

## 📄 License
This project is licensed under the MIT License.
