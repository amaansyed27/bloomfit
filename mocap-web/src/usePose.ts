import { useEffect, useRef, useState } from 'react';
import { PoseLandmarker, FilesetResolver } from '@mediapipe/tasks-vision';

export type NormalizedLandmark = {
    x: number;
    y: number;
    z: number;
    visibility: number;
};

export type PoseData = {
    landmarks: NormalizedLandmark[];
    worldLandmarks: NormalizedLandmark[];
} | null;

// The EMA alpha value (0.0 to 1.0). Lower = smoother but more lag. Higher = faster but more jitter.
const SMOOTHING_ALPHA = 0.2;

export function usePose(videoRef: React.RefObject<HTMLVideoElement | null>) {
    const [poseData, setPoseData] = useState<PoseData>(null);
    const [isLoaded, setIsLoaded] = useState(false);
    const poseLandmarkerRef = useRef<PoseLandmarker | null>(null);
    const requestRef = useRef<number>(0);
    const lastVideoTimeRef = useRef<number>(-1);

    // Store the smoothed landmarks across frames
    const smoothedWorldLandmarksRef = useRef<NormalizedLandmark[] | null>(null);

    useEffect(() => {
        let active = true;

        async function init() {
            try {
                const vision = await FilesetResolver.forVisionTasks(
                    "https://cdn.jsdelivr.net/npm/@mediapipe/tasks-vision@latest/wasm"
                );
                const landmarker = await PoseLandmarker.createFromOptions(vision, {
                    baseOptions: {
                        modelAssetPath: "https://storage.googleapis.com/mediapipe-models/pose_landmarker/pose_landmarker_lite/float16/1/pose_landmarker_lite.task",
                        delegate: "GPU"
                    },
                    runningMode: "VIDEO",
                    numPoses: 1,
                    minPoseDetectionConfidence: 0.5,
                    minPosePresenceConfidence: 0.5,
                    minTrackingConfidence: 0.5,
                });

                if (active) {
                    poseLandmarkerRef.current = landmarker;
                    setIsLoaded(true);
                }
            } catch (e) {
                console.error("Error loading MediaPipe Pose Landmarker:", e);
            }
        }

        init();

        return () => {
            active = false;
            if (poseLandmarkerRef.current) {
                poseLandmarkerRef.current.close();
            }
        };
    }, []);

    useEffect(() => {
        if (!isLoaded || !videoRef.current) return;

        const video = videoRef.current;

        const tick = () => {
            if (video.currentTime !== lastVideoTimeRef.current && poseLandmarkerRef.current && video.readyState >= 2) {
                lastVideoTimeRef.current = video.currentTime;

                try {
                    const result = poseLandmarkerRef.current.detectForVideo(video, performance.now());
                    if (result.landmarks && result.landmarks.length > 0) {
                        const rawWorldLms = (result.worldLandmarks && result.worldLandmarks.length > 0) ? result.worldLandmarks[0] : null;

                        let finalWorldLms = null;

                        if (rawWorldLms) {
                            // Apply EMA smoothing to World Landmarks safely
                            if (!smoothedWorldLandmarksRef.current) {
                                smoothedWorldLandmarksRef.current = rawWorldLms.map(lm => ({ ...lm }));
                            } else {
                                for (let i = 0; i < Math.min(rawWorldLms.length, smoothedWorldLandmarksRef.current.length); i++) {
                                    const current = smoothedWorldLandmarksRef.current[i];
                                    const target = rawWorldLms[i];
                                    current.x = current.x + SMOOTHING_ALPHA * (target.x - current.x);
                                    current.y = current.y + SMOOTHING_ALPHA * (target.y - current.y);
                                    current.z = current.z + SMOOTHING_ALPHA * (target.z - current.z);
                                    current.visibility = target.visibility; // Keep visibility instantaneous
                                }
                            }
                            finalWorldLms = smoothedWorldLandmarksRef.current.map(lm => ({ ...lm }));
                        } else {
                            smoothedWorldLandmarksRef.current = null;
                        }

                        setPoseData({
                            landmarks: result.landmarks[0], // Keep 2D landmarks raw for pure tracking response
                            worldLandmarks: finalWorldLms || []
                        });
                    } else {
                        setPoseData(null);
                        smoothedWorldLandmarksRef.current = null; // Reset smoothing if tracking lost
                    }
                } catch (e) {
                    console.error("Detect error:", e);
                }
            }
            requestRef.current = requestAnimationFrame(tick);
        };

        if (video.readyState >= 2) {
            requestRef.current = requestAnimationFrame(tick);
        } else {
            video.addEventListener("loadeddata", () => {
                requestRef.current = requestAnimationFrame(tick);
            });
        }

        return () => {
            cancelAnimationFrame(requestRef.current);
        };
    }, [isLoaded, videoRef]);

    return { poseData, isLoaded };
}
