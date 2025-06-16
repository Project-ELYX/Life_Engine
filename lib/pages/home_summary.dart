import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/home_summary_card.dart';
import '../constants/user_ids.dart'

class HomeSummaryScreen extends StatefulWidget {
  const HomeSummaryScreen({super.key});

  @override
  State<HomeSummaryScreen> createState() => _HomeSummaryScreenState();
}

class _HomeSummaryScreenState extends State<HomeSummaryScreen> {
  double myMood = 0;
  String? myStatus;
  DateTime? myUpdated;

  double theirMood = 0;
  String? theirStatus;
  DateTime? theirUpdated;

  @override
  void initState() {
    super.initState();
    _loadMoodSummaries();
  }

  Future<void> _loadMoodSummaries() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final myData = await FirestoreServices.loadMoodData('me');
      final theirData = await FirestoreServices.loadMoodData('partner');

      setState(() {
        myMood = myData?['moods']?['general'] ?? prefs.getDouble('mood') ?? 0.0;
        myStatus = myData?['status'] ?? prefs.getString('moodStatus_me');
        myUpdated = myData?['lastUpdated'] != null
          ? DateTime.tryParse(myData!['lastUpdated'])
          : null;

        theirMood = theirData?['moods']?['general'] ?? prefs.getDouble('partner_mood') ?? 0.0;
        theirStatus = theirData?['status'] ?? prefs.getString('moodStatus_partner');
        theirUpdated = theirData?['lastUpdated'] != null
          ? DateTime.tryParse(theirData!['lastUpdated'])
          : null;
      });
    } catch (e) {
      print("Error loading from Firestore: $e")
          // Fallback to SharedPreferences if Firestore fails
      setState(() {
        myMood = prefs.getDouble('mood') ?? 0.0;
        theirMood = prefs.getDouble('partner_mood') ?? 0.0;

        myStatus = prefs.getString('moodStatus_me');
        theirStatus = prefs.getString('moodStatus_partner');

        final myTimeStr = prefs.getString('lastMoodUpdateTime');
        final theirTimeStr = prefs.getString('partner_lastMoodUpdateTime');
        myUpdated = myTimeStr != null ? DateTime.tryParse(myTimeStr) : null;
        theirUpdated = theirTimeStr != null ? DateTime.tryParse(theirTimeStr) : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mood Overview")),
      body: Padding(
        padding: const EdgeInsets.all(16)
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            moodSummaryCard('me', 'placeholdername', myMood, myStatus, myUpdated),
            const SizedBox(height: 20)
            moodSummaryCard('partner', 'theirplaceholdername', theirMood, theirStatus, theirUpdated),
          ],
        ),
      ),
    );
  }
}