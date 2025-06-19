import 'package:flutter/material.dart';

// === GLITCHY PURPLE PROFILE THEME ===
final ThemeData glitchTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.deepPurpleAccent,
  scaffoldBackgroundColor: Colors.black,
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white, fontFamily: 'Orbitron'),
    bodyMedium: TextStyle(color: Colors.white70),
  ),
  sliderTheme: SliderThemeData(
    activeTrackColor: Colors.deepPurpleAccent,
    inactiveTrackColor: Colors.purple.shade900,
    thumbColor: Colors.deepPurpleAccent,
    overlayColor: Colors.purpleAccent.withAlpha(51),
    trackHeight: 4.0,
  ),
  fontFamily: 'Orbitron',
);

// === PLACEHOLDER FOR HIS FUTURE THEME ===
final ThemeData calmBlueTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.lightBlue,
  scaffoldBackgroundColor: Colors.white,
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black),
    bodyMedium: TextStyle(color: Colors.black87),
  ),
  sliderTheme: SliderThemeData(
    activeTrackColor: Colors.lightBlue,
    inactiveTrackColor: Colors.blueGrey.shade200,
    thumbColor: Colors.blueAccent,
    overlayColor: Colors.blueAccent.withAlpha(25),
    trackHeight: 4.0,
  ),
);

// Basic light and dark themes used by the app
final ThemeData lightTheme = ThemeData.light();
final ThemeData darkTheme = ThemeData.dark();
