// lib/services/achievement_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AchievementService {
  static final _db = FirebaseFirestore.instance;

  static Future<void> unlockAchievement(String userId, String id, {
    required String title,
    required String subtitle,
    bool isPublic = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final localKey = 'achievement_$id';
    if (prefs.getBool(localKey) == true) return; // Already unlocked

    // Mark as unlocked locally
    await prefs.setBool(localKey, true);

    // Save to Firestore
    await _db.collection('achievements').doc(userId).set({
      id: {
        'title': title,
        'subtitle': subtitle,
        'timestamp': DateTime.now().toIso8601String(),
        'public': isPublic,
      }
    }, SetOptions(merge: true));
  }

  static Future<Map<String, dynamic>> loadAchievements(String userId) async {
    final doc = await _db.collection('achievements').doc(userId).get();
    return doc.exists ? doc.data() ?? {} : {};
  }
}
