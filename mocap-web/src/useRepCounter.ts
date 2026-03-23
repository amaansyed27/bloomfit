import { useState, useEffect, useRef } from 'react';

// Landmark indices from MediaPipe Pose
// 11: left shoulder, 13: left elbow, 15: left wrist
// 12: right shoulder, 14: right elbow, 16: right wrist
// 23: left hip, 25: left knee, 27: left ankle
// 24: right hip, 26: right knee, 28: right ankle

const calculateAngle = (a: any, b: any, c: any) => {
    const radians = Math.atan2(c.y - b.y, c.x - b.x) - Math.atan2(a.y - b.y, a.x - b.x);
    let angle = Math.abs((radians * 180.0) / Math.PI);
    if (angle > 180.0) {
        angle = 360 - angle;
    }
    return angle;
};

export function useRepCounter(poseData: any, exerciseName: string | null) {
    const [reps, setReps] = useState(0);
    const [feedback, setFeedback] = useState<string>('');
    const stateRef = useRef<'up' | 'down'>('up');

    useEffect(() => {
        if (!poseData || !poseData.landmarks || !exerciseName) return;

        const lms = poseData.landmarks;

        const leftShoulder = lms[11];
        const leftElbow = lms[13];
        const leftWrist = lms[15];
        const rightWrist = lms[16];
        
        const leftHip = lms[23];
        const rightHip = lms[24];
        const leftKnee = lms[25];
        const rightKnee = lms[26];
        const leftAnkle = lms[27];
        const rightAnkle = lms[28];

        const isVisible = (lm: any) => lm && lm.visibility > 0.3; // slightly more forgiving for lower body

        const lowerName = exerciseName.toLowerCase();

        // 1. SQUATS
        if (lowerName.includes('squat')) {
            const leftVis = (leftHip?.visibility || 0) + (leftKnee?.visibility || 0) + (leftAnkle?.visibility || 0);
            const rightVis = (rightHip?.visibility || 0) + (rightKnee?.visibility || 0) + (rightAnkle?.visibility || 0);
            
            // Track the leg that is most visible to the camera
            const useLeft = leftVis >= rightVis;
            const hip = useLeft ? leftHip : rightHip;
            const knee = useLeft ? leftKnee : rightKnee;
            const ankle = useLeft ? leftAnkle : rightAnkle;

            if (isVisible(hip) && isVisible(knee) && isVisible(ankle)) {
                // To prevent "kicking" from counting as a squat, ensure both feet are planted (roughly same Y level in screen space)
                const feetPlanted = isVisible(leftAnkle) && isVisible(rightAnkle) 
                                      ? Math.abs(leftAnkle.y - rightAnkle.y) < 0.15 
                                      : true; // fallback if only one side is seen at all

                if (!feetPlanted) {
                    setFeedback('Keep both feet planted!');
                } else {
                    const kneeAngle = calculateAngle(hip, knee, ankle);
                    
                    if (kneeAngle > 150) {
                        if (stateRef.current === 'down') {
                            setReps(r => r + 1);
                            setFeedback('Good squat!');
                        }
                        stateRef.current = 'up';
                    } else if (kneeAngle < 100) {
                        stateRef.current = 'down';
                    } else {
                        setFeedback(stateRef.current === 'up' ? 'Go lower!' : 'Push up!');
                    }
                }
            } else {
                setFeedback('Make sure your full body is in frame.');
            }
        }

        // 2. BICEP CURL
        else if (lowerName.includes('curl')) {
            if (isVisible(leftShoulder) && isVisible(leftElbow) && isVisible(leftWrist)) {
                const elbowAngle = calculateAngle(leftShoulder, leftElbow, leftWrist);
                if (elbowAngle > 160) {
                    if (stateRef.current === 'down') {
                        setReps(r => r + 1);
                        setFeedback('Nice curl!');
                    }
                    stateRef.current = 'up';
                } else if (elbowAngle < 30) {
                    stateRef.current = 'down';
                }
            } else {
                setFeedback('Show your arm to the camera.');
            }
        }

        // 3. JUMPING JACKS
        else if (lowerName.includes('jack')) {
            if (isVisible(leftWrist) && isVisible(rightWrist) && isVisible(leftAnkle) && isVisible(rightAnkle)) {
                // Simplistic distance check
                const handDist = Math.abs(leftWrist.x - rightWrist.x);
                const footDist = Math.abs(leftAnkle.x - rightAnkle.x);
                
                if (handDist < 0.2 && footDist > 0.3) {
                    stateRef.current = 'down'; // Arms up, legs apart
                } else if (handDist > 0.4 && footDist < 0.2) {
                    if (stateRef.current === 'down') {
                        setReps(r => r + 1);
                        setFeedback('Keep it up!');
                    }
                    stateRef.current = 'up'; // Arms down, legs together
                }
            }
        }
        
        // 4. PUSHUP
        else if (lowerName.includes('push')) {
            if (isVisible(leftShoulder) && isVisible(leftElbow) && isVisible(leftWrist)) {
                const elbowAngle = calculateAngle(leftShoulder, leftElbow, leftWrist);
                if (elbowAngle > 160) {
                    if (stateRef.current === 'down') {
                        setReps(r => r + 1);
                        setFeedback('Good push!');
                    }
                    stateRef.current = 'up';
                } else if (elbowAngle < 90) {
                    stateRef.current = 'down';
                }
            }
        }

        // 5. LUNGE
        else if (lowerName.includes('lunge')) {
             if (isVisible(leftHip) && isVisible(leftKnee) && isVisible(leftAnkle)) {
                const kneeAngle = calculateAngle(leftHip, leftKnee, leftAnkle);
                if (kneeAngle > 160) {
                    if (stateRef.current === 'down') {
                        setReps(r => r + 1);
                        setFeedback('Great lunge!');
                    }
                    stateRef.current = 'up';
                } else if (kneeAngle < 90) {
                    stateRef.current = 'down';
                }
            }
        }

        // 6. PLANK (Timer based)
        else if (lowerName.includes('plank')) {
            if (isVisible(leftShoulder) && isVisible(leftHip) && isVisible(leftAnkle)) {
                const bodyAngle = calculateAngle(leftShoulder, leftHip, leftAnkle);
                if (bodyAngle > 160) {
                    setFeedback('Hold it... Good form!');
                    // reps can be used as seconds held in the calling component, or just feedback
                } else {
                    setFeedback('Keep your back straight!');
                }
            }
        }

    }, [poseData, exerciseName]);

    // Reset reps when exercise changes
    useEffect(() => {
        setReps(0);
        setFeedback('Ready.');
    }, [exerciseName]);

    return { reps, feedback };
}