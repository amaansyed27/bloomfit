class WorkoutActivity {
  final String exerciseId;
  final int? sets;
  final int? reps;
  final int? durationSeconds;
  final String? notes;

  WorkoutActivity({
    required this.exerciseId,
    this.sets,
    this.reps,
    this.durationSeconds,
    this.notes,
  });

  factory WorkoutActivity.fromJson(Map<String, dynamic> json) {
    return WorkoutActivity(
      exerciseId: json['exerciseId'] as String,
      sets: json['sets'] as int?,
      reps: json['reps'] as int?,
      durationSeconds: json['durationSeconds'] as int?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      if (sets != null) 'sets': sets,
      if (reps != null) 'reps': reps,
      if (durationSeconds != null) 'durationSeconds': durationSeconds,
      if (notes != null) 'notes': notes,
    };
  }
}
