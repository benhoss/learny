import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state_scope.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final l = L10n.of(context);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          l.settingsTitle,
          style: Theme.of(
            context,
          ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        Card(
          child: SwitchListTile(
            title: Text(l.settingsNotificationsTitle),
            subtitle: Text(l.settingsNotificationsSubtitle),
            value: state.notificationsEnabled,
            onChanged: state.toggleNotifications,
          ),
        ),
        Card(
          child: SwitchListTile(
            title: Text(l.settingsSoundEffectsTitle),
            subtitle: Text(l.settingsSoundEffectsSubtitle),
            value: state.soundEnabled,
            onChanged: state.toggleSound,
          ),
        ),
        Card(
          child: SwitchListTile(
            title: Text(l.settingsStudyRemindersTitle),
            subtitle: Text(l.settingsStudyRemindersSubtitle),
            value: state.remindersEnabled,
            onChanged: state.toggleReminders,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l.settingsLearningMemoryTitle,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Card(
          child: SwitchListTile(
            title: Text(l.settingsPersonalizedRecommendationsTitle),
            subtitle: Text(l.settingsPersonalizedRecommendationsSubtitle),
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
            title: Text(l.settingsRecommendationRationaleTitle),
            subtitle: Text(l.settingsRecommendationRationaleSubtitle),
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
            title: Text(l.settingsRationaleDetailLevelTitle),
            subtitle: Text(
              state.recommendationWhyLevel == 'brief'
                  ? l.settingsDetailLevelBrief
                  : l.settingsDetailLevelDetailed,
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
              items: [
                DropdownMenuItem(value: 'brief', child: Text(l.settingsDetailLevelBrief)),
                DropdownMenuItem(value: 'detailed', child: Text(l.settingsDetailLevelDetailed)),
              ],
            ),
          ),
        ),
        Card(
          child: Column(
            children: [
              ListTile(
                title: Text(l.settingsClearMemoryScopeTitle),
                subtitle: Text(
                  state.lastMemoryResetAt == null
                      ? l.settingsNoRecentMemoryReset
                      : l.settingsLastReset(
                          state.lastMemoryResetScope ?? l.settingsUnknownScope,
                          state.lastMemoryResetAt!.toLocal().toIso8601String(),
                        ),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.auto_awesome_rounded),
                title: Text(l.settingsClearEventsOnlyTitle),
                subtitle: Text(l.settingsClearEventsOnlySubtitle),
                enabled: !state.memorySettingsBusy,
                onTap: state.memorySettingsBusy
                    ? null
                    : () => _clearScopeWithConfirm(context, 'events'),
              ),
              ListTile(
                leading: const Icon(Icons.history_rounded),
                title: Text(l.settingsClearRevisionSessionsTitle),
                subtitle: Text(l.settingsClearRevisionSessionsSubtitle),
                enabled: !state.memorySettingsBusy,
                onTap: state.memorySettingsBusy
                    ? null
                    : () =>
                          _clearScopeWithConfirm(context, 'revision_sessions'),
              ),
              ListTile(
                leading: const Icon(Icons.cleaning_services_rounded),
                title: Text(l.settingsClearAllLearningMemoryTitle),
                subtitle: Text(l.settingsClearAllLearningMemorySubtitle),
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
          title: l.parentSettingsTitle,
          icon: Icons.lock_rounded,
          route: AppRoutes.parentPin,
          parentOnly: true,
        ),
        _SettingsTile(
          title: l.safetyPrivacyTitle,
          icon: Icons.shield_rounded,
          route: AppRoutes.safetyPrivacy,
        ),
        _SettingsTile(
          title: l.faqTitle,
          icon: Icons.help_rounded,
          route: AppRoutes.faq,
        ),
        _SettingsTile(
          title: l.contactSupportTitle,
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
            title: Text(l.deleteAccountTitle),
            subtitle: Text(l.settingsDeleteAccountSubtitle),
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
    final l = L10n.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.settingsConfirmClearMemoryTitle),
        content: Text(
          scope == 'all'
              ? l.settingsClearAllConfirm
              : l.settingsClearScopeConfirm(scope),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l.commonClear),
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
        subtitle: parentOnly ? Text(L10n.of(context).parentOnlyLabel) : null,
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }
}
