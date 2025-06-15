import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart'
import 'firebase_options.dart'; //Auto-Generated
import '../constants/user_ids.dart'
import 'themes/theme_manager.dart';
import 'pages/mood_dashboard.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.InitializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const Life_EngineApp)
}

void main() => runApp(const Life_EngineApp());

class Life_EngineApp extends StatelessWidget {
  const Life_EngineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LoveOS',
      theme: ThemeData.dark(),
      home: const HomeSummaryScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final nameCtrl = TextEditingController();
  final bioCtrl = TextEditingController();
  double mood = 0.7;

  List<String> likes = [];
  List<String> dislikes = [];
  List<String> skills = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nameCtrl.text = prefs.getString('name') ?? 'Monic 🐍';
      bioCtrl.text = prefs.getString('bio') ?? 'Emotionally feral / Affectionate menace';
      mood = prefs.getDouble('mood') ?? 0.7;
      likes = prefs.getStringList('likes') ?? ['Storms', 'Welding', 'Gaming'];
      dislikes = prefs.getStringList('dislikes') ?? ['Silence when it matters'];
      skills = prefs.getStringList('skills') ?? ['TIG Welding – Level 10'];
    });
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', nameCtrl.text);
    await prefs.setString('bio', bioCtrl.text);
    await prefs.setDouble('mood', mood);
    await prefs.setStringList('likes', likes);
    await prefs.setStringList('dislikes', dislikes);
    await prefs.setStringList('skills', skills);
  }

  void _addItem(List<String> list, String label, String hint, Function(List<String>) onUpdate) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Add $label"),
        content: TextField(controller: controller, decoration: InputDecoration(hintText: hint)),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Add"),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                list.add(controller.text.trim());
                onUpdate(list);
                _saveProfile();
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _editableList(String title, List<String> items, Function(List<String>) onUpdate, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ...items.map((e) => ListTile(
          title: Text(e),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () {
              items.remove(e);
              onUpdate(items);
              _saveProfile();
            },
          ),
        )),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => _addItem(items, label, 'Enter new $label', onUpdate),
            icon: const Icon(Icons.add),
            label: const Text('Add'),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KKMB Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(radius: 50, backgroundColor: Colors.deepPurple),
            const SizedBox(height: 10),
            TextField(
              controller: nameCtrl,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(labelText: 'Name'),
              onChanged: (_) => _saveProfile(),
            ),
            TextField(
              controller: bioCtrl,
              decoration: const InputDecoration(labelText: 'Bio'),
              onChanged: (_) => _saveProfile(),
            ),
            const Divider(thickness: 1.5, height: 40),
            _editableList("Likes", likes, (v) => setState(() => likes = v), "like"),
            _editableList("Dislikes", dislikes, (v) => setState(() => dislikes = v), "dislike"),
            _editableList("Skill Tree", skills, (v) => setState(() => skills = v), "skill"),
            const SizedBox(height: 10),
            const Text("Mood", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Slider(
              value: mood,
              onChanged: (v) => setState(() {
                mood = v;
                _saveProfile();
              }),
              min: 0.0,
              max: 1.0,
              activeColor: Colors.purpleAccent,
            ),
            Text("Current Mood: ${(mood * 100).round()}% charged"),
          ],
        ),
      ),
    );
  }
}
