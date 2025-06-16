import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../models/skill_node.dart';
import '../../../services/skill_tree_service.dart';
import '../../../constants/user_ids.dart'; // for USER_ID or partner ID

class SkillTreeTab extends StatefulWidget {
  const SkillTreeTab({super.key});

  @override
  State<SkillTreeTab> createState() => _SkillTreeTabState();
}

class _SkillTreeTabState extends State<SkillTreeTab> {
  List<SkillNode> nodes = [];
  bool isEditMode = false;
  final uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _loadSkillTree();
  }

  Future<void> _loadSkillTree() async {
    final data = await SkillTreeService.loadSkillTree(USER_ID);
    setState(() => nodes = data);
  }

  void _toggleEditMode() {
    setState(() => isEditMode = !isEditMode);
  }

  Future<void> _addSkillNode({String? parentId}) async {
    final controller = TextEditingController();
    String emoji = '🌱';
    Color color = Colors.blue;

    final result = await showDialog<SkillNode>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(parentId == null ? 'Add Main Skill' : 'Add Subskill'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Skill name'),
            ),
            const SizedBox(height: 10),
            Text('Pick emoji and color (placeholder for now)'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final node = SkillNode(
                id: uuid.v4(),
                name: controller.text.trim(),
                emoji: emoji,
                colorHex: '#${color.value.toRadixString(16)}',
                parentId: parentId,
              );
              Navigator.pop(context, node);
            },
            child: const Text('Add'),
          ),
        ],
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
    final mainSkills = nodes.where((n) => n.parentId == null).toList();
    final subskills = nodes.where((n) => n.parentId != null).toList();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(isEditMode ? Icons.visibility : Icons.edit),
              tooltip: isEditMode ? 'View Mode' : 'Edit Mode',
              onPressed: _toggleEditMode,
            ),
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add Main Skill',
              onPressed: () => _addSkillNode(),
            ),
          ],
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: mainSkills.map((main) {
              final children = subskills.where((s) => s.parentId == main.id).toList();

              return Card(
                color: main.color.withOpacity(0.15),
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('${main.emoji} ${main.name}', style: const TextStyle(fontSize: 18)),
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
                      if (children.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: children.map((sub) {
                              return Row(
                                children: [
                                  Text('${sub.emoji} ${sub.name}'),
                                  if (isEditMode)
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () => _deleteNode(sub),
                                    ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
