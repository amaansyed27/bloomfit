# 🌸 BloomFit

BloomFit is a modern, cross-platform fitness application built with **Flutter** and **Firebase**. It provides users with a seamless experience to track workouts, discover new exercises, and manage their fitness journey with a personalized touch.

---

## 🚀 Features

- **Personalized Onboarding**: Tailored user experience from the first launch.
- **Secure Authentication**: Integration with Google Sign-In and Firebase Auth.
- **Workout Library**: A comprehensive database of exercises with seeding capabilities.
- **Dynamic Theming**: Beautiful UI with smooth animations using `flutter_animate`.
- **State Management**: Robust state handling using `Riverpod`.
- **Navigation**: Clean routing architecture with `GoRouter`.

---

## 🛠️ Technology Stack

- **Framework**: [Flutter](https://flutter.dev/) (Channel stable, 3.10.0+)
- **Backend-as-a-Service**: [Firebase](https://firebase.google.com/)
  - Authentication (Google Sign-In)
  - Cloud Firestore (NoSQL Database)
- **State Management**: [Riverpod](https://riverpod.dev/)
- **Navigation**: [GoRouter](https://pub.dev/packages/go_router)
- **UI & Animations**: 
  - [Google Fonts](https://pub.dev/packages/google_fonts) (Inter, etc.)
  - [Flutter Animate](https://pub.dev/packages/flutter_animate)
  - [Confetti](https://pub.dev/packages/confetti)
- **Architecture**: Feature-based Domain Driven Design (DDD) principles.

---

## 📂 Project Structure

```text
lib/
├── core/               # Shared utilities, themes, and global widgets
│   ├── theme/          # App-wide color schemes and text styles
│   └── widgets/        # Reusable UI components
├── features/           # Domain-specific functionality
│   ├── authentication/ # User login, sign-up, and auth state
│   ├── home/           # Main dashboard and landing views
│   ├── onboarding/     # First-time user flow
│   └── workouts/       # Exercise library, tracking, and seeding
├── firebase_options.dart # Firebase configuration
└── main.dart           # App entry point and providers initialization
```

---

## ⚙️ Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Firebase CLI](https://firebase.google.com/docs/cli)
- Android Studio / VS Code with Flutter extensions.

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/bloomfit.git
   cd bloomfit
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**:
   - Create a new project on the [Firebase Console](https://console.firebase.google.com/).
   - Add Android/iOS/Web apps to your project.
   - Run `flutterfire configure` to generate `firebase_options.dart`.

4. **Run the app**:
   ```bash
   flutter run
   ```

---

## 🧪 Testing

Run all unit and widget tests using:
```bash
flutter test
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

*Made with ❤️ by the BloomFit Team*
