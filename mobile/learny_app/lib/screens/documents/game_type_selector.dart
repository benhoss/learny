import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class GameTypeSelector extends StatelessWidget {
  const GameTypeSelector({
    super.key,
    required this.selectedTypes,
    required this.onSelectionChanged,
  });

  final List<String> selectedTypes;
  final ValueChanged<List<String>> onSelectionChanged;

  static const Map<String, String> _labels = {
    'flashcards': 'Flashcards',
    'quiz': 'Quiz',
    'matching': 'Matching',
    'true_false': 'True/False',
    'fill_blank': 'Fill Blank',
    'ordering': 'Ordering',
    'multiple_select': 'Multi Select',
    'short_answer': 'Short Answer',
  };

  @override
  Widget build(BuildContext context) {
    final selected = selectedTypes.toSet();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quiz types',
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _labels.entries.map((entry) {
            final isSelected = selected.contains(entry.key);
            return FilterChip(
              label: Text(entry.value),
              selected: isSelected,
              selectedColor: LearnyColors.teal.withValues(alpha: 0.2),
              checkmarkColor: LearnyColors.teal,
              onSelected: (value) {
                final next = <String>{...selected};
                if (value) {
                  next.add(entry.key);
                } else {
                  if (next.length == 1 && next.contains(entry.key)) {
                    return;
                  }
                  next.remove(entry.key);
                }
                onSelectionChanged(next.toList());
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
