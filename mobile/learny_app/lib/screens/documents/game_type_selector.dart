import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';

class GameTypeSelector extends StatelessWidget {
  const GameTypeSelector({
    super.key,
    required this.selectedTypes,
    required this.onSelectionChanged,
  });

  final List<String> selectedTypes;
  final ValueChanged<List<String>> onSelectionChanged;

  static Map<String, String> _labels(L10n l) => {
    'flashcards': l.gameTypeFlashcards,
    'quiz': l.gameTypeQuiz,
    'matching': l.gameTypeMatching,
    'true_false': l.gameTypeTrueFalse,
    'fill_blank': l.gameTypeFillBlank,
    'ordering': l.gameTypeOrdering,
    'multiple_select': l.gameTypeMultiSelect,
    'short_answer': l.gameTypeShortAnswer,
  };

  @override
  Widget build(BuildContext context) {
    final selected = selectedTypes.toSet();
    final labels = _labels(L10n.of(context));
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
          children: labels.entries.map((entry) {
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
