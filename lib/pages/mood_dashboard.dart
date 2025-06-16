import 'package:flutter/material.dart';
import '../services/mood_storage.dart';
import '../widgets/animated_mood_slider.dart';
import '../constants/user_ids.dart'

class MoodDashboard extends StatefulWidget {
  const MoodDashboard({super.key});

  @override
  State<MoodDashboard> createState() => _MoodDashboardState();
}


class _MoodDashboardState extends State<MoodDashboard> {
  bool isEditMode = true;

  Map<String, double> moods = {
    'anger': 0.0,
    'happiness': 0.0,
    'sadness': 0.0,
    'love': 0.0,
    'joking': 0.0,
  };

  Map<String, String> notes = {
    'anger': '',
    'happiness': '',
    'sadness': '',
    'love': '',
    'joking': '',
  };

  String status = 'Unknown';

  @override
  void initState() {
    super.initState();
    _loadInitialMoodValues();
  }

  Future<void> _loadInitialMoodValues() async {
    for (var mood in moods.keys) {
      moods[mood] = await MoodStorage.getMood(mood) ?? 0.0;
      notes[mood] = await MoodStorage.getNote(mood) ?? '';
    }
    status = await MoodStorage.getMoodStatus('me') ?? 'Unknown';
    setState(() {});
  }

  Future<void> _saveAllToFirestore() async {
    final now = DateTime.now();
    const userId = 'me';

    await MoodStorage.saveMoodStatus(userId);
    await MoodStorage.saveLastUpdateTime(now);

    await FirestoreServices.saveMoodData(
      userId: userId,
      moods: Map.fromEntries(moods.entries.map((e) => MapEntry(e.key.toLowerCase(), e.value))),
      notes: Map.fromEntries(notes.entries.map((e) => MapEntry(e.key.toLowerCase(), e.value))),
      status: status,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Moods synced to Firestore ✔️')),
    );
  }

  bool isEditMode = true;

  double anger = 0;
  double happiness = 0;
  double sadness = 0;
  double love = 0;
  double joking = 0;

  String angerNote = '';
  String happinessNote = '';
  String sadnessNote = '';
  String loveNote = '';
  String jokingNote = '';

  @override
  void initState() {
    super.initState();
    _loadMoodData();
  }

  void _loadMoodData() async {
    anger = await MoodStorage.loadMood('anger');
    happiness = await MoodStorage.loadMood('happiness');
    sadness = await MoodStorage.loadMood('sadness');
    love = await MoodStorage.loadMood('love');
    joking = await MoodStorage.loadMood('joking');

    angerNote = await MoodStorage.loadNote('anger');
    happinessNote = await MoodStorage.loadNote('happiness');
    sadnessNote = await MoodStorage.loadNote('sadness');
    loveNote = await MoodStorage.loadNote('love');
    jokingNote = await MoodStorage.loadNote('joking');

    setState(() {}); // Triggers UI update once loaded
  }

  final Map<String, double> moods = {
    'Anger': 0,
    'Happiness': 0,
    'Sadness': 0,
    'Love': 0,
    'Joking': 0,
  };

  final Map<String, String> moodNotes = {
    'Anger': '',
    'Happiness': '',
    'Sadness': '',
    'Love': '',
    'Joking': '',
  };

  final Map<String, Color> moodColors = {
    'Anger': Colors.redAccent,
    'Happiness': Colors.yellowAccent,
    'Sadness': Colors.blueAccent,
    'Love': Colors.pinkAccent,
    'Joking': Colors.greenAccent,
  };

  String calculateOverallMood() {
    double anger = moods['Anger'] ?? 0;
    double happiness = moods['Happiness'] ?? 0;
    double sadness = moods['Sadness'] ?? 0;
    double love = moods['Love'] ?? 0;
    double joking = moods['Joking'] ?? 0;

    if (anger > 70) return "Pissed Off";
    if (sadness > 60) return "Moody";
    if (happiness > 60 && love > 40) return "Cheerful";
    if (joking > 60 && love > 40) return "Goofball";
    if (anger < 30 && happiness < 30 && sadness < 30) return "Neutral";

    return "Mixed";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Dashboard'),
        actions: [
          IconButton(
            icon: Icon(isEditMode ? Icons.visibility : Icons.edit),
            onPressed: () {
              setState(() => isEditMode = !isEditMode);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'General Mood: ${calculateOverallMood()}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: moods.keys.map((mood) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(mood, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      isEditMode
                          ? Slider(
                        value: moods[mood]!,
                        onChanged: (value) async {
                          setState(() {
                            moods[mood] = value;
                          });

                          final now = DateTime.now();
                          final userId = 'me'; // or 'partner' depending on the device

                          await MoodStorage.saveMood(mood.toLowerCase(), value);
                          await MoodStorage.saveLastUpdateTime(now);

                          final note = await MoodStorage.getNote(mood.toLowerCase()) ?? '';
                          final status = await MoodStorage.getMoodStatus(userId) ?? '';

                          await FirestoreServices.saveMoodData(
                            userId,
                            {mood.toLowerCase(): value};
                            {mood.toLowerCase(): note};
                            status,
                          );
                        }
                        min: 0,
                        max: 100,
                        divisions: 10,
                        label: moods[mood]!.round().toString(),
                      )
                          : AnimatedMoodSlider(
                        mood: mood,
                        value: moods[mood]!,
                        color: moodColors[mood]!,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: InputDecoration(labelText: 'Notes for $mood'),
                        controller: TextEditingController.fromValue(
                          TextEditingValue(
                            text: moodNotes[mood] ?? '',
                            selection: TextSelection.collapsed(offset: (moodNotes[mood] ?? '').length),
                          ),
                        ),
                        onChanged: (val) {
                          moodNotes[mood] = val;
                          MoodStorage.saveNote(mood.toLowerCase(), val);
                        },
                      ),
                      const Divider(),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
