import 'package:flutter/material.dart';
import '../shared/placeholder_screen.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state_scope.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    return PlaceholderScreen(
      title: 'Notifications',
      subtitle: 'Friendly nudges for parents and kids.',
      gradient: LearnyGradients.trust,
      body: Column(
        children: state.notifications
            .map(
              (item) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: item.isRead ? LearnyColors.slateLight : LearnyColors.coral,
                    child: Icon(
                      item.isRead ? Icons.notifications_none_rounded : Icons.notifications_active_rounded,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(item.title),
                  subtitle: Text('${item.message} • ${item.timeLabel}'),
                  trailing: item.isRead
                      ? null
                      : TextButton(
                          onPressed: () => state.markNotificationRead(item.id),
                          child: const Text('Mark read'),
                        ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
