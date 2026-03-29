# BloomFit: Viva & Presentation Preparation Guide

This document is designed to help you prepare for your EPICS Phase-2 Viva or final presentation. It breaks down the most complex technical terms used in your individual report, explains exactly how they work in BloomFit, and provides potential examiner questions with ideal answers.

---

## 1. Flutter & UI/UX Architecture

### Concept: Riverpod & Unidirectional Data Flow
**What it is:** Riverpod is a reactive state-management framework for Flutter. "Unidirectional data flow" means data only travels in one direction: State -> UI -> Action -> State. The UI never mutates data directly; it fires an action (like a button press), which updates the state, which automatically redraws the UI.
**How we used it:** We used `StreamProvider` to watch Firebase live data and `StateNotifierProvider` to manage complex local states without cluttering the UI code.

* **Q: Why did you choose Riverpod over standard Provider or setState?**
  * **A:** *Standard Provider relies on the Flutter Widget Tree, which can cause "ProviderNotFound" runtime errors if the widget tree changes. Riverpod is compile-safe, meaning if the code compiles, it won't crash looking for state. It also handles asynchronous data (like Firebase Streams) beautifully with `AsyncValue` (loading, data, error states).*

### Concept: RenderFlex Overflow & Circuit Flow Algorithm
**What it is:** A "RenderFlex Overflow" is Flutter's famous yellow-and-black striped error box. It happens when a Column or Row tries to draw widgets that exceed the physical pixels of the screen.
**How we used it:** Initially, a 3-set exercise stacked 3 checkbox rows. This caused overflows. I engineered the "Circuit Flow Algorithm" to flatten an array of `WorkoutActivity` objects (e.g., `[{Squats: 3 sets}, {Pushups: 3 sets}]`) into a 1D array (`[Squat 1, Pushup 1, Squat 2, Pushup 2...]`).

* **Q: How did you solve the UI clutter on the workout screen?**
  * **A:** *I realized that athletes don't want to scroll while sweating. I wrote an algorithm to flatten the nested loops (exercises containing sets) into a single, linear Circuit queue. This allowed me to render exactly one set per screen (O(1) spatial complexity per page), completely eliminating RenderFlex errors and enforcing better athletic rest periods.*

### Concept: Offline Asset Bundling (.glb files)
**What it is:** `.glb` is the binary version of the glTF (GL Transmission Format) 3D model standard. 
**How we used it:** We used `model_viewer_plus` to render Mixamo 3D coaches. Instead of streaming them, we added them to `pubspec.yaml`'s `assets/models/` folder.

* **Q: Why did you bundle 40MB 3D models into the app instead of streaming them from a server to save APK size?**
  * **A:** *We are targeting users who might be in gyms with terrible Wi-Fi or areas with spotty cellular data. Streaming a 40MB asset every time the user opens an exercise would result in blank screens and high bandwidth costs. By bundling them offline, the APK size is larger initially, but the 3D models render instantly with zero latency, ensuring a flawless user experience.*

---

## 2. React Web Companion & Motion Capture

### Concept: Edge-Computed MediaPipe
**What it is:** "Edge computing" means processing data directly on the user's device (the laptop) rather than sending it to a cloud server (like AWS). Google MediaPipe Pose is an ML model that outputs 33 3D normalized coordinates `(x, y, z)`.
**How we used it:** We process the webcam's `HTMLVideoElement` frames locally via JavaScript `requestAnimationFrame`. 

* **Q: Isn't it a huge privacy risk to have a camera watching the user exercise?**
  * **A:** *Actually, it's the exact opposite because we use Edge Computing. The webcam video frames never leave the user's browser. They are fed directly into the local MediaPipe model running in their RAM, converted to meaningless numbers (x, y, z coordinates), and the video frame is immediately destroyed. Absolutely zero video data is transmitted over the internet or saved to our databases.*

### Concept: Biomechanical Analysis (Vector Mathematics)
**What it is:** Using the 33 points to calculate real-world angles.
**How we used it:** To detect a squat, we need the angle of the knee. We take three 3D vectors: Hip (11), Knee (23), Ankle (27). We use the Dot Product formula `A·B = |A||B|cos(θ)` to find the interior angle. 

* **Q: How does the app actually know when a repetition is completed?**
  * **A:** *I built a state machine backed by vector mathematics. For a squat, I calculate the angle between the hip, knee, and ankle landmarks. If the angle is ~180°, the user is "Standing". When the angle drops below 90°, the state changes to "Descending". When the user stands back up above 160°, the state resets and the rep counter increments. If they don't drop below 90°, the state machine rejects the rep and triggers form feedback like "Go lower!".*

