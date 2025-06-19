import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/user_ids.dart';
import '../widgets/profile_tabs/general_tab.dart';
import '../widgets/profile_tabs/likes_tab.dart';
import '../widgets/profile_tabs/dislikes_tab.dart';
import '../widgets/profile_tabs/skill_tree_tab.dart';
import '../widgets/profile_tabs/x_rated/nsfw_mood_tab.dart';
import '../widgets/profile_tabs/x_rated/experience_tree_tab.dart';
import '../widgets/profile_tabs/x_rated/identified_roles_tab.dart';
import '../widgets/profile_tabs/x_rated/play_preferences_tab.dart';
import '../widgets/profile_tabs/x_rated/hard_limits_tab.dart';


class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isXRatedMode = false;

  final List<Tab> standardTabs = const [
    Tab(text: 'Mood'),
    Tab(text: 'Likes'),
    Tab(text: 'Dislikes'),
    Tab(text: 'Skills'),
  ];

  final List<Tab> xRatedTabs = const [
    Tab(text: 'NSFW Mood'),
    Tab(text: 'Roles'),
    Tab(text: 'Preferences'),
    Tab(text: 'Limits'),
    Tab(text: 'Experience'),
  ];

  @override
  void initState() {
    super.initState();
    _loadXRatedMode();
  }

  void _loadXRatedMode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getBool('xRatedMode') ?? false;

    setState(() {
      isXRatedMode = savedMode;
      _tabController = TabController(
        length: isXRatedMode ? xRatedTabs.length : standardTabs.length,
        vsync: this,
      );
    });
  }

void _toggleMode() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      isXRatedMode = !isXRatedMode;
      _tabController.dispose();
      _tabController = TabController(
        length: isXRatedMode ? xRatedTabs.length : standardTabs.length,
        vsync: this
      );
    });

    await prefs.setBool('xRatedMode', isXRatedMode);
}

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = isXRatedMode ? xRatedTabs : standardTabs;

    return Scaffold(
      appBar: AppBar(
        title: Text(isXRatedMode ? 'X-Rated Profile' : 'Profile'),
        actions: [
          if (widget.userId == myUserId)
            IconButton(
              icon: Icon(isXRatedMode ? Icons.lock_open : Icons.lock),
              onPressed: _toggleMode,
              tooltip: isXRatedMode ? 'Exit X-Rated Mode' : 'Enter X-Rated Mode',
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: tabs,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: isXRatedMode
            ? const [
          NSFWMoodTab(),
          IdentifiedRolesTab(),
          PlayPreferencesTab(),
          HardLimitsTab(),
          ExperienceTreeTab(),
        ]
            : const [
          GeneralTab(),
          LikesTab(),
          DislikesTab(),
          SkillTreeTab(),
        ],
      ),
    );
  }
}


