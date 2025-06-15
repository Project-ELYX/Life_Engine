import 'package:shared_preferences/shared_preferences.dart';

class MoodStorage {
  static Future<void> saveMood(String key, double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('mood_$key', value);
  }

  static Future<double> loadMood(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('mood_$key') ?? 0.0;
  }

  static Future<void> saveNote(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('note_$key', value);
  }

  static Future<String> loadNote(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('note_$key') ?? '';
  }

  static Future<void> saveLastUpdateTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastMoodUpdateTime', time.toIso8601String());
  }

  static Future<DateTime?> getLastUpdateTime() async {
    final.prefs = await SharedPreferences.getInstance();
    final timeStr = prefs.getString('lastMoodUpdateTime');
    if (timeStr == null) return null;
    return DateTime.tryParse(timeStr);
  }

  static Future<void> saveMoodStatus(String userId, String status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('moodStatus_$userid', status); //Use "me" or "partner" as $userId
  }

  static Future<String?> getMoodStatus(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('moodStatus_$userId'); //Use "me" or "partner" as $userId
  }
}
