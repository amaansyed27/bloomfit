import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/path_models.dart';
import '../../workouts/data/models/exercise_model.dart';
import 'package:bloomfit/features/onboarding/domain/user_profile.dart';
import '../domain/workout_activity.dart';

class PathGenerationService {
  final FirebaseFirestore _firestore;

  PathGenerationService(this._firestore);

  Future<List<ExerciseModel>> _fetchAllExercises() async {
    final snapshot = await _firestore.collection('exercises').get();
    return snapshot.docs
        .map((doc) => ExerciseModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  // Renamed and updated to return WorkoutActivity list
  List<WorkoutActivity> _pickRandomActivities(
    List<ExerciseModel> allExercises,
    NodeType type,
  ) {
    if (type == NodeType.rest) return [];

    final relevant = allExercises.where((e) {
      if (type == NodeType.cardio) return e.bodyPart.toLowerCase() == 'cardio';
      if (type == NodeType.yoga)
        return false; // Assuming no yoga exercises in seed yet
      return e.bodyPart.toLowerCase() != 'cardio' &&
          e.bodyPart.toLowerCase() !=
              'yoga'; // Strength defaults to everything else
    }).toList();

    if (relevant.isEmpty) return [];

    relevant.shuffle();
    return relevant
        .take(5)
        .map(
          (e) => WorkoutActivity(
            exerciseId: e.id,
            sets: 3,
            reps: 12,
            notes: "Standard set",
          ),
        )
        .toList();
  }

  // Helper to format exercises for the AI prompt
  String _formatExerciseList(List<ExerciseModel> exercises) {
    // Limit to avoid context overflow if list is huge, though 50-100 is fine.
    // Format: "id: Name (BodyPart)"
    return exercises
        .map((e) => '- "${e.id}": ${e.name} (${e.bodyPart})')
        .join('\n');
  }

  Future<void> generatePathForUser(UserProfile profile) async {
    final userPathRef = _firestore
        .collection('users')
        .doc(profile.uid)
        .collection('path_nodes');

    // Check if path already exists
    final snapshot = await userPathRef.orderBy('position').limit(1).get();
    if (snapshot.docs.isNotEmpty) {
      debugPrint(
        "PathGenerationService: Path already exists for ${profile.uid}",
      );
      return; // Path already exists
    }

    debugPrint(
      "PathGenerationService: Generating new path for ${profile.uid}...",
    );

    // Fetch all exercises once
    final allExercises = await _fetchAllExercises();
    debugPrint(
      "PathGenerationService: Fetched ${allExercises.length} exercises from seed.",
    );

    try {
      debugPrint("PathGenerationService: Attempting Gemini generation...");
      final generatedNodes = await _generateWithGemini(profile, allExercises);
      debugPrint(
        "PathGenerationService: Gemini generated ${generatedNodes.length} nodes.",
      );
      await _saveNodesToFirestore(userPathRef, generatedNodes);
      debugPrint("PathGenerationService: Saved Gemini nodes to Firestore.");
    } catch (e) {
      debugPrint(
        'PathGenerationService: Gemini generation failed: $e. Falling back to basic logic.',
      );
      final fallbackNodes = _generateBasicPath(profile, allExercises);
      debugPrint(
        "PathGenerationService: Generated ${fallbackNodes.length} fallback nodes.",
      );
      await _saveNodesToFirestore(userPathRef, fallbackNodes);
      debugPrint("PathGenerationService: Saved fallback nodes to Firestore.");
    }
  }

  Future<List<PathNodeData>> _generateWithGemini(
    UserProfile profile,
    List<ExerciseModel> allExercises,
  ) async {
    final schema = Schema.array(
      items: Schema.object(
        properties: {
          'title': Schema.string(),
          'type': Schema.enumString(
            enumValues: ['strength', 'cardio', 'yoga', 'rest'],
          ),
          'activities': Schema.array(
            items: Schema.object(
              properties: {
                'exerciseId': Schema.string(),
                'sets': Schema.integer(),
                'reps': Schema.integer(),
                'durationSeconds': Schema.integer(),
                'notes': Schema.string(),
              },
              optionalProperties: ['sets', 'reps', 'durationSeconds', 'notes'],
            ),
          ),
        },
      ),
    );

    final model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.5-flash',
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: schema,
      ),
    );

    final prompt =
        '''
    Act as an expert fitness coach. Create a 7-day workout plan for:
    - Age: ${profile.age}, Weight: ${profile.weight}kg, Goal: ${profile.primaryGoal.name}
    - Equipment: ${profile.equipment.join(', ')}
    - Duration: ${profile.durationMinutes} min/session

    Available exercises (ID: Name):
    ${_formatExerciseList(allExercises)}

    Generate a 7-day plan using strictly the allowed exercise IDs.
    For REST days, provide an empty activities list.
    Type must be one of: strength, cardio, yoga, rest.
    ''';

    final response = await model.generateContent([Content.text(prompt)]);
    final jsonString = response.text;

    if (jsonString == null) throw Exception("Empty response from AI");

    final cleanedText = jsonString
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();
    final List<dynamic> jsonList = jsonDecode(cleanedText);

    List<PathNodeData> nodes = [];
    for (int i = 0; i < jsonList.length; i++) {
      final item = jsonList[i];
      final typeStr = item['type']?.toString().toLowerCase() ?? 'strength';
      final type = NodeType.values.firstWhere(
        (e) => e.name == typeStr,
        orElse: () => NodeType.strength,
      );

      List<WorkoutActivity> activities = [];
      if (item['activities'] != null) {
        activities = (item['activities'] as List)
            .map((a) {
              return WorkoutActivity(
                exerciseId: a['exerciseId'] ?? '',
                sets: a['sets'],
                reps: a['reps'],
                durationSeconds: a['durationSeconds'],
                notes: a['notes'],
              );
            })
            .where((a) => a.exerciseId.isNotEmpty)
            .toList();
      }

      // Fallback if AI returns no activities for a non-rest day
      if (activities.isEmpty && type != NodeType.rest) {
        activities = _pickRandomActivities(allExercises, type);
      }

      nodes.add(
        PathNodeData(
          id: 'node_$i',
          title: item['title'] ?? 'Day ${i + 1}',
          type: type,
          state: i == 0 ? PathNodeState.active : PathNodeState.locked,
          position: i,
          activities: activities, // Updated to use activities
        ),
      );
    }
    return nodes;
  }

