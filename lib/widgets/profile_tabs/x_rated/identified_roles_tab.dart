// lib/widgets/profile_tabs/x_rated/identified_roles_tab.dart
import 'package:flutter/material.dart';
import '../../../services/achievement_service.dart';

class IdentifiedRolesTab extends StatefulWidget {
  final String userId;
  const IdentifiedRolesTab({required this.userId, super.key});

  @override
  State<IdentifiedRolesTab> createState() => _IdentifiedRolesTabState();
}

class _IdentifiedRolesTabState extends State<IdentifiedRolesTab> {
  List<String> selectedRoles = [];
  final List<String> allRoles = [
    'Dominant', 'Submissive', 'Switch', 'Sadomasochist', 'Rigger', 'Rope Bunny', 'Brat', 'Primal', 'Pet', 'Handler', // etc
  ];

  bool isEditMode = true;

  void _toggleRole(String role) async {
    setState(() {
      selectedRoles.contains(role)
          ? selectedRoles.remove(role)
          : selectedRoles.add(role);
    });

    // Easter Egg: Sadopotatochist achievement
    if (role == 'Sadomasochist' && selectedRoles.contains(role)) {
      await AchievementService.unlockAchievement(
        widget.userId,
        'sadopotatochist',
        title: 'sadopotatochist',
        subtitle: 'This potato knows what you did. And liked it.',
        isPublic: true,
      );

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("🎉 Achievement Unlocked"),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("sadopotatochist", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text("This potato knows what you did. And liked it.", style: TextStyle(fontStyle: FontStyle.italic)),
              ],
            ),
            actions: [
              TextButton(
                child: const Text("Acknowledge your sins"),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isEditMode)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: allRoles.map((role) {
                final selected = selectedRoles.contains(role);
                return ListTile(
                  title: Text(role),
                  trailing: Icon(
                    selected ? Icons.check_box : Icons.check_box_outline_blank,
                    color: selected ? Colors.green : null,
                  ),
                  onTap: () => _toggleRole(role),
                );
              }).toList(),
            ),
          )
        else
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: selectedRoles.map((role) => ListTile(title: Text(role))).toList(),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: ElevatedButton(
            onPressed: () => setState(() => isEditMode = !isEditMode),
            child: Text(isEditMode ? 'Save' : 'Edit'),
          ),
        ),
      ],
    );
  }
}
