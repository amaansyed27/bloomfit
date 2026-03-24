String getGlbPathForExercise(String exerciseName) {
  final name = exerciseName.toLowerCase();
  if (name.contains('squat')) return 'assets/models/squats.glb';
  if (name.contains('jump')) return 'assets/models/jumping_jacks.glb';
  if (name.contains('push')) return 'assets/models/pushup.glb';
  if (name.contains('plank')) return 'assets/models/plank.glb';
  if (name.contains('curl')) return 'assets/models/bicep_curl.glb';
  if (name.contains('sit') || name.contains('crunch'))
    return 'assets/models/sit_up.glb';
  if (name.contains('knee') || name.contains('run'))
    return 'assets/models/running.glb';
  if (name.contains('burpee')) return 'assets/models/burpee.glb';
  return 'assets/models/cheer.glb'; // Fallback
}
