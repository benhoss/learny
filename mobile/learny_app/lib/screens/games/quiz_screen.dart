import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../routes/app_routes.dart';
import '../../models/quiz_question.dart';
import '../../services/haptic_service.dart';
import '../../state/app_state.dart';
import '../../state/app_state_scope.dart';
import '../../theme/app_assets.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_tokens.dart';
import '../../widgets/animations/fade_in_slide.dart';
import '../../widgets/games/answer_chip.dart';
import '../../widgets/games/feedback_banner.dart';
import '../../widgets/games/game_card.dart';
import '../../widgets/games/game_header.dart';
import '../../widgets/games/game_scaffold.dart';
import '../../widgets/games/pressable_scale.dart';

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
  bool _showingResult = false;
  _FeedbackData? _feedback;
  Completer<void>? _feedbackCompleter;

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

    // Validate selection first
    if (question.isTextInput) {
      if (_textController.text.trim().isEmpty) return;
    } else if (question.isOrdering) {
      if (_orderingItems.isEmpty) return;
    } else if (question.isMultiSelect) {
      if (_selectedIndices.isEmpty) return;
    } else {
      if (_selectedIndex == null) return;
    }

    setState(() => _isSubmitting = true);
    final isCorrect = _evaluateAnswer(question);

    // Haptic feedback based on result
    if (isCorrect) {
      HapticService.success();
    } else {
      HapticService.error();
    }

    // Show result state on answer chips
    setState(() {
      _showingResult = true;
    });

    // Brief pause to show correct/incorrect state
    await Future.delayed(const Duration(milliseconds: 600));

    // Show feedback overlay
    await _showInlineFeedback(question, isCorrect);

    // Record answer
    if (question.isTextInput) {
      await state.answerCurrentQuestionText(_textController.text);
    } else if (question.isOrdering) {
      await state.answerCurrentQuestionOrdering(_orderingItems);
    } else if (question.isMultiSelect) {
      await state.answerCurrentQuestionMulti(_selectedIndices.toList());
    } else {
      await state.answerCurrentQuestion(_selectedIndex!);
    }
    if (!mounted) {
      return;
    }

    // Navigate or reset
    if (state.quizSession?.isComplete ?? false) {
      if (state.inPackSession) {
        final nextType = state.nextPackGameType;
        if (nextType != null) {
          state.advancePackGame();
          state.startGameType(nextType);
          Navigator.pushReplacementNamed(
            context,
            state.routeForGameType(nextType),
          );
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
        _showingResult = false;
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
      final correct = (question.correctIndices ?? [question.correctIndex])
          .toSet();
      final selected = _selectedIndices.toSet();
      return selected.isNotEmpty &&
          selected.length == correct.length &&
          selected.containsAll(correct);
    }
    return _selectedIndex == question.correctIndex;
  }

  Future<void> _showInlineFeedback(
    QuizQuestion question,
    bool isCorrect,
  ) async {
    if (_feedbackCompleter != null && !_feedbackCompleter!.isCompleted) {
      _feedbackCompleter!.complete();
    }
    final explanation = question.explanation;
    final subtitle = isCorrect
        ? L10n.of(context).quizCorrectFeedback
        : L10n.of(context).quizIncorrectFeedback;
    _feedbackCompleter = Completer<void>();
    setState(() {
      _feedback = _FeedbackData(
        isCorrect: isCorrect,
        message: explanation?.isNotEmpty == true ? explanation! : subtitle,
      );
    });
    await _feedbackCompleter!.future;
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
      _showingResult = false;
    }

    final tokens = context.tokens;
    final total = session?.questions.length ?? 0;
    final currentIndex = session?.currentIndex ?? 0;
    final progress = total == 0 ? 0.0 : ((currentIndex + 1) / total) * 100;
    final masteryAvg = state.mastery.isEmpty
        ? 0.65
        : state.mastery.values.reduce((a, b) => a + b) / state.mastery.length;

    if (session == null) {
      return const GameScaffold(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (total == 0) {
      return GameScaffold(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                L10n.of(context).quizNoQuizMessage,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.cameraCapture),
                child: Text(L10n.of(context).quizUploadDocument),
              ),
            ],
          ),
        ),
      );
    }

    final hasSelection =
        question != null &&
        (question.isTextInput
            ? _textController.text.trim().isNotEmpty
            : question.isOrdering
            ? _orderingItems.isNotEmpty
            : question.isMultiSelect
            ? _selectedIndices.isNotEmpty
            : _selectedIndex != null);

    return GameScaffold(
      child: Stack(
        children: [
          // Background decoration
          Positioned(
            right: -24,
            top: 10,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.08,
                child: Image.asset(AppImages.renderQuiz, width: 160),
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GameHeader(
                title: _gameTitle(context, state),
                subtitle: total == 0
                    ? L10n.of(context).quizEmptyProgress
                    : L10n.of(context).quizProgress(currentIndex + 1, total),
                progress: progress,
                timerSeconds: 60,
                timerSeed: currentIndex,
                streakCount: state.streakDays,
                masteryPercent: masteryAvg,
              ),

              SizedBox(height: tokens.spaceSm),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  tooltip: L10n.of(context).quizSaveAndExit,
                  onPressed: _isSubmitting
                      ? null
                      : () async {
                          await state.saveAndExitQuiz();
                          if (!context.mounted) {
                            return;
                          }
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRoutes.home,
                            (route) => false,
                          );
                        },
                  icon: const Icon(Icons.pause_circle_outline_rounded),
                ),
              ),

              SizedBox(height: tokens.spaceMd),

              // Question card
              FadeInSlide(
                key: ValueKey('question_$currentIndex'),
                delay: const Duration(milliseconds: 100),
                child: GameCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question?.prompt ??
                            L10n.of(context).quizLoadingQuestion,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                      if (question != null && question.isMultiSelect) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              LucideIcons.checkSquare,
                              size: 16,
                              color: LearnyColors.neutralMedium,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              L10n.of(context).quizSelectAllThatApply,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: LearnyColors.neutralMedium),
                            ),
                          ],
                        ),
                      ],
                      if (question != null && question.isOrdering) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              LucideIcons.arrowUpDown,
                              size: 16,
                              color: LearnyColors.neutralMedium,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              L10n.of(context).quizDragIntoOrder,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: LearnyColors.neutralMedium),
                            ),
                          ],
                        ),
                      ],
                      if (question?.hint != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: EdgeInsets.all(tokens.spaceSm + 4),
                          decoration: BoxDecoration(
                            color: LearnyColors.highlight,
                            borderRadius: tokens.radiusMd,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                LucideIcons.lightbulb,
                                size: 16,
                                color: LearnyColors.sunshine,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  question!.hint!,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: LearnyColors.neutralMedium,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              SizedBox(height: tokens.spaceMd),

              // Answer options
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (question != null && question.isTextInput) ...[
                        FadeInSlide(
                          delay: const Duration(milliseconds: 200),
                          child: GameCard(
                            child: TextField(
                              controller: _textController,
                              decoration: InputDecoration(
                                labelText: L10n.of(context).quizYourAnswer,
                                hintText: L10n.of(context).quizTypeAnswerHint,
                                border: OutlineInputBorder(
                                  borderRadius: tokens.radiusMd,
                                ),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ),
                      ] else if (question != null && question.isOrdering) ...[
                        FadeInSlide(
                          delay: const Duration(milliseconds: 200),
                          child: GameCard(
                            child: ReorderableListView(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              onReorder: (oldIndex, newIndex) {
                                setState(() {
                                  if (newIndex > oldIndex) {
                                    newIndex -= 1;
                                  }
                                  final item = _orderingItems.removeAt(
                                    oldIndex,
                                  );
                                  _orderingItems.insert(newIndex, item);
                                });
                              },
                              children: [
                                for (final item in _orderingItems)
                                  ListTile(
                                    key: ValueKey(item),
                                    leading: const Icon(
                                      Icons.drag_handle_rounded,
                                    ),
                                    title: Text(item),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ] else if (question != null)
                        ...List.generate(question.options.length, (index) {
                          final isCorrectOption =
                              index == question.correctIndex ||
                              (question.correctIndices?.contains(index) ??
                                  false);
                          final isSelected = question.isMultiSelect
                              ? _selectedIndices.contains(index)
                              : _selectedIndex == index;

                          return FadeInSlide(
                            key: ValueKey('option_${currentIndex}_$index'),
                            delay: Duration(milliseconds: 200 + (index * 50)),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: AnswerChip(
                                text: _localizedOption(
                                  context,
                                  question.options[index],
                                ),
                                isSelected: isSelected,
                                isCorrect: _showingResult
                                    ? isCorrectOption
                                    : null,
                                showResult: _showingResult,
                                onTap: _showingResult
                                    ? null
                                    : () {
                                        setState(() {
                                          if (question.isMultiSelect) {
                                            if (_selectedIndices.contains(
                                              index,
                                            )) {
                                              _selectedIndices.remove(index);
                                            } else {
                                              _selectedIndices.add(index);
                                            }
                                          } else {
                                            _selectedIndex = index;
                                          }
                                        });
                                      },
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),

              // Submit button
              FadeInSlide(
                delay: const Duration(milliseconds: 400),
                child: PressableScale(
                  onTap: (question == null || _showingResult || !hasSelection)
                      ? null
                      : () => _submitAnswer(state, question),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: tokens.spaceMd),
                    decoration: BoxDecoration(
                      gradient: hasSelection && !_showingResult
                          ? tokens.gradientAccent
                          : null,
                      color: hasSelection && !_showingResult
                          ? null
                          : LearnyColors.neutralSoft,
                      borderRadius: tokens.radiusFull,
                      boxShadow: hasSelection && !_showingResult
                          ? tokens.buttonShadow
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        (currentIndex + 1 >= total)
                            ? L10n.of(context).quizFinish
                            : L10n.of(context).quizCheckAnswer,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: hasSelection && !_showingResult
                                  ? Colors.white
                                  : LearnyColors.neutralLight,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: tokens.spaceSm),
            ],
          ),

          // Feedback overlay
          if (_feedback != null)
            Positioned.fill(
              child: _FeedbackOverlay(
                data: _feedback!,
                onContinue: () {
                  _feedbackCompleter?.complete();
                  setState(() => _feedback = null);
                },
              ),
            ),
        ],
      ),
    );
  }

  String _localizedOption(BuildContext context, String text) {
    if (text == 'True') return L10n.of(context).trueFalseTrue;
    if (text == 'False') return L10n.of(context).trueFalseFalse;
    return text;
  }

  String _gameTitle(BuildContext context, AppState state) {
    final provided = state.currentGameTitle;
    if (provided != null && provided.trim().isNotEmpty) {
      return provided;
    }
    switch (state.currentGameType) {
      case 'true_false':
        return L10n.of(context).gameTypeTrueFalse;
      case 'multiple_select':
        return L10n.of(context).gameTypeMultiSelect;
      case 'fill_blank':
        return L10n.of(context).gameTypeFillBlank;
      case 'short_answer':
        return L10n.of(context).gameTypeShortAnswer;
      case 'ordering':
        return L10n.of(context).gameTypeOrdering;
      case 'quiz':
      default:
        return L10n.of(context).gameTypeQuiz;
    }
  }
}

class _FeedbackData {
  const _FeedbackData({required this.isCorrect, required this.message});

  final bool isCorrect;
  final String message;
}

class _FeedbackOverlay extends StatefulWidget {
  const _FeedbackOverlay({required this.data, required this.onContinue});

  final _FeedbackData data;
  final VoidCallback onContinue;

  @override
  State<_FeedbackOverlay> createState() => _FeedbackOverlayState();
}

class _FeedbackOverlayState extends State<_FeedbackOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _autoTimer;
  Timer? _countdownTimer;
  int _secondsLeft = 5;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    )..forward();
    _autoTimer = Timer(const Duration(seconds: 5), _handleContinue);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
        return;
      }
      setState(() => _secondsLeft -= 1);
    });
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _countdownTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (!mounted) {
      return;
    }
    widget.onContinue();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        color: Colors.black.withValues(alpha: 0.08),
        child: FeedbackBanner(
          message: widget.data.message,
          isCorrect: widget.data.isCorrect,
          onContinue: _handleContinue,
          secondsLeft: _secondsLeft,
        ),
      ),
    );
  }
}
