class SkillNode {
  final String id;
  final String name;
  final String emoji;
  final String colorHex;
  final String? parentId;
  int? order;            // ← new

  SkillNode({
    required this.id,
    required this.name,
    this.emoji = '🌱',
    this.colorHex = '#FFFFFF',
    this.parentId,
    this.order,          // ← new
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'colorHex': colorHex,
      'parentId': parentId,
      'order': order,    // ← new
    };
  }

  factory SkillNode.fromMap(Map<String, dynamic> map) {
    return SkillNode(
      id: map['id'],
      name: map['name'],
      emoji: map['emoji'] ?? '🌱',
      colorHex: map['colorHex'] ?? '#FFFFFF',
      parentId: map['parentId'],
      order: map['order'] != null ? (map['order'] as num).toInt() : null, // ← new
    );
  }

  Color get color => Color(int.parse(colorHex.replaceFirst('#', '0xff')));
}
