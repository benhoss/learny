import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../shared/placeholder_screen.dart';

class MasteryDetailScreen extends StatelessWidget {
  const MasteryDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: 'Mastery Details',
      subtitle: 'Concept-level breakdown for Fractions.',
      gradient: LearnyGradients.trust,
      body: Column(
        children: const [
          ListTile(
            leading: Icon(Icons.check_circle_rounded, color: LearnyColors.teal),
            title: Text('Equivalent fractions'),
            subtitle: Text('Mastered'),
          ),
          ListTile(
            leading: Icon(Icons.timelapse_rounded, color: LearnyColors.coral),
            title: Text('Adding fractions'),
            subtitle: Text('Practicing'),
          ),
          ListTile(
            leading: Icon(Icons.error_outline_rounded, color: LearnyColors.purple),
            title: Text('Mixed numbers'),
            subtitle: Text('Needs review'),
          ),
        ],
      ),
    );
  }
}
