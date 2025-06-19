// lib/widgets/profile_tabs/skill_tree_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../models/skill_node.dart';
import '../../../services/skill_tree_service.dart';
import '../../../constants/user_ids.dart'; // defines USER_ID

/// Draws lines between parent and subskill centers.
class BranchPainter extends CustomPainter {
  final List<SkillNode> nodes;
  final Map<String, GlobalKey> nodeKeys;

  BranchPainter(this.nodes, this.nodeKeys);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 2;

    for (var node in nodes.where((n) => n.parentId != null)) {
      final parentId = node.parentId!;
      final parentKey = nodeKeys[parentId];
      final childKey = nodeKeys[node.id];
      if (parentKey == null || childKey == null) continue;

      final parentBox = parentKey.currentContext?.findRenderObject() as RenderBox?;
      final childBox = childKey.currentContext?.findRenderObject() as RenderBox?;
      if (parentBox == null || childBox == null) continue;

      final parentOffset = parentBox.localToGlobal(parentBox.size.center(Offset.zero));
      final childOffset = childBox.localToGlobal(childBox.size.center(Offset.zero));

      // Convert global to local coordinates
      final transform = (canvas.getSaveLayerBounds().transform ?? Matrix4.identity());
      final localParent = transform.transform3(Vector3(parentOffset.dx, parentOffset.dy, 0));
      final localChild = transform.transform3(Vector3(childOffset.dx, childOffset.dy, 0));

      canvas.drawLine(
        Offset(localParent.x, localParent.y),
        Offset(localChild.x, localChild.y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SkillTreeTab extends StatefulWidget {
  const SkillTreeTab({super.key});

  @override
  State<SkillTreeTab> createState() => _SkillTreeTabState();
}

class _SkillTreeTabState extends State<SkillTreeTab>
    with SingleTickerProviderStateMixin {
  List<SkillNode> nodes = [];
  bool isEditMode = false;
  final uuid = const Uuid();

  // Pulse animation
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  // Keys to locate widgets for branch painting
  final Map<String, GlobalKey> _nodeKeys = {};

  @override
  void initState() {
    super.initState();
    _loadSkillTree();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadSkillTree() async {
    final data = await SkillTreeService.loadSkillTree(USER_ID);
    setState(() {
      nodes = data;
      // ensure keys exist
      for (var node in nodes) {
        _nodeKeys.putIfAbsent(node.id, () => GlobalKey());
      }
    });
  }

  void _toggleEditMode() => setState(() => isEditMode = !isEditMode);

  Future<void> _addSkillNode({String? parentId}) async {
    final controller = TextEditingController();
    String emoji = '🌱';
    Color selectedColor = Colors.blue;

    final result = await showDialog<SkillNode>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(parentId == null ? 'Add Main Skill' : 'Add Subskill'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(labelText: 'Skill name'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    // Color picker
                    GestureDetector(
                      onTap: () async {
                        await showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Pick a color'),
                            content: SingleChildScrollView(
                              child: BlockPicker(
                                pickerColor: selectedColor,
                                onColorChanged: (c) => setState(() => selectedColor = c),
                              ),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: selectedColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black26),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Emoji picker
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDialog<String>(
                          context: context,
                          builder: (ctx) => SizedBox(
                            height: 300,
                            child: EmojiPicker(
                              onEmojiSelected: (cat, em) => Navigator.pop(ctx, em.emoji),
                            ),
                          ),
                        );
                        if (picked != null) setState(() => emoji = picked);
                      },
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final node = SkillNode(
                  id: uuid.v4(),
                  name: controller.text.trim(),
                  emoji: emoji,
                  colorHex: '#${selectedColor.value.toRadixString(16).padLeft(8, '0')}',
                  parentId: parentId,
                  order: nodes.length,
                );
                Navigator.pop(context, node);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      await SkillTreeService.saveSkillNode(USER_ID, result);
      _loadSkillTree();
    }
  }

  Future<void> _deleteNode(SkillNode node) async {
    await SkillTreeService.deleteSkillNode(USER_ID, node.id);
    _loadSkillTree();
  }

  @override
  Widget build(BuildContext context) {
    // sort by order
    nodes.sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));
    final mainSkills = nodes.where((n) => n.parentId == null).toList();
    final subskills = nodes.where((n) => n.parentId != null).toList();

    return Stack(
      children: [
        CustomPaint(
          size: MediaQuery.of(context).size,
          painter: BranchPainter(nodes, _nodeKeys),
        ),
        ReorderableListView(
          padding: const EdgeInsets.all(12),
          onReorder: (oldIndex, newIndex) async {
            setState(() {
              if (newIndex > oldIndex) newIndex--;
              final item = mainSkills.removeAt(oldIndex);
              mainSkills.insert(newIndex, item);
            });
            // persist new order
            for (int i = 0; i < mainSkills.length; i++) {
              final node = mainSkills[i];
              node.order = i;
              await SkillTreeService.saveSkillNode(USER_ID, node);
            }
          },
          children: [
            for (var main in mainSkills)
              Card(
                key: _nodeKeys[main.id],
                color: main.color.withAlpha((0.2 * 255).round()),
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${main.emoji} ${main.name}',
                            style: const TextStyle(fontSize: 18),
                          ),
                          if (isEditMode)
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteNode(main),
                            ),
                          if (isEditMode)
                            IconButton(
                              icon: const Icon(Icons.add),
                              tooltip: 'Add Subskill',
                              onPressed: () => _addSkillNode(parentId: main.id),
                            ),
                        ],
                      ),
                      if (subskills.any((s) => s.parentId == main.id))
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: subskills
                                .where((s) => s.parentId == main.id)
                                .map((sub) {
                              Widget nodeBox = Container(
                                key: _nodeKeys[sub.id],
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                    colors: [
                                      main.color.withAlpha(150),
                                      main.color.withAlpha(30),
                                    ],
                                    radius: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: main.color.withAlpha(100),
                                      blurRadius: 12,
                                      spreadRadius: 1,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: main.color.withAlpha(80),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      '${sub.emoji} ${sub.name}',
                                      style: const TextStyle(
                                          fontSize: 15, color: Colors.white),
                                    ),
                                    if (isEditMode)
                                      IconButton(
                                        icon: const Icon(Icons.delete, size: 18),
                                        onPressed: () => _deleteNode(sub),
                                        color: Colors.white70,
                                      ),
                                  ],
                                ),
                              );
                              return isEditMode
                                  ? nodeBox
                                  : ScaleTransition(
                                scale: _pulseAnim,
                                child: nodeBox,
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
