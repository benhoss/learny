import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../models/quiz_question.dart';
import '../../state/app_state.dart';
import '../../state/app_state_scope.dart';
import '../../theme/app_assets.dart';
import '../../theme/app_theme.dart';
import '../shared/gradient_scaffold.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int? _selectedIndex;
  final Set<int> _selectedIndices = <int>{};
  final TextEditingController _textController = TextEditingController();
  List<String> _orderingItems = <String>[];
  String? _lastQuestionId;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = AppStateScope.of(context);
    if (state.quizSession == null) {
      state.startQuiz();
    }
  }

  Future<void> _submitAnswer(AppState state, QuizQuestion question) async {
    if (_isSubmitting) {
      return;
    }
    setState(() => _isSubmitting = true);
    final isCorrect = _evaluateAnswer(question);
    await _showFeedbackDialog(context, question, isCorrect);

    if (question.isTextInput) {
      final value = _textController.text;
      if (value.trim().isEmpty) {
        setState(() => _isSubmitting = false);
        return;
      }
      state.answerCurrentQuestionText(value);
    } else if (question.isOrdering) {
      if (_orderingItems.isEmpty) {
        setState(() => _isSubmitting = false);
        return;
      }
      state.answerCurrentQuestionOrdering(_orderingItems);
    } else if (question.isMultiSelect) {
      if (_selectedIndices.isEmpty) {
        setState(() => _isSubmitting = false);
        return;
      }
      state.answerCurrentQuestionMulti(_selectedIndices.toList());
    } else {
      final selected = _selectedIndex;
      if (selected == null) {
        setState(() => _isSubmitting = false);
        return;
      }
      state.answerCurrentQuestion(selected);
    }
    if (state.quizSession?.isComplete ?? false) {
      if (state.inPackSession) {
        final nextType = state.nextPackGameType;
        if (nextType != null) {
          state.advancePackGame();
          state.startGameType(nextType);
          Navigator.pushReplacementNamed(context, state.routeForGameType(nextType));
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.results);
        }
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.results);
      }
    } else {
      setState(() {
        _selectedIndex = null;
        _selectedIndices.clear();
        _textController.clear();
        _orderingItems = <String>[];
      });
    }
    setState(() => _isSubmitting = false);
  }

  bool _evaluateAnswer(QuizQuestion question) {
    if (question.isTextInput) {
      final normalized = _textController.text.trim().toLowerCase();
      final answers = <String>{};
      if (question.answerText != null) {
        answers.add(question.answerText!.trim().toLowerCase());
      }
      for (final item in question.acceptedAnswers ?? <String>[]) {
        answers.add(item.trim().toLowerCase());
      }
      return answers.contains(normalized);
    }
    if (question.isOrdering) {
      final expected = question.orderedSequence ?? <String>[];
      if (expected.length != _orderingItems.length) {
        return false;
      }
      for (var i = 0; i < expected.length; i += 1) {
        if (expected[i] != _orderingItems[i]) {
          return false;
        }
      }
      return true;
    }
    if (question.isMultiSelect) {
      final correct = (question.correctIndices ?? [question.correctIndex]).toSet();
      final selected = _selectedIndices.toSet();
      return selected.isNotEmpty &&
          selected.length == correct.length &&
          selected.containsAll(correct);
    }
    return _selectedIndex == question.correctIndex;
  }

  Future<void> _showFeedbackDialog(
    BuildContext context,
    QuizQuestion question,
    bool isCorrect,
  ) async {
    final explanation = question.explanation;
    final title = isCorrect ? 'Correct!' : 'Not quite';
    final color = isCorrect ? LearnyColors.teal : LearnyColors.coral;
    final subtitle = isCorrect
        ? 'You’re on a roll.'
        : 'Review the explanation and keep going.';
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                color: color,
              ),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: Text(
            explanation?.isNotEmpty == true
                ? explanation!
                : subtitle,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Continue',
                style: TextStyle(color: color),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final session = state.quizSession;
    final question = session?.currentQuestion;
    if (question?.id != null && question!.id != _lastQuestionId) {
      _lastQuestionId = question.id;
      _selectedIndex = null;
      _selectedIndices.clear();
      _textController.clear();
      _orderingItems = List<String>.from(question.options);
    }

    return GradientScaffold(
      gradient: LearnyGradients.hero,
      appBar: AppBar(title: Text(_gameTitle(state))),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: 10,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.14,
                child: Image.asset(
                  AppImages.renderQuiz,
                  width: 200,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session == null
                      ? 'Question 0 / 0'
                      : 'Question ${session.currentIndex + 1} / ${session.questions.length}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: LearnyColors.slateMedium),
                ),
                const SizedBox(height: 12),
                Text(
                  question?.prompt ?? 'Loading question...',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                if (question != null && question.isMultiSelect) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Select all that apply.',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: LearnyColors.slateMedium),
                  ),
                ],
                if (question != null && question.isOrdering) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Drag items into the correct order.',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: LearnyColors.slateMedium),
                  ),
                ],
                if (question?.hint != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    question!.hint!,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: LearnyColors.slateMedium),
                  ),
                ],
                const SizedBox(height: 20),
                if (question != null && question.isTextInput) ...[
                  TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      labelText: 'Your answer',
                    ),
                  ),
                ] else if (question != null && question.isOrdering) ...[
                  ReorderableListView(
                    shrinkWrap: true,
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) {
                          newIndex -= 1;
                        }
                        final item = _orderingItems.removeAt(oldIndex);
                        _orderingItems.insert(newIndex, item);
                      });
                    },
                    children: [
                      for (final item in _orderingItems)
                        ListTile(
                          key: ValueKey(item),
                          leading: const Icon(Icons.drag_handle_rounded),
                          title: Text(item),
                        ),
                    ],
                  ),
                ] else if (question != null && question.isMultiSelect)
                  ...List.generate(
                    question.options.length,
                    (index) => _MultiOptionTile(
                      text: question.options[index],
                      isSelected: _selectedIndices.contains(index),
                      onTap: () => setState(() {
                        if (_selectedIndices.contains(index)) {
                          _selectedIndices.remove(index);
                        } else {
                          _selectedIndices.add(index);
                        }
                      }),
                    ),
                  )
                else if (question != null)
                  ...List.generate(
                    question.options.length,
                    (index) => _OptionTile(
                      text: question.options[index],
                      isSelected: _selectedIndex == index,
                      onTap: () => setState(() => _selectedIndex = index),
                    ),
                  ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: question == null ? null : () => _submitAnswer(state, question),
                    child: Text((session?.currentIndex ?? 0) + 1 >= (session?.questions.length ?? 1)
                        ? 'Finish'
                        : 'Continue'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _gameTitle(AppState state) {
    final provided = state.currentGameTitle;
    if (provided != null && provided.trim().isNotEmpty) {
      return provided;
    }
    switch (state.currentGameType) {
      case 'true_false':
        return 'True or False';
      case 'multiple_select':
        return 'Choose All That Apply';
      case 'fill_blank':
        return 'Fill in the Blank';
      case 'short_answer':
        return 'Short Answer';
      case 'ordering':
        return 'Put in Order';
      case 'quiz':
      default:
        return 'Quick Quiz';
    }
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected ? LearnyColors.teal.withValues(alpha: 0.2) : Colors.white,
      child: ListTile(
        leading: Icon(
          isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
          color: isSelected ? LearnyColors.teal : LearnyColors.slateLight,
        ),
        title: Text(text),
        onTap: onTap,
      ),
    );
  }
}

class _MultiOptionTile extends StatelessWidget {
  const _MultiOptionTile({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected ? LearnyColors.teal.withValues(alpha: 0.2) : Colors.white,
      child: ListTile(
        leading: Icon(
          isSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
          color: isSelected ? LearnyColors.teal : LearnyColors.slateLight,
        ),
        title: Text(text),
        onTap: onTap,
      ),
    );
  }
}
