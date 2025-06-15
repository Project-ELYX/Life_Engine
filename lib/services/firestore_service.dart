import 'package:cloud_firestore/cloud_firestore.dart'

class FirestoreServices {
  static final FirebaseFirestore_db = FirebaseFirestore.instance;

  static Future<void> saveMoodData(String userId, Map<String, double> moods, Map<String, String> notes, String status) async {
    final now = DateTime.now();
    await _db.collection('moods').doc(userId).set({
      'moods': moods,
      'notes': notes,
      'status': status,
      'lastUpdated': now.toIso8601String(),
    });
  }

  static Future<Map<String, dynamic>?> loadMoodData(String userId) async {
    final doc = await _db.collection('moods').doc(userId).get();
    return doc.exists ? doc.data() : null;
  }
}