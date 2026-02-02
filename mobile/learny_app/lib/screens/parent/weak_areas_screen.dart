import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state_scope.dart';
import '../shared/placeholder_screen.dart';

class WeakAreasScreen extends StatelessWidget {
  const WeakAreasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    return PlaceholderScreen(
      title: 'Weak Areas',
      subtitle: 'Focus zones to review next.',
      gradient: LearnyGradients.trust,
      body: Column(
        children: state.weakAreas
            .map(
              (area) => ListTile(
                leading: const Icon(Icons.error_outline_rounded, color: LearnyColors.coral),
                title: Text(area.title),
                subtitle: Text(area.note),
              ),
            )
            .toList(),
      ),
    );
  }
}
