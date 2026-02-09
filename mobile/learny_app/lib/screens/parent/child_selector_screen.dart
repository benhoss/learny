import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state_scope.dart';
import '../shared/placeholder_screen.dart';

class ChildSelectorScreen extends StatelessWidget {
  const ChildSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final l = L10n.of(context);
    return PlaceholderScreen(
      title: l.childSelectorTitle,
      subtitle: l.childSelectorSubtitle,
      gradient: LearnyGradients.trust,
      body: Column(
        children: state.children
            .map(
              (child) {
                final isSelected = child.id == state.backendChildId;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isSelected
                        ? LearnyColors.peach
                        : LearnyColors.sky,
                    child: Text(child.name.characters.first),
                  ),
                  title: Text(child.name),
                  subtitle: Text(child.gradeLabel),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: LearnyColors.teal)
                      : null,
                  onTap: isSelected
                      ? null
                      : () => state.selectChild(child.id),
                );
              },
            )
            .toList(),
      ),
    );
  }
}
