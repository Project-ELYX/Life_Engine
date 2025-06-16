import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/home_summary.dart';
import 'themes/theme_manager.dart';

void main() async {
  WidgetFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const LifeEngineApp());
}

class LifeEngineApp extends StatelessWidget {
  const LifeEngineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Life Engine',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode..system,
      home: const HomeSummaryScreen(),
    );
  }
}