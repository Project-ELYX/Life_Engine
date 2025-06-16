// lib/widgets/profile_tabs/x_rated/experience_tree_tab.dart
import 'package:flutter/material.dart';
import '../../../services/experience_service.dart';

class ExperienceTreeTab extends StatefulWidget {
  const ExperienceTreeTab({super.key});

  @override
  State<ExperienceTreeTab> createState() => _ExperienceTreeTabState();
}

class _ExperienceTreeTabState extends State<ExperienceTreeTab> {
  final TextEditingController _skillController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  Map<String, Map<String, dynamic>> experiences = {};
  String? _skillLevel;
  String? _editingSkill;

  @override
  void initState() {
    super.initState();
    _loadExperiences();
  }

  Future<void> _loadExperiences() async {
    final data = await ExperienceService.loadExperience();
    if (data != null) {
      setState(() => experiences = data);
    }
  }

  Future<void> _saveExperience(String skill) async {
    final exp = int.tryParse(_skillLevel ?? '0') ?? 0;
    final note = _noteController.text;
    await ExperienceService.saveExperience(skill, {
      'experience': exp,
      'notes': note,
      'lastUpdated': DateTime.now().toIso8601String(),
    });
    _clearInputs();
    _loadExperiences();
  }

  Future<void> _deleteExperience(String skill) async {
    await ExperienceService.deleteExperience(skill);
    _loadExperiences();
  }

  void _startEditing(String skill, Map<String, dynamic> data) {
    setState(() {
      _editingSkill = skill;
      _skillController.text = skill;
      _noteController.text = data['notes'] ?? '';
      _skillLevel = data['experience'].toString();
    });
  }

  void _clearInputs() {
    _editingSkill = null;
    _skillController.clear();
    _noteController.clear();
    _skillLevel = null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_editingSkill != null ? 'Edit Experience' : 'Add Experience',
              style: Theme.of(context).textTheme.titleLarge),
          TextField(
            controller: _skillController,
            decoration: const InputDecoration(labelText: 'Skill Name'),
          ),
          DropdownButton<String>(
            value: _skillLevel,
            hint: const Text('Experience Level (1–5)'),
            items: List.generate(5, (i) => (i + 1).toString()).map((level) {
              return DropdownMenuItem(
                value: level,
                child: Text(level),
              );
            }).toList(),
            onChanged: (val) => setState(() => _skillLevel = val),
          ),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(labelText: 'Notes'),
            maxLines: 2,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => _saveExperience(_skillController.text.trim()),
                child: Text(_editingSkill != null ? 'Update' : 'Save'),
              ),
              const SizedBox(width: 10),
              if (_editingSkill != null)
                OutlinedButton(
                  onPressed: _clearInputs,
                  child: const Text('Cancel'),
                ),
            ],
          ),
          const Divider(height: 30),
          Text('Your Experience Log:', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              children: experiences.entries.map((entry) {
                final data = entry.value;
                return ListTile(
                  title: Text(entry.key),
                  subtitle: Text('Exp: ${data['experience']} • ${data['notes']}'),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _startEditing(entry.key, data),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteExperience(entry.key),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
