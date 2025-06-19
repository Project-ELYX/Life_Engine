import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreServices {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> saveMoodData({
    required String userId,
    required Map<String, double> moods,
    required Map<String, String> notes,
    required String status,
    required DateTime lastUpdated,
  }) async {
    await _db.collection('moods').doc(userId).set({
      'moods': moods,
      'notes': notes,
      'status': status,
      'lastUpdated': lastUpdated.toIso8601String(),
    });
  }

  static Future<Map<String, dynamic>?> loadMoodData(String userId) async {
    final doc = await _db.collection('moods').doc(userId).get();
    return doc.exists ? doc.data() : null;
  }

  static Future<void> saveUserToken(String userId, String token) async {
    final usersRef = _db.collection('users');
    await usersRef.doc(userId).set({'fcmToken': token}, SetOptions(merge: true));
  }
}
