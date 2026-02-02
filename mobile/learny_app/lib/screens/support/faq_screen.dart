import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state_scope.dart';
import '../shared/placeholder_screen.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    return PlaceholderScreen(
      title: 'FAQ',
      subtitle: 'Answers to common questions.',
      gradient: LearnyGradients.trust,
      body: Column(
        children: state.faqs
            .map((item) => _FaqItem(question: item.question, answer: item.answer))
            .toList(),
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  const _FaqItem({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(question),
        subtitle: Text(answer),
      ),
    );
  }
}
