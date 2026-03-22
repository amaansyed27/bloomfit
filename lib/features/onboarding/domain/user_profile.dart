enum ExperienceLevel { rookie, casual, pro }

enum Gender { male, female, other }

enum Goal { weightLoss, buildMuscle, getFitter, stressRelief }

class UserProfile {
  final String uid;
  final String email;
  final String? displayName;
  final Gender? gender;
  final int? age;
  final double? weight;
  final double? height;
  final double? targetWeight;
  final ExperienceLevel experienceLevel;
  final Goal primaryGoal;
  final List<String> equipment;
  final int daysPerWeek;
  final int durationMinutes;
  final int xp;
  final int streak;
  final int level;
  final int planDurationMonths;

  UserProfile({
    required this.uid,
    required this.email,
    this.displayName,
    this.gender,
    this.age,
    this.weight,
    this.height,
    this.targetWeight,
    this.experienceLevel = ExperienceLevel.rookie,
    this.primaryGoal = Goal.getFitter,
    this.equipment = const [],
    this.daysPerWeek = 3,
    this.durationMinutes = 30,
    this.xp = 0,
    this.streak = 0,
    this.level = 1,
    this.planDurationMonths = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'gender': gender?.name,
      'age': age,
      'weight': weight,
      'height': height,
      'targetWeight': targetWeight,
      'experienceLevel': experienceLevel.name,
      'primaryGoal': primaryGoal.name,
      'equipment': equipment,
      'daysPerWeek': daysPerWeek,
      'durationMinutes': durationMinutes,
      'xp': xp,
      'streak': streak,
      'level': level,
      'planDurationMonths': planDurationMonths,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, String id) {
    return UserProfile(
      uid: id,
      email: map['email'] ?? '',
      displayName: map['displayName'],
      gender: map['gender'] != null
          ? Gender.values.byName(map['gender'])
          : null,
      age: map['age'],
      weight: (map['weight'] as num?)?.toDouble(),
      height: (map['height'] as num?)?.toDouble(),
      targetWeight: (map['targetWeight'] as num?)?.toDouble(),
      experienceLevel: ExperienceLevel.values.byName(
        map['experienceLevel'] ?? 'rookie',
      ),
      primaryGoal: Goal.values.byName(map['primaryGoal'] ?? 'getFitter'),
      equipment: List<String>.from(map['equipment'] ?? []),
      daysPerWeek: map['daysPerWeek'] ?? 3,
      durationMinutes: map['durationMinutes'] ?? 30,
      xp: map['xp'] ?? 0,
      streak: map['streak'] ?? 0,
      level: map['level'] ?? 1,
      planDurationMonths: map['planDurationMonths'] ?? 1,
    );
  }
}
