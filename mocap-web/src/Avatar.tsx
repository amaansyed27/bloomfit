import * as THREE from 'three';
import type { PoseData } from './usePose';

type BoneProps = {
    start: THREE.Vector3;
    end: THREE.Vector3;
    color?: string;
    radius?: number;
    visible?: boolean;
};

// Render a cylinder between two points in 3D space
function Bone({ start, end, color = "#4ade80", radius = 0.05, visible = true }: BoneProps) {
    if (!visible) return null;

    const distance = start.distanceTo(end);
    const position = start.clone().lerp(end, 0.5);

    // Create a quaternion to rotate the cylinder to face the end point
    const quaternion = new THREE.Quaternion();
    const up = new THREE.Vector3(0, 1, 0); // Cylinder geometry defaults to Y axis
    const direction = end.clone().sub(start).normalize();
    quaternion.setFromUnitVectors(up, direction);

    return (
        <mesh position={position} quaternion={quaternion}>
            <cylinderGeometry args={[radius, radius, distance, 16]} />
            <meshStandardMaterial color={color} />
        </mesh>
    );
}

function Joint({ position, color = "#facc15", visible = true }: { position: THREE.Vector3, color?: string, visible?: boolean }) {
    if (!visible) return null;
    return (
        <mesh position={position}>
            <sphereGeometry args={[0.06, 16, 16]} />
            <meshStandardMaterial color={color} />
        </mesh>
    );
}

export function Avatar({ poseData }: { poseData: PoseData }) {
    if (!poseData || !poseData.worldLandmarks) {
        return (
            <group>
                <mesh position={[0, 1, 0]}>
                    <boxGeometry args={[0.5, 2, 0.5]} />
                    <meshStandardMaterial color="#64748b" opacity={0.5} transparent />
                </mesh>
            </group>
        ); // Default standing placeholder
    }

    // Map MediaPipe World Landmarks to ThreeJS Space
    const lms = poseData.worldLandmarks;

    // MediaPipe World Landmarks coordinates are usually in meters, Origin at hips.
    // Invert X and Z if tracking mirror is needed, but we'll apply a root rotation if needed later.
    const getVec = (index: number) => {
        // We negate Y because MediaPipe Y goes down, but ThreeJS Y goes up.
        // We negate X to mirror the user properly.
        return new THREE.Vector3(-lms[index].x, -lms[index].y, -lms[index].z);
    };

    const isVisible = (index: number) => {
        return lms[index].visibility !== undefined && lms[index].visibility > 0.6;
    };

    const joints = {
        nose: getVec(0),
        leftShoulder: getVec(11),
        rightShoulder: getVec(12),
        leftElbow: getVec(13),
        rightElbow: getVec(14),
        leftWrist: getVec(15),
        rightWrist: getVec(16),
        leftHip: getVec(23),
        rightHip: getVec(24),
        leftKnee: getVec(25),
        rightKnee: getVec(26),
        leftAnkle: getVec(27),
        rightAnkle: getVec(28),
    };

    const vis = {
        nose: isVisible(0),
        leftShoulder: isVisible(11),
        rightShoulder: isVisible(12),
        leftElbow: isVisible(13),
        rightElbow: isVisible(14),
        leftWrist: isVisible(15),
        rightWrist: isVisible(16),
        leftHip: isVisible(23),
        rightHip: isVisible(24),
        leftKnee: isVisible(25),
        rightKnee: isVisible(26),
        leftAnkle: isVisible(27),
        rightAnkle: isVisible(28),
    };

    const centerShoulder = joints.leftShoulder.clone().add(joints.rightShoulder).multiplyScalar(0.5);
    const centerHip = joints.leftHip.clone().add(joints.rightHip).multiplyScalar(0.5);

    // ROOT OFFSET: Move all joints so the center of the hips rests at local (0,0,0) instead of floating or bending
    // We only apply this if the hips are actually visible, otherwise we use a default center.
    const hipsVisible = vis.leftHip && vis.rightHip;
    const rootOffset = hipsVisible ? centerHip.clone() : new THREE.Vector3(0, 0, 0);

    Object.values(joints).forEach((v) => v.sub(rootOffset));
    centerShoulder.sub(rootOffset);
    centerHip.sub(rootOffset);

    return (
        <group position={[0, 1.5, 0]} scale={[-1.5, 1.5, 1.5]}>
            {/* Torso */}
            <Bone start={centerShoulder} end={centerHip} color="#3b82f6" radius={0.08} visible={vis.leftShoulder || vis.rightShoulder || hipsVisible} />
            <Bone start={joints.leftShoulder} end={joints.rightShoulder} color="#3b82f6" radius={0.08} visible={vis.leftShoulder && vis.rightShoulder} />
            <Bone start={joints.leftHip} end={joints.rightHip} color="#3b82f6" radius={0.08} visible={hipsVisible} />

            {/* Head */}
            <Bone start={centerShoulder} end={joints.nose} color="#f87171" radius={0.05} visible={vis.nose && (vis.leftShoulder || vis.rightShoulder)} />
            <Joint position={joints.nose} color="#ef4444" visible={vis.nose} />

            {/* Left Arm (User's Right physically in mirror) */}
            <Bone start={joints.leftShoulder} end={joints.leftElbow} visible={vis.leftShoulder && vis.leftElbow} />
            <Bone start={joints.leftElbow} end={joints.leftWrist} visible={vis.leftElbow && vis.leftWrist} />
            <Joint position={joints.leftShoulder} visible={vis.leftShoulder} />
            <Joint position={joints.leftElbow} visible={vis.leftElbow} />
            <Joint position={joints.leftWrist} visible={vis.leftWrist} />

            {/* Right Arm (User's Left physically in mirror) */}
            <Bone start={joints.rightShoulder} end={joints.rightElbow} visible={vis.rightShoulder && vis.rightElbow} />
            <Bone start={joints.rightElbow} end={joints.rightWrist} visible={vis.rightElbow && vis.rightWrist} />
            <Joint position={joints.rightShoulder} visible={vis.rightShoulder} />
            <Joint position={joints.rightElbow} visible={vis.rightElbow} />
            <Joint position={joints.rightWrist} visible={vis.rightWrist} />

            {/* Left Leg */}
            <Bone start={joints.leftHip} end={joints.leftKnee} color="#f97316" visible={vis.leftHip && vis.leftKnee} />
            <Bone start={joints.leftKnee} end={joints.leftAnkle} color="#f97316" visible={vis.leftKnee && vis.leftAnkle} />
            <Joint position={joints.leftHip} color="#ea580c" visible={vis.leftHip} />
            <Joint position={joints.leftKnee} color="#ea580c" visible={vis.leftKnee} />
            <Joint position={joints.leftAnkle} color="#ea580c" visible={vis.leftAnkle} />

            {/* Right Leg */}
            <Bone start={joints.rightHip} end={joints.rightKnee} color="#f97316" visible={vis.rightHip && vis.rightKnee} />
            <Bone start={joints.rightKnee} end={joints.rightAnkle} color="#f97316" visible={vis.rightKnee && vis.rightAnkle} />
            <Joint position={joints.rightHip} color="#ea580c" visible={vis.rightHip} />
            <Joint position={joints.rightKnee} color="#ea580c" visible={vis.rightKnee} />
            <Joint position={joints.rightAnkle} color="#ea580c" visible={vis.rightAnkle} />
        </group>
    );
}