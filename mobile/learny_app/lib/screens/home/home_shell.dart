import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import 'home_screen.dart';
import 'packs_screen.dart';
import 'progress_screen.dart';
import 'settings_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    HomeScreen(),
    PacksScreen(),
    ProgressScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LearnyColors.cream,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _tabs,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_rounded), label: L10n.of(context).homeTabHome),
          NavigationDestination(icon: const Icon(Icons.auto_stories_rounded), label: L10n.of(context).homeTabPacks),
          NavigationDestination(icon: const Icon(Icons.insights_rounded), label: L10n.of(context).homeTabProgress),
          NavigationDestination(icon: const Icon(Icons.settings_rounded), label: L10n.of(context).homeTabSettings),
        ],
      ),
    );
  }
}
