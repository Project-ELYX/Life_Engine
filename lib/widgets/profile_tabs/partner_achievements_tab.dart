// lib/widgets/profile_tabs/partner_achievements_tab.dart
import 'package:flutter/material.dart';
import '../../services/achievement_service.dart';

class PartnerAchievementsTab extends StatefulWidget {
  final String partnerId;
  const PartnerAchievementsTab({required this.partnerId, super.key});

  @override
  State<PartnerAchievementsTab> createState() => _PartnerAchievementsTabState();
}

class _PartnerAchievementsTabState extends State<PartnerAchievementsTab> {
  Map<String, dynamic> _achievements = {};

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    final data = await AchievementService.loadAchievements(widget.partnerId);
    final filtered = Map.fromEntries(
      data.entries.where((e) => e.value['public'] == true),
    );
    setState(() => _achievements = filtered);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: _achievements.entries.map((entry) {
        final data = entry.value;
        return ListTile(
          title: Text(data['subtitle'] ?? 'Cryptic Mystery...'),
          subtitle: const Text("You'll never know why."),
        );
      }).toList(),
    );
  }
}
