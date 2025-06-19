import 'package:flutter/material.dart';

Widget moodSummaryCard(String userId, String displayName, double moodValue, String? statusMsg, DateTime? lastUpdated) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 10),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(displayName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text("Mood: ${moodValue.round()}%"),
          if (statusMsg != null && statusMsg.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text("Status: $statusMsg", style: const TextStyle(fontStyle: FontStyle.italic)),
            ),
          if (lastUpdated != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text("Last Updated: ${_formatTime(lastUpdated)}", style: const TextStyle(fontSize: 12)),
            ),
        ],
      ),
    ),
  );
}

String _formatTime(DateTime time) {
  final now = DateTime.now();
  final diff = now.difference(time);
  if (diff.inMinutes < 1) return "Just Now";
  if (diff.inHours < 1) return "${diff.inMinutes} min ago";
  if (diff.inDays < 1) return "${diff.inHours} hrs ago";
  return "${diff.inDays} day(s) ago";
}
