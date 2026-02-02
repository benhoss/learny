import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state_scope.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Settings',
          style: Theme.of(context)
              .textTheme
              .headlineLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        Card(
          child: SwitchListTile(
            title: const Text('Notifications'),
            subtitle: const Text('Get updates about new packs and streaks.'),
            value: state.notificationsEnabled,
            onChanged: state.toggleNotifications,
          ),
        ),
        Card(
          child: SwitchListTile(
            title: const Text('Sound Effects'),
            subtitle: const Text('Play sounds during games.'),
            value: state.soundEnabled,
            onChanged: state.toggleSound,
          ),
        ),
        Card(
          child: SwitchListTile(
            title: const Text('Study Reminders'),
            subtitle: const Text('Daily reminders for short sessions.'),
            value: state.remindersEnabled,
            onChanged: state.toggleReminders,
          ),
        ),
        const SizedBox(height: 16),
        _SettingsTile(
          title: 'Parent Settings',
          icon: Icons.lock_rounded,
          route: AppRoutes.parentPin,
          parentOnly: true,
        ),
        _SettingsTile(
          title: 'Safety & Privacy',
          icon: Icons.shield_rounded,
          route: AppRoutes.safetyPrivacy,
        ),
        _SettingsTile(
          title: 'FAQ',
          icon: Icons.help_rounded,
          route: AppRoutes.faq,
        ),
        _SettingsTile(
          title: 'Contact Support',
          icon: Icons.mail_rounded,
          route: AppRoutes.contactSupport,
        ),
        const SizedBox(height: 16),
        Card(
          color: LearnyColors.sky,
          child: ListTile(
            leading: const Icon(Icons.delete_forever_rounded, color: LearnyColors.coral),
            title: const Text('Delete Account'),
            subtitle: const Text('This is a destructive action.'),
            onTap: () => Navigator.pushNamed(context, AppRoutes.deleteAccount),
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.title,
    required this.icon,
    required this.route,
    this.parentOnly = false,
  });

  final String title;
  final IconData icon;
  final String route;
  final bool parentOnly;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: LearnyColors.peach,
          child: Icon(icon, color: LearnyColors.coral),
        ),
        title: Text(title),
        subtitle: parentOnly ? const Text('Parent only') : null,
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }
}
