import 'package:cloud_firestore/cloud_firestore.dart';

class MoodFirestoreService {
  final _db = FirebaseFirestore.instance;

  Future<void> updateMood(String userId, double mood, String status) async {
    await _db.collection('moods').doc(userId).set({
      'mood': mood,
      'status': status,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamMood(String userId) {
    return _db.collection('moods').doc(userId).snapshots();
  }
}
