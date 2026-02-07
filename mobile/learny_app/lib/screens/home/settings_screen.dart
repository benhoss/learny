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
          style: Theme.of(
            context,
          ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w700),
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
        const SizedBox(height: 8),
        Text(
          'Learning Memory',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Card(
          child: SwitchListTile(
            title: const Text('Personalized Recommendations'),
            subtitle: const Text('Use activity history to adapt next steps.'),
            value: state.memoryPersonalizationEnabled,
            onChanged: state.memorySettingsBusy
                ? null
                : (value) => state.updateMemoryPreferences(
                    memoryPersonalizationEnabled: value,
                  ),
          ),
        ),
        Card(
          child: SwitchListTile(
            title: const Text('Show Recommendation Rationale'),
            subtitle: const Text('Display “why this suggestion” explanations.'),
            value: state.recommendationWhyEnabled,
            onChanged: state.memorySettingsBusy
                ? null
                : (value) => state.updateMemoryPreferences(
                    recommendationWhyEnabled: value,
                  ),
          ),
        ),
        Card(
          child: ListTile(
            title: const Text('Rationale Detail Level'),
            subtitle: Text(
              state.recommendationWhyLevel == 'brief' ? 'Brief' : 'Detailed',
            ),
            trailing: DropdownButton<String>(
              value: state.recommendationWhyLevel,
              onChanged: state.memorySettingsBusy
                  ? null
                  : (value) {
                      if (value == null) {
                        return;
                      }
                      state.updateMemoryPreferences(
                        recommendationWhyLevel: value,
                      );
                    },
              items: const [
                DropdownMenuItem(value: 'brief', child: Text('Brief')),
                DropdownMenuItem(value: 'detailed', child: Text('Detailed')),
              ],
            ),
          ),
        ),
        Card(
          child: Column(
            children: [
              ListTile(
                title: const Text('Clear Memory Scope'),
                subtitle: Text(
                  state.lastMemoryResetAt == null
                      ? 'No recent memory reset.'
                      : 'Last reset: ${state.lastMemoryResetScope ?? 'unknown'} at ${state.lastMemoryResetAt!.toLocal().toIso8601String()}',
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.auto_awesome_rounded),
                title: const Text('Clear events only'),
                subtitle: const Text('Keeps mastery and results.'),
                enabled: !state.memorySettingsBusy,
                onTap: state.memorySettingsBusy
                    ? null
                    : () => _clearScopeWithConfirm(context, 'events'),
              ),
              ListTile(
                leading: const Icon(Icons.history_rounded),
                title: const Text('Clear revision sessions'),
                subtitle: const Text('Removes quick revision history.'),
                enabled: !state.memorySettingsBusy,
                onTap: state.memorySettingsBusy
                    ? null
                    : () =>
                          _clearScopeWithConfirm(context, 'revision_sessions'),
              ),
              ListTile(
                leading: const Icon(Icons.cleaning_services_rounded),
                title: const Text('Clear all learning memory'),
                subtitle: const Text(
                  'Events, revision, game results, mastery.',
                ),
                enabled: !state.memorySettingsBusy,
                onTap: state.memorySettingsBusy
                    ? null
                    : () => _clearScopeWithConfirm(context, 'all'),
              ),
            ],
          ),
        ),
        if (state.memorySettingsBusy)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: LinearProgressIndicator(minHeight: 2),
          ),
        if (state.memorySettingsError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              state.memorySettingsError!,
              style: const TextStyle(color: LearnyColors.coral),
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
            leading: const Icon(
              Icons.delete_forever_rounded,
              color: LearnyColors.coral,
            ),
            title: const Text('Delete Account'),
            subtitle: const Text('This is a destructive action.'),
            onTap: () => Navigator.pushNamed(context, AppRoutes.deleteAccount),
          ),
        ),
      ],
    );
  }

  Future<void> _clearScopeWithConfirm(
    BuildContext context,
    String scope,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm clear memory'),
        content: Text(
          scope == 'all'
              ? 'This clears all learning memory signals. Continue?'
              : 'Clear memory scope "$scope"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }
    final state = AppStateScope.of(context);
    await state.clearMemoryScope(scope);
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
