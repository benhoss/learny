import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../routes/app_routes.dart';
import '../../services/haptic_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_tokens.dart';
import '../../state/app_state_scope.dart';
import '../../widgets/animations/fade_in_slide.dart';
import '../../widgets/games/game_scaffold.dart';
import '../../widgets/games/pressable_scale.dart';
import '../../widgets/games/result_summary_card.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final session = state.quizSession;
    final outcome = state.lastGameOutcome;
    final total = outcome?.totalQuestions ?? session?.questions.length ?? 0;
    final correct = outcome?.correctAnswers ?? session?.correctCount ?? 0;
    final roundXp = outcome?.xpEarned ?? (correct * 5);
    final isPackSession = state.inPackSession;
    final hasRetry =
        !isPackSession && (session?.incorrectIndices.isNotEmpty ?? false);
    final tokens = context.tokens;
    final masteryAvg = state.mastery.isEmpty
        ? 0.65
        : state.mastery.values.reduce((a, b) => a + b) / state.mastery.length;
    final masteryDelta = ((masteryAvg * 100).round() * 0.06).round();

    return GameScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const _CelebrationHeader(),
          SizedBox(height: tokens.spaceMd),

          // Title with staggered animation
          FadeInSlide(
            delay: const Duration(milliseconds: 400),
            child: Text(
              'Great Job!',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 6),

          // Subtitle
          FadeInSlide(
            delay: const Duration(milliseconds: 500),
            child: Text(
              'You earned $roundXp XP in this round and kept your streak.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: LearnyColors.neutralMedium,
              ),
            ),
          ),

          SizedBox(height: tokens.spaceLg),

          // Results card
          FadeInSlide(
            delay: const Duration(milliseconds: 600),
            child: ResultSummaryCard(
              correct: correct,
              total: total,
              streak: state.streakDays,
              masteryDelta: masteryDelta,
            ),
          ),

          if (state.lastResultSyncError != null) ...[
            const SizedBox(height: 12),
            FadeInSlide(
              delay: const Duration(milliseconds: 650),
              child: Text(
                'Progress sync is delayed. We will retry automatically.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: LearnyColors.coral),
              ),
            ),
          ],

          const Spacer(),

          // Primary action button
          FadeInSlide(
            delay: const Duration(milliseconds: 700),
            child: PressableScale(
              onTap: () {
                if (isPackSession) {
                  state.completePackSession();
                  state.resetQuiz();
                  state.endPackSession();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.home,
                    (route) => false,
                  );
                } else {
                  state.resetQuiz();
                  Navigator.pushNamed(context, AppRoutes.matching);
                }
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: tokens.spaceMd),
                decoration: BoxDecoration(
                  gradient: tokens.gradientAccent,
                  borderRadius: tokens.radiusFull,
                  boxShadow: tokens.buttonShadow,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isPackSession ? 'Finish Session' : 'Continue',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      LucideIcons.arrowRight,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Secondary action button
          FadeInSlide(
            delay: const Duration(milliseconds: 800),
            child: PressableScale(
              onTap: hasRetry
                  ? () async {
                      await state.retryIncorrectQuestions();
                      if (!context.mounted) {
                        return;
                      }
                      Navigator.pushNamed(context, AppRoutes.quiz);
                    }
                  : () {
                      state.resetQuiz();
                      if (isPackSession) {
                        state.completePackSession();
                        state.endPackSession();
                        Navigator.pushNamed(
                          context,
                          AppRoutes.progressOverview,
                        );
                      } else {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.home,
                          (route) => false,
                        );
                      }
                    },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: tokens.spaceMd),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: tokens.radiusFull,
                  border: Border.all(color: LearnyColors.skyPrimary, width: 2),
                ),
                child: Center(
                  child: Text(
                    hasRetry
                        ? 'Review Mistakes'
                        : (isPackSession ? 'See Progress' : 'Back to Home'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: LearnyColors.skyPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Back to Home link (always visible when hasRetry or isPackSession)
          if (hasRetry || isPackSession) ...[
            const SizedBox(height: 16),
            FadeInSlide(
              delay: const Duration(milliseconds: 900),
              child: PressableScale(
                onTap: () {
                  state.resetQuiz();
                  if (isPackSession) {
                    state.completePackSession();
                    state.endPackSession();
                  }
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.home,
                    (route) => false,
                  );
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: tokens.spaceSm),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.home,
                        size: 18,
                        color: LearnyColors.neutralMedium,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Back to Home',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: LearnyColors.neutralMedium,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CelebrationHeader extends StatefulWidget {
  const _CelebrationHeader();

  @override
  State<_CelebrationHeader> createState() => _CelebrationHeaderState();
}

class _CelebrationHeaderState extends State<_CelebrationHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_BurstDot> _dots;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _dots = _BurstDot.generate(count: 14);

    // Celebration haptic feedback
    HapticService.celebrate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = Curves.easeInOut.transform(_controller.value);
          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Burst dots
              for (final dot in _dots)
                Positioned(
                  left: 100 + dot.dx(t),
                  top: 80 + dot.dy(t),
                  child: Opacity(
                    opacity: dot.opacity(t),
                    child: Container(
                      width: dot.size(t),
                      height: dot.size(t),
                      decoration: BoxDecoration(
                        color: dot.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),

              // Main celebration icon
              Transform.rotate(
                angle: (t - 0.5) * 0.4,
                child: Transform.scale(
                  scale: 0.9 + t * 0.15,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFFFF4E1), Color(0xFFFFE4BC)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: LearnyColors.sunshine.withValues(alpha: 0.4),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        LucideIcons.partyPopper,
                        size: 52,
                        color: LearnyColors.sunshine,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BurstDot {
  const _BurstDot({
    required this.angle,
    required this.radius,
    required this.phase,
    required this.color,
    required this.baseSize,
  });

  final double angle;
  final double radius;
  final double phase;
  final Color color;
  final double baseSize;

  double dx(double t) => cos(angle) * (radius + 10 * sin(t * pi * 2 + phase));
  double dy(double t) => sin(angle) * (radius + 12 * sin(t * pi * 2 + phase));
  double size(double t) => baseSize + 2 * sin(t * pi * 2 + phase);
  double opacity(double t) => 0.5 + 0.5 * sin(t * pi + phase);

  static List<_BurstDot> generate({int count = 12}) {
    final random = Random();
    final colors = [
      LearnyColors.coral,
      LearnyColors.mintPrimary,
      LearnyColors.lavender,
      LearnyColors.sunshine,
      LearnyColors.skyPrimary,
    ];
    return List<_BurstDot>.generate(count, (index) {
      final angle = (2 * pi / count) * index + random.nextDouble() * 0.3;
      final radius = 40 + random.nextDouble() * 25;
      final phase = random.nextDouble() * pi * 2;
      final color = colors[random.nextInt(colors.length)];
      final size = 6 + random.nextDouble() * 5;
      return _BurstDot(
        angle: angle,
        radius: radius,
        phase: phase,
        color: color,
        baseSize: size,
      );
    });
  }
}
