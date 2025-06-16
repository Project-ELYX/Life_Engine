// lib/widgets/profile_tabs/x_rated/nsfw_mood_tab.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/firestore_service.dart';
import '../../../services/mood_storage.dart';

class NSFWMoodTab extends StatefulWidget {
  const NSFWMoodTab({super.key});

  @override
  State<NSFWMoodTab> createState() => _NSFWMoodTabState();
}

class _NSFWMoodTabState extends State<NSFWMoodTab> {
  bool editMode = true;
  String primaryRole = 'Submissive';
  Map<String, double> moodValues = {};
  Map<String, String> moodNotes = {};

  final submissiveSliders = [
    {
      'key': 'obedience',
      'label': 'Obedience',
      'min': 'Defiant',
      'max': 'Obedient',
      'desc': 'Defiant = pushing limits, Obedient = receptive/compliant'
    },
    {
      'key': 'desire',
      'label': 'Desire',
      'min': 'Needs initiation',
      'max': 'Sexually charged',
      'desc': 'Desire to engage; visible tension or arousal'
    },
    {
      'key': 'attachment',
      'label': 'Attachment',
      'min': 'Self-contained',
      'max': 'Hyperfixated',
      'desc': 'Emotional intensity directed at partner'
    },
    {
      'key': 'pain_threshold',
      'label': 'Pain Threshold',
      'min': 'Overwhelmed easily',
      'max': 'Up to hard limits',
      'desc': 'Perceived capacity for intensity/play'
    },
    {
      'key': 'emotional_sensitivity',
      'label': 'Emotional Sensitivity',
      'min': 'Shielded',
      'max': 'Fragile',
      'desc': 'How emotionally raw or closed-off they appear'
    }
  ];

  final dominantSliders = [
    {
      'key': 'control',
      'label': 'Control Drive',
      'min': 'Detached',
      'max': 'Possessive',
      'desc': 'Desire to steer and command partner behavior'
    },
    {
      'key': 'assertiveness',
      'label': 'Assertiveness',
      'min': 'Subtle',
      'max': 'Commanding',
      'desc': 'Overt direction vs background steering'
    },
    {
      'key': 'restraint',
      'label': 'Restraint Level',
      'min': 'Reckless',
      'max': 'Controlled',
      'desc': 'How calculated or impulsive their dominance feels'
    },
    {
      'key': 'empathy_monitor',
      'label': 'Empathy Monitor',
      'min': 'Insensitive',
      'max': 'Hyperaware',
      'desc': 'Reading the partner’s emotional state & adapting'
    },
    {
      'key': 'emotional_exposure',
      'label': 'Emotional Exposure',
      'min': 'Shut down',
      'max': 'Unfiltered',
      'desc': 'Visible emotion and vulnerability signals'
    }
  ];

  List<Map<String, String>> get moodSliders =>
      primaryRole.toLowerCase() == 'dominant' ? dominantSliders : submissiveSliders;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final role = await MoodStorage.getPrimaryRole();
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      primaryRole = role ?? 'Submissive';
      final sliders = moodSliders;
      for (var slider in sliders) {
        final key = slider['key']!;
        moodValues[key] = prefs.getDouble('nsfw_$key') ?? 0.5;
        moodNotes[key] = prefs.getString('nsfw_note_$key') ?? '';
      }
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    for (var entry in moodValues.entries) {
      await prefs.setDouble('nsfw_${entry.key}', entry.value);
    }
    for (var entry in moodNotes.entries) {
      await prefs.setString('nsfw_note_${entry.key}', entry.value);
    }
    await FirestoreServices.saveMoodData(
      userId: 'me',
      moods: {'nsfw': {for (var e in moodValues.entries) e.key: e.value}},
      notes: {'nsfw': {for (var e in moodNotes.entries) e.key: e.value}},
      status: '',
      lastUpdated: DateTime.now(),
    );
    setState(() => editMode = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(editMode ? Icons.check : Icons.edit),
              onPressed: () =>
              editMode ? _saveData() : setState(() => editMode = true),
            )
          ],
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: moodSliders.map((slider) {
              final key = slider['key']!;
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(slider['label']!,
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(width: 6),
                          Tooltip(
                            message: slider['desc'],
                            child: const Icon(Icons.help_outline, size: 18),
                          )
                        ],
                      ),
                      Slider(
                        value: moodValues[key]!,
                        onChanged: editMode
                            ? (value) => setState(() => moodValues[key] = value)
                            : null,
                        min: 0,
                        max: 1,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(slider['min']!),
                          Text(slider['max']!)
                        ],
                      ),
                      if (editMode)
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Optional note',
                          ),
                          onChanged: (val) => moodNotes[key] = val,
                          controller: TextEditingController(
                              text: moodNotes[key]),
                        )
                      else if (moodNotes[key]!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            moodNotes[key]!,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        )
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
