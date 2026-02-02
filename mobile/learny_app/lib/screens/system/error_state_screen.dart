import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../shared/placeholder_screen.dart';

class ErrorStateScreen extends StatelessWidget {
  const ErrorStateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: 'Something Went Wrong',
      subtitle: 'We could not process the document.',
      gradient: LearnyGradients.trust,
      body: const Icon(Icons.error_outline_rounded, size: 80, color: LearnyColors.coral),
      primaryAction: ElevatedButton(
        onPressed: () {},
        child: const Text('Try Again'),
      ),
    );
  }
}
