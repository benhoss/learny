import 'dart:math';

import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../routes/app_routes.dart';
import '../../state/app_state_scope.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_tokens.dart';
import '../../widgets/animations/fade_in_slide.dart';
import '../../widgets/games/game_scaffold.dart';
import '../../widgets/games/pressable_scale.dart';

class QuizSetupScreen extends StatefulWidget {
  const QuizSetupScreen({super.key});

  @override
  State<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends State<QuizSetupScreen> {
  static const int _minQuestions = 10;
  static const int _maxQuestions = 20;
  int _questionCount = 10;
  bool _loading = true;
  bool _submitting = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }
    _initialized = true;
    _prepare();
  }

  Future<void> _prepare() async {
    final state = AppStateScope.of(context);
    await state.prepareQuizSetup();
    if (!mounted) {
      return;
    }
    _questionCount = _randomQuestionCount();
    setState(() => _loading = false);
  }

  Future<void> _startQuiz() async {
    if (_submitting) {
      return;
    }
    setState(() => _submitting = true);
    final state = AppStateScope.of(context);
    final started = await state.startQuizFromSetup(
      questionCount: _questionCount,
    );
    if (!mounted) {
      return;
    }
    setState(() => _submitting = false);
    if (!started) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.lastResultSyncError ?? 'Unable to start quiz'),
        ),
      );
      return;
    }
    Navigator.pushReplacementNamed(context, AppRoutes.quiz);
  }

  Future<void> _resumeQuiz() async {
    if (_submitting) {
      return;
    }
    setState(() => _submitting = true);
    final state = AppStateScope.of(context);
    final resumed = await state.resumeQuizFromSetup();
    if (!mounted) {
      return;
    }
    setState(() => _submitting = false);
    if (!resumed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.lastResultSyncError ?? 'Unable to resume quiz'),
        ),
      );
      return;
    }
    Navigator.pushReplacementNamed(context, AppRoutes.quiz);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final l10n = L10n.of(context);
    final tokens = context.tokens;

    if (_loading) {
      return const GameScaffold(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final hasQuiz =
        state.gamePayloads['quiz'] != null && state.currentGameId != null;

    if (!hasQuiz) {
      return GameScaffold(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.quizNoQuizMessage, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.cameraCapture),
                child: Text(l10n.quizUploadDocument),
              ),
            ],
          ),
        ),
      );
    }

    final funLine = _questionCount <= 7
        ? l10n.quizSetupFunLineShort
        : (_questionCount <= 14
              ? l10n.quizSetupFunLineMedium
              : l10n.quizSetupFunLineLong);

    return GameScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInSlide(
            child: Text(
              l10n.quizSetupTitle,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          SizedBox(height: tokens.spaceSm),
          FadeInSlide(
            delay: const Duration(milliseconds: 80),
            child: Text(
              l10n.quizSetupSubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: LearnyColors.neutralMedium,
              ),
            ),
          ),
          SizedBox(height: tokens.spaceLg),
          FadeInSlide(
            delay: const Duration(milliseconds: 120),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(tokens.spaceMd),
              decoration: BoxDecoration(
                color: LearnyColors.skyLight.withValues(alpha: 0.35),
                borderRadius: tokens.radiusLg,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.quiz_rounded,
                    color: LearnyColors.skyPrimary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.quizSetupCountValue(_questionCount),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: tokens.spaceSm),
          FadeInSlide(
            delay: const Duration(milliseconds: 160),
            child: Text(
              funLine,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: LearnyColors.teal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: tokens.spaceLg),
          if (state.hasActiveQuizSession) ...[
            FadeInSlide(
              delay: const Duration(milliseconds: 240),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(tokens.spaceMd),
                decoration: BoxDecoration(
                  color: LearnyColors.highlight,
                  borderRadius: tokens.radiusMd,
                  border: Border.all(
                    color: LearnyColors.sunshine.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  l10n.quizSetupResumeHint(state.activeQuizRemainingCount),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            SizedBox(height: tokens.spaceMd),
            FadeInSlide(
              delay: const Duration(milliseconds: 280),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _submitting ? null : _resumeQuiz,
                  child: Text(l10n.quizSetupResumeButton),
                ),
              ),
            ),
            SizedBox(height: tokens.spaceSm),
          ],
          const Spacer(),
          FadeInSlide(
            delay: const Duration(milliseconds: 320),
            child: PressableScale(
              onTap: _submitting ? null : _startQuiz,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: tokens.spaceMd),
                decoration: BoxDecoration(
                  gradient: tokens.gradientAccent,
                  borderRadius: tokens.radiusFull,
                  boxShadow: tokens.buttonShadow,
                ),
                child: Center(
                  child: Text(
                    l10n.quizSetupStartButton,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
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
    );
  }

  int _randomQuestionCount() {
    return _minQuestions +
        Random().nextInt(_maxQuestions - _minQuestions + 1);
  }
}
