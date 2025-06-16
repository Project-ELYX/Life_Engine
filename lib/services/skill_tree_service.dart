import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/skill_node.dart';

class SkillTreeService {
  static final _db = FirebaseFirestore.instance;

  static Future<void> saveSkillNode(String userId, SkillNode node) async {
    await _db
        .collection('skill_trees')
        .doc(userId)
        .collection('nodes')
        .doc(node.id)
        .set(node.toMap());
  }

  static Future<void> deleteSkillNode(String userId, String nodeId) async {
    await _db
        .collection('skill_trees')
        .doc(userId)
        .collection('nodes')
        .doc('nodeId')
        .delete();
  }

  static Future<List<SkillNode>> loadSkillTree(String userId) async {
    final snapshot = await _db
        .collection('skill_trees')
        .doc(userId)
        .collection('nodes')
        .get();

    return snapshot.docs.map((doc) => SkillNode.fromMap(doc.data())).toList();
  }
}