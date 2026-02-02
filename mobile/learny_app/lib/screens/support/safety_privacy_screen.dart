import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../shared/placeholder_screen.dart';

class SafetyPrivacyScreen extends StatelessWidget {
  const SafetyPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: 'Safety & Privacy',
      subtitle: 'Built for kids, trusted by parents.',
      gradient: LearnyGradients.trust,
      body: Column(
        children: const [
          ListTile(
            leading: Icon(Icons.shield_rounded, color: LearnyColors.coral),
            title: Text('COPPA compliant'),
            subtitle: Text('Parental consent required'),
          ),
          ListTile(
            leading: Icon(Icons.lock_rounded, color: LearnyColors.teal),
            title: Text('Encrypted storage'),
            subtitle: Text('Files are protected'),
          ),
          ListTile(
            leading: Icon(Icons.visibility_off_rounded, color: LearnyColors.purple),
            title: Text('No ads, no selling'),
            subtitle: Text('We do not monetize data'),
          ),
        ],
      ),
    );
  }
}
