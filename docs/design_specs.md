# Product Design Specifications: "BloomFit"

## 1. Vision & Core Value Proposition
A gamified, hyper-personalized fitness app that turns working out into a rewarding RPG-like experience. Inspired by Duolingo's retention mechanics and MuscleWiki's clarity, it uses a "Path" system to guide users through their fitness journey, adapting daily based on their profile, equipment, and feedback.

**Core Pillars:**
*   **Hyper-Personalization:** Workouts adapt to *everything* (time, equipment, pain points, goals).
*   **Gamification:** Streaks, XP, Leagues, and a visual "Path" progression.
*   **Immersiveness:** High-quality animations, sound effects, and haptic feedback.
*   **Accessibility:** Clear visuals (eventually 3D), simple instructions.

---

## 2. Onboarding Flow (The "Hook")
*Goal: Gather data while convincing the user this app is "made for them".*

**Screen 1: The "Why"**
*   **Question:** "What brings you here?"
*   **Options:** Lose Weight, Build Muscle, Improve Stamina, Mental Clarity, just moving more.
*   **UI:** Large, tappable cards with icons.

**Screen 2: The "Who"**
*   **Inputs:** Gender, Age, Current Weight, Target Weight, Height.
*   **UI:** Smooth sliders/spinners instead of boring text fields.

**Screen 3: Experience Level**
*   **Options:**
    *   *Rookie:* "I'm new to this."
    *   *Casual:* "I work out sometimes."
    *   *Pro:* "I know what I'm doing."
*   **Constraint:** affects exercise difficulty and terminology.

**Screen 4: Logistics (Critical for Personalization)**
*   **Frequency:** Days per week (1-7).
*   **Duration:** Minutes per day (10, 20, 30, 45, 60+).
*   **Equipment:**
    *   "None (Bodyweight only)"
    *   "Basic Home Gym (Dumbbells, Mat)"
    *   "Full Gym Access"
    *   *Multi-select:* Check specific items (Pull-up bar, Bands, Kettlebell).

**Screen 5: The "Promise" (Loading Screen)**
*   **Animation:** "Analyzing your profile...", "Building your path...", "Optimizing for [User Goal]...".
*   **Result:** "We've created a plan that will get you to your goal by [Date]."

**Screen 6: Commitment**
*   **Action:** Set a daily reminder time.
*   **Gamification:** "Start your 1st day streak now!"

---

## 3. Core Features & "The Path" UI

