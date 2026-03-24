String getGlbPathForExercise(String exerciseName) {
  const String baseUrl = 'https://raw.githubusercontent.com/amaansyed27/bloomfit/main/assets/models';
  final name = exerciseName.toLowerCase();
  if (name.contains('squat')) return '$baseUrl/squats.glb';
  if (name.contains('jump')) return '$baseUrl/jumping_jacks.glb';
  if (name.contains('push')) return '$baseUrl/pushup.glb';
  if (name.contains('plank')) return '$baseUrl/plank.glb';
  if (name.contains('curl')) return '$baseUrl/bicep_curl.glb';
  if (name.contains('sit') || name.contains('crunch')) return '$baseUrl/sit_up.glb';
  if (name.contains('knee') || name.contains('run')) return '$baseUrl/running.glb';
  if (name.contains('burpee')) return '$baseUrl/burpee.glb';
  return '$baseUrl/cheer.glb'; // Fallback
}
