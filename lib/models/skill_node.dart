import 'package:flutter/material.dart';

class SkillNode {
  final String id;
  final String name;
  final String emoji;
  final String colorHex;
  final String? parentId; //null means it's a main skill

  SkillNode({
    required this.id,
    required this.name,
    required this.emoji,
    required this.colorHex = '#FFFFFF',
    this.parentId,
  });

  // Firestore save function
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'colorHex': colorHex,
      'parentId': parentId,
    };
  }

  // Firestore Load Function
factory SkillNode.fromMap(Map<String, dynamic> map) {
    return SkillNode(
      id: map['id'],
      name: map['name'],
      emoji: map['emoji'],
      colorHex: map['colorHex'],
      parentId: map['parentId'],
    };
  }

  Color get color => Color(int.parse(colorHex.replaceFirst('#', '0xff')));
}