### A. The Home Screen (The Path)
Instead of a calendar or list, the main view is a winding path (like Candy Crush/Duolingo).
*   **Nodes:** Each "step" on the path is a workout session.
*   **State:**
    *   *Locked:* Greyed out (future workouts).
    *   *Active:* Bouncing/Glowing (today's workout).
    *   *Completed:* Gold/Colored checkmark (past workouts).
*   **Chests/Rewards:** Scattered along the path (e.g., every 5 days). Opening them gives XP or flexible "Freeze Streaks".
*   **Boss Battles:** End of a "Unit" (e.g., 4 weeks). A "Challenge Workout" (e.g., AMRAP test) to level up.

### B. The Workout Player
*   **Immersive Intro:** Full-screen animation showing target muscles (MuscleWiki style map).
*   **The Loop:**
    1.  **Preview:** "Next: Push-ups - 3 Sets".
    2.  **Action:** Timer/Rep counter + Video Loop.
    3.  **Rest:** Pulse timer, maybe a "tip of the day" or "breathing guide".
    4.  **Feedback/RPE:** After each exercise: "Too Hard? Too Easy?" (Adapts next set).
*   **Audio:** Text-to-Speech coaching ("Keep your core tight!", "Last 3 reps!").
*   **3D Models (Future):** Rotate/Zoom on the active muscle during the demo.

### C. Gamification Engine
*   **XP (Experience Points):** Earned per workout, per exercise completed.
*   **Streaks:** The #1 retention metric. Fire icon in the header.
*   **Leagues:** "Bronze", "Silver", "Gold". Weekly leaderboards based on XP.
*   **Badges:** Visual achievements (e.g., "Early Bird" for morning workouts, "Iron Clad" for lifting 10,000kg total).

---

## 4. Technical Architecture

### Tech Stack
*   **Frontend:** Flutter (Dart). Cross-platform, high-performance rendering (Impeller engine).
*   **Backend:** Firebase.
    *   **Auth:** Google Sign-In + Email/Password.
    *   **Firestore:** NoSQL DB for User Profiles, Workout History, and the "Path" structure.
    *   **Functions:** Server-side logic for generating workouts (to keep the client light and logic secure).
    *   **Storage:** Hosting video assets/images.

### Data Models (Simplified)

**User Profile**
```json
{
  "uid": "string",
  "stats": { "xp": 1200, "level": 5, "streak": 12 },
  "settings": { "equipment": ["dumbbell"], "days_per_week": 3 },
  "body": { "weight": 75, "height": 180, "gender": "male" }
}
```

**Exercise (The Dataset)**
```json
{
  "id": "pushup_std",
  "name": "Standard Push-up",
  "difficulty": 1, // 1-5
  "muscles": ["chest", "triceps", "front_delt"],
  "equipment": ["none"],
  "type": "strength", // cardio, flexibility, strength
  "assets": {
    "animation": "url",
    "model_3d": "url_future"
  }
}
```

**Workout Generation Algorithm**
*   **Input:** User Equipment, Time Available, Last Workout (to avoid overtraining same muscles).
*   **Logic:**
    1.  Select "Focus" (e.g., Upper Body Push).
    2.  Pick Compound Movement (e.g., Bench Press or Push-up).
    3.  Pick Accessory Movements (e.g., Flys, Tricep Dips).
    4.  Scale sets/reps based on User Level.
    5.  Fill remaining time with core/cardio finisher.

---

## 5. UI/UX & Aesthetics
*   **Theme:** "Classy Playful" (High-end interaction design).
    *   *Concept:* "Apple Health meets Duolingo". Fun physics, but clean layout.
    *   *Backgrounds:* Crisp White (#FFFFFF) with subtle grey surface variances.
    *   *Primary Colors:* Vibrant but not neon.
        *   **Action:** Vivid Coral (#FF6B6B) or Electric Indigo.
        *   **Accents:** Soft pastels for secondary elements to keep it "classy".
    *   **Shapes:** Generous rounded corners (**20-24px**). Soft, approachable, but structured.
*   **Animations:** "Physics-based & Liquid".
    *   *Interactions:* Buttons typically "spring" or scale down on press.
    *   *Navigation:* **Liquid Swipe** transitions between onboarding pages.
    *   *Constraint:* "Don't overdo it." Only key actions trigger bounce. content remains stable.
*   **Typography:** The anchor of professionalism.
    *   *Headings:* **Outfit** or **Plus Jakarta Sans** (Modern, geometric, slightly friendly).
    *   *Body:* **Inter** or **Roboto** (Clean, legible, standard).
*   **Logo:** Professional vector mark.

## 7. Detailed UI Flows (Markdown Mockups)

### Flow 1: Onboarding (The Hook)

**Screen: Welcome**
```text
[ Logo: Abstract Lightning Path ]
-------------------------------
   LEVEL UP YOUR FITNESS
   
   "Your personal path to a 
    stronger you starts here."
   
   [ GET STARTED ] (Neon Green Button)
   [ I ALREADY HAVE AN ACCOUNT ] (Text Link)
-------------------------------
```

**Screen: Goal Selection**
```text
[ < Back ]      Step 1 of 5
-------------------------------
   WHAT'S YOUR MAIN GOAL?
   
   [  LOSE WEIGHT  ] (Icon: Scale)
   [  BUILD MUSCLE ] (Icon: Arm)
   [  GET FITTER   ] (Icon: Heart)
   [  STRESS RELIEF] (Icon: Lotus)
   
   "We'll adapt your path based on this."
-------------------------------
```

**Screen: Logistics (Equipment)**
```text
[ < Back ]      Step 4 of 5
-------------------------------
   WHAT EQUIPMENT DO YOU HAVE?
   
   ( ) No Equipment (Bodyweight only)
   ( ) Basic Home Gym (Dumbbells)
   ( ) Full Gym Access
   
   [v] I have a Pull-up Bar
   [ ] I have Resistance Bands
   
   [ CONTINUE ]
-------------------------------
```

### Flow 2: The Main Path (Home)

**Screen: The Path**
```text
[ Fire Icon: 12 ] [ XP: 1450 ] [ Profile Pic ]
----------------------------------------------
       ( Chest Preview )
          [  START  ] <--- Pulsing Animation
             |
             |
           ( O ) <--- Completed (Gold Check)
          /
         /
      ( O ) <--- Completed
         \
          ( Chest ) <--- Locked (Grey)
----------------------------------------------
[ Path ]  [ Leaderboard ]  [ Quests ]  [ Profile ]
```

### Flow 3: Workout Player

**Screen: Exercise Active**
```text
[ || Pause ]      Set 1/3      [ Next > ]
----------------------------------------------
     (  VIDEO LOOP OF PUSHUP  )
     (  3D Model Overlay Toggle )
----------------------------------------------
   PUSH-UPS
   Target: Chest, Triceps
   
   [  12 REPS  ]  <-- Big Counter
   
   [  DONE  ] (Haptic Feedback on press)
----------------------------------------------
```

**Screen: Feedback (Post-Set)**
```text
----------------------------------------------
   Phew! How was that?
   
   [ TOO EASY ]  [ JUST RIGHT ]  [ TOO HARD ]
   
   "We'll adjust the next set for you."
----------------------------------------------
```

## 8. Gamification Logic (The Addiction Engine)

*   **XP Formula:** [(Duration * 10) + (Difficulty_Multiplier * 5) + (Streak_Bonus)](file:///d:/Programming/02_University/epics/bloomfit/test/widget_test.dart#14-32)
*   **Streak Freeze:** Can be bought with "Gems" earned from completing 5 workouts.
*   **Leagues:** Top 10 users in a league of 50 move up to the next tier (Bronze -> Silver -> Gold -> Diamond).
*   **Daily Quests:**
    *   "Complete a workout before 9 AM"
    *   "Do 50 Pushups total"
    *   "Earn 300 XP"

## 9. Future Roadmap (Post-MVP)
*   **Social:** Add friends, "Nudge" feature.
*   **3D Avatar:** A personalized 3D character that gets "fitter" as you do.
*   **AR Mode:** Place the 3D exercise model in your room.
