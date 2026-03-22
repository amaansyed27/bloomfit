class ExerciseModel {
  final String id;
  final String name;
  final String bodyPart; // Chest, Back, Legs, Arms, Shoulders, Core
  final String equipment; // Bodyweight, Dumbbell, Barbell, Machine
  final String difficulty; // Beginner, Intermediate, Advanced
  final List<String> instructions;
  final String imageUrl;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.bodyPart,
    required this.equipment,
    required this.difficulty,
    required this.instructions,
    required this.imageUrl,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json, String id) {
    return ExerciseModel(
      id: id,
      name: json['name'] ?? '',
      bodyPart: json['bodyPart'] ?? '',
      equipment: json['equipment'] ?? '',
      difficulty: json['difficulty'] ?? 'Beginner',
      instructions: List<String>.from(json['instructions'] ?? []),
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'bodyPart': bodyPart,
      'equipment': equipment,
      'difficulty': difficulty,
      'instructions': instructions,
      'imageUrl': imageUrl,
    };
  }

  factory ExerciseModel.empty() {
    return ExerciseModel(
      id: '',
      name: '',
      bodyPart: '',
      equipment: '',
      difficulty: '',
      instructions: [],
      imageUrl: '',
    );
  }
}
