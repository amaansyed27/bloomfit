import { useRef, useEffect, useState } from 'react';
import { Canvas } from '@react-three/fiber';
import { OrbitControls, Environment, Grid } from '@react-three/drei';
import { Camera, Activity, Settings, Smartphone } from 'lucide-react';
import { usePose } from './usePose';
import { Avatar } from './Avatar';
import { db, doc, onSnapshot, setDoc, serverTimestamp } from './firebase';
import { useRepCounter } from './useRepCounter';

function App() {
  const videoRef = useRef<HTMLVideoElement>(null);
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const { poseData, isLoaded } = usePose(videoRef);
  const [cameraAccess, setCameraAccess] = useState(false);
  
  // Firebase Bridge State
  const [sessionCode, setSessionCode] = useState<string>('');
  const [liveExercise, setLiveExercise] = useState<any>(null);

  // Mocap Rep Counter logic
  const { reps, feedback } = useRepCounter(poseData, liveExercise?.exerciseName);

  useEffect(() => {
    // Generate a 4 digit code
    const code = Math.floor(1000 + Math.random() * 9000).toString();
    setSessionCode(code);

    // Initialize the session document in Firestore
    const sessionRef = doc(db, 'live_sessions', code);
    setDoc(sessionRef, {
      status: 'waiting_for_connection',
      createdAt: serverTimestamp()
    });

    // Listen to changes from the mobile app
    const unsubscribe = onSnapshot(sessionRef, (snapshot) => {
      if (snapshot.exists()) {
        const data = snapshot.data();
        if (data.status === 'active') {
          setLiveExercise(data);
        } else if (data.status === 'ended') {
          setLiveExercise(null);
        }
      }
    });

    return () => unsubscribe();
  }, []);

  // Sync Reps back to Firebase
  useEffect(() => {
    if (!liveExercise || !sessionCode) return;
    const sessionRef = doc(db, 'live_sessions', sessionCode);
    setDoc(sessionRef, {
      currentReps: reps,
      formFeedback: feedback,
      updatedAt: serverTimestamp()
    }, { merge: true });
  }, [reps, feedback, sessionCode, liveExercise]);

  useEffect(() => {
    async function setupCamera() {
      try {
        const stream = await navigator.mediaDevices.getUserMedia({
          video: { width: 640, height: 480, facingMode: 'user' }
        });
        if (videoRef.current) {
          videoRef.current.srcObject = stream;
          setCameraAccess(true);
        }
      } catch (err) {
        console.error("Camera access denied!", err);
        setCameraAccess(false);
      }
    }
    setupCamera();
  }, []);

  // Draw 2D Landmarks on the video canvas overlay
  useEffect(() => {
    if (!poseData || !canvasRef.current || !videoRef.current) return;
    const ctx = canvasRef.current.getContext('2d');
    if (!ctx) return;

    ctx.clearRect(0, 0, canvasRef.current.width, canvasRef.current.height);
    ctx.fillStyle = '#10b981';
    ctx.strokeStyle = '#ffffff';
    ctx.lineWidth = 2;

    const lms = poseData.landmarks;
    if (!lms) return;

    // Draw the 33 joints
    for (const lm of lms) {
      if (lm.visibility && lm.visibility > 0.5) {
        ctx.beginPath();
        // MediaPipe coords are 0.0-1.0
        ctx.arc(lm.x * canvasRef.current.width, lm.y * canvasRef.current.height, 4, 0, 2 * Math.PI);
        ctx.fill();
        ctx.stroke();
      }
    }
  }, [poseData]);


  return (
    <div className="h-screen w-screen bg-slate-900 text-slate-100 flex overflow-hidden font-sans">

      {/* Sidebar */}
      <div className="w-16 bg-slate-950 border-r border-slate-800 flex flex-col items-center py-6 gap-8 shrink-0 z-10">
        <div className="p-3 bg-emerald-500/20 rounded-xl text-emerald-400">
          <Activity size={24} />
        </div>
        <div className="p-3 text-slate-500 hover:text-slate-300 cursor-pointer transition-colors">
          <Camera size={24} />
        </div>
        <div className="p-3 text-slate-500 hover:text-slate-300 cursor-pointer transition-colors mt-auto">
          <Settings size={24} />
        </div>
      </div>

      {/* Main 3D Viewport */}
      <div className="flex-1 relative cursor-move">
        <Canvas camera={{ position: [0, 1.5, 4], fov: 45 }}>
          <ambientLight intensity={0.5} />
          <directionalLight position={[10, 10, 5]} intensity={1.5} castShadow />
          <directionalLight position={[-10, -10, -5]} intensity={0.5} color="#3b82f6" />

          <Environment preset="city" />

          <group position={[0, -1, 0]}>
            <Grid infiniteGrid fadeDistance={20} sectionColor="#475569" cellColor="#334155" />
            <Avatar poseData={poseData} />
          </group>

          <OrbitControls target={[0, 1, 0]} maxPolarAngle={Math.PI / 2 + 0.1} />
        </Canvas>

        {/* Top Header Overlay */}
        <div className="absolute top-6 left-8 pointer-events-none">
          <h1 className="text-3xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-emerald-400 to-cyan-400 drop-shadow-sm">
            Web Motion Capture
          </h1>
          <p className="text-slate-400 mt-1 drop-shadow-md">
            {isLoaded ? "MediaPipe Active • Tracking 33 Landmarks" : "Initializing AI Models..."}
          </p>

          <div className="mt-6 pointer-events-auto bg-slate-800/80 backdrop-blur-md border border-slate-700 p-4 rounded-xl shadow-xl w-72">
            {liveExercise ? (
              <div className="flex flex-col gap-2">
                <div className="flex items-center gap-2 text-emerald-400">
                  <Smartphone size={18} className="animate-pulse" />
                  <span className="font-semibold text-sm">Phone Connected</span>
                </div>
                <h2 className="text-2xl font-bold text-white">{liveExercise.exerciseName}</h2>
                <div className="flex justify-between text-slate-300">
                  <span>Target Reps: <strong className="text-white">{liveExercise.targetReps}</strong></span>
                  <span>Duration: <strong className="text-white">{liveExercise.targetDuration}s</strong></span>
                </div>
                {/* Live Rep Counter */}
                <div className="mt-2 flex flex-col items-center p-4 rounded-lg bg-emerald-500/10 border border-emerald-500/20">
                  <div className="text-5xl font-black text-emerald-400">
                    {reps}
                  </div>
                  <span className="text-sm font-medium text-emerald-500 mt-1 uppercase tracking-wider">Current Reps</span>
                </div>
                <div className="mt-2 text-center py-2 px-3 bg-slate-800 rounded text-slate-300 text-sm font-medium border border-slate-700">
                  {feedback}
                </div>
              </div>
            ) : (
              <div className="flex flex-col items-center justify-center py-2">
                <p className="text-sm text-slate-400 mb-2">Pairing Code</p>
                <div className="text-4xl font-mono font-bold tracking-[0.2em] text-cyan-400">
                  {sessionCode || "..."}
                </div>
                <p className="text-xs text-slate-500 mt-2 text-center">
                  Enter this code in the BloomFit mobile app settings to sync live workouts.
                </p>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Camera Feed Panel */}
      <div className="w-80 bg-slate-900 border-l border-slate-800 p-4 shrink-0 shadow-2xl z-10 flex flex-col">
        <h2 className="text-sm uppercase tracking-wider font-semibold text-slate-400 mb-4">Live Camera</h2>

        <div className="relative w-full aspect-[4/3] bg-slate-950 rounded-lg overflow-hidden border border-slate-800">
          <video
            ref={videoRef}
            className="absolute inset-0 w-full h-full object-cover transform -scale-x-100"
            autoPlay
            playsInline
            muted
          />
          <canvas
            ref={canvasRef}
            className="absolute inset-0 w-full h-full z-10"
            width={640}
            height={480}
            style={{ transform: "scaleX(-1)" }}
          />

          {!cameraAccess && (
            <div className="absolute inset-0 flex items-center justify-center text-slate-500 bg-slate-900/80 z-20">
              <span className="text-sm">Waiting for camera...</span>
            </div>
          )}
        </div>

        <div className="mt-6 flex-1">
          <h2 className="text-sm uppercase tracking-wider font-semibold text-slate-400 mb-4">Diagnostics</h2>

          <div className="space-y-3">
            <div className="bg-slate-800/50 p-3 rounded-lg flex items-center justify-between border border-slate-700/50">
              <span className="text-slate-300">Model Load</span>
              {isLoaded ?
                <span className="text-emerald-400 font-medium">Ready</span> :
                <span className="text-amber-400 flex items-center gap-2">
                  <div className="w-2 h-2 bg-amber-400 rounded-full animate-pulse" />
                  Loading
                </span>
              }
            </div>

            <div className="bg-slate-800/50 p-3 rounded-lg flex items-center justify-between border border-slate-700/50">
              <span className="text-slate-300">Tracking</span>
              {poseData ?
                <span className="text-emerald-400 font-medium font-mono text-sm">Active</span> :
                <span className="text-slate-500 font-medium text-sm">Waiting...</span>
              }
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

export default App;