### Concept: 3D Kinematic Mapping (Euler Angles & Quaternions)
**What it is:** Mapping invisible 3D coordinates to a visible 3D skeleton. Quaternions are a complex mathematical number system used in 3D graphics to calculate rotations without encountering "Gimbal Lock" (where 3D axes overlap and break).
**How we used it:** We used React Three Fiber to draw cylinders (bones) between the MediaPipe landmarks (joints). 

* **Q: How did you draw the 3D stick figure over the user's video?**
  * **A:** *MediaPipe gives me raw 3D points. In React Three Fiber, I placed spheres at those exact points. To draw the "bones" connecting them, I calculated the Euclidean distance between two points to set the length of a 3D cylinder. To angle the cylinder correctly so it connects point A to point B, I used 3D LookAt matrices and Quaternions to dynamically rotate the cylinder in 3D space.*

---

## 3. Cloud Backend & Synchronization

### Concept: Distributed NoSQL Database (Firestore)
**What it is:** Unlike SQL databases which use rigid tables, Firestore is a NoSQL document database. Data is stored in JSON-like documents grouped into collections.
**How we used it:** We stored data in shallow subcollections (`users/{uid}/history` and `users/{uid}/paths`).

* **Q: Why did you choose Firebase Firestore over a traditional SQL database like PostgreSQL?**
  * **A:** *Firestore allows for unstructured, flexible data (like varying JSON exercise objects) and inherently supports real-time synchronization. Furthermore, by using nested subcollections, our queries remain "shallow". When we fetch a user's profile, it doesn't accidentally load their entire lifetime workout history, keeping reads lightning-fast and minimizing our cloud billing costs.*

### Concept: The Sub-100ms Handshake Protocol & WebSockets
**What it is:** Standard HTTP requests wait for the client to ask for data. WebSockets (used by Firestore's `onSnapshot`) keep a continuous open pipe, pushing data from the server to the client the millisecond it changes.
**How we used it:** The `live_sessions/1234` document bridges the phone and laptop.

* **Q: How are the phone and the laptop communicating if they aren't connected via Bluetooth?**
  * **A:** *They communicate via a real-time Cloud Firestore document acting as a socket bridge. The web app generates a 4-digit code. The phone enters the code and starts listening to `live_sessions/1234` using a Flutter StreamSubscription. When the web app's MediaPipe engine counts a rep, it overwrites the 'currentReps' field in that cloud document. Firestore instantly pushes that update down the open stream to the phone, updating the UI in under 100 milliseconds.*

---

## 4. Generative AI (Gemini 3 Flash)

### Concept: Prompt Engineering & Structured JSON Output
**What it is:** Carefully crafting the text sent to an AI so it behaves predictably.
**How we used it:** The Flutter app parses strings to build the UI. If Gemini returns "Hey! Here is your workout: Squats...", the app crashes because it expects code, not a chatty response. We forced Gemini to return pure JSON schema.

* **Q: LLMs (Large Language Models) are known to hallucinate or be unpredictable. How do you ensure the app doesn't crash when Gemini generates a workout?**
  * **A:** *Through strict prompt engineering. In the system instructions, I explicitly mandate that Gemini must return the output formatted strictly against a JSON schema I provided. It is not allowed to add conversational text like "Sure, here is your plan." The Flutter app then parses this deterministic JSON directly into Dart models. If the JSON is malformed, we catch the exception and safely retry.*

### Concept: Context Window Optimization & Historical Parsing
**What it is:** The "Context Window" is how much text the AI can "remember" or process in one request. Every word costs "tokens" (money).
**How we used it:** Instead of sending the user's entire database history to Gemini, we compress it.

* **Q: How does the AI know to avoid exercises the user has skipped in the past? Do you send their entire workout history to the API?**
  * **A:** *Sending raw workout history would waste massive amounts of API tokens, increase cloud costs, and slow down response times. I built a data-compression middleware layer in Dart. When generating a prompt, my code aggregates the user's history, throwing away generic successful workouts, and extracts only high-value anomalies. I pass a condensed string like: `Skipped: [Squats (Reason: Knee Pain)]`. This highly optimized context forces Gemini to substitute squats with low-impact alternatives like glute bridges while saving bandwidth and tokens.*