import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';

class HealthService {
  final Health _health = Health();
  bool _isAuthorized = false;

  Future<bool> requestPermissions() async {
    final types = [
      HealthDataType.STEPS,
      HealthDataType.ACTIVE_ENERGY_BURNED,
      HealthDataType.HEART_RATE,
    ];

    final permissions = [
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.READ,
    ];

    try {
      bool? hasPermissions = await _health.hasPermissions(types, permissions: permissions);
      if (hasPermissions == false) {
        _isAuthorized = await _health.requestAuthorization(types, permissions: permissions);
      } else {
        _isAuthorized = true;
      }
      return _isAuthorized;
    } catch (e) {
      print("Error requesting health permissions: $e");
      return false;
    }
  }

  Future<int> getTodaySteps() async {
    if (!_isAuthorized) await requestPermissions();
    if (!_isAuthorized) return 0;

    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);
    
    try {
      int? steps = await _health.getTotalStepsInInterval(midnight, now);
      return steps ?? 0;
    } catch (e) {
      print("Error getting steps: $e");
      return 0;
    }
  }

  Future<double> getTodayActiveCalories() async {
    if (!_isAuthorized) await requestPermissions();
    if (!_isAuthorized) return 0.0;

    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);
    
    try {
      List<HealthDataPoint> data = await _health.getHealthDataFromTypes(
          startTime: midnight, endTime: now, types: [HealthDataType.ACTIVE_ENERGY_BURNED]);
      
      double totalCalories = 0.0;
      for (var point in data) {
         if (point.value is NumericHealthValue) {
           totalCalories += (point.value as NumericHealthValue).numericValue.toDouble();
         }
      }
      return totalCalories;
    } catch (e) {
      print("Error getting calories: $e");
      return 0.0;
    }
  }
}

final healthServiceProvider = Provider((ref) => HealthService());

final todayStepsProvider = FutureProvider<int>((ref) async {
  return ref.read(healthServiceProvider).getTodaySteps();
});

final todayCaloriesProvider = FutureProvider<double>((ref) async {
  return ref.read(healthServiceProvider).getTodayActiveCalories();
});