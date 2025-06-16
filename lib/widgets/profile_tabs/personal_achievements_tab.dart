// lib/widgets/profile_tabs/personal_achievements_tab.dart
import 'package:flutter/material.dart';
import '../../services/achievement_service.dart';

class PersonalAchievementsTab extends StatefulWidget {
  final String userId;
  const PersonalAchievementsTab({required this.userId, super.key});

  @override
  State<PersonalAchievementsTab> createState() => _PersonalAchievementsTabState();
}

class _PersonalAchievementsTabState extends State<PersonalAchievementsTab> {
  Map<String, dynamic> _achievements = {};

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    final data = await AchievementService.loadAchievements(widget.userId);
    setState(() => _achievements = data);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: _achievements.entries.map((entry) {
        final data = entry.value;
        return ListTile(
          title: Text(data['title'] ?? entry.key),
          subtitle: Text(data['subtitle'] ?? ''),
        );
      }).toList(),
    );
  }
}