  List<PathNodeData> _generateBasicPath(
    UserProfile profile,
    List<ExerciseModel> allExercises,
  ) {
    List<PathNodeData> nodes = [];
    final types = [
      NodeType.strength,
      NodeType.cardio,
      NodeType.strength,
      NodeType.rest,
      NodeType.strength,
      NodeType.cardio,
      NodeType.yoga,
    ];

    // The basic path now generates a fixed 7-day cycle
    for (int i = 0; i < 7; i++) {
      final type = types[i % types.length];
      nodes.add(
        PathNodeData(
          id: 'node_$i',
          title: "Day ${i + 1}",
          type: type,
          state: i == 0 ? PathNodeState.active : PathNodeState.locked,
          position: i,
          activities: _pickRandomActivities(allExercises, type), // Updated
        ),
      );
    }
    return nodes;
  }

  Future<void> _saveNodesToFirestore(
    CollectionReference collection,
    List<PathNodeData> nodes,
  ) async {
    final batch = _firestore.batch();
    for (var node in nodes) {
      final docRef = collection.doc(node.id);
      batch.set(docRef, {
        'id': node.id,
        'title': node.title,
        'type': node.type.name,
        'state': node.state.name,
        'position': node.position,
        'activities': node.activities.map((a) => a.toJson()).toList(),
      });
    }
    await batch.commit();
  }

  Future<void> deletePathForUser(String uid) async {
    final userPathRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('path_nodes');
    final snapshot = await userPathRef.get();
    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}

final pathGenerationServiceProvider = Provider<PathGenerationService>((ref) {
  return PathGenerationService(FirebaseFirestore.instance);
});
