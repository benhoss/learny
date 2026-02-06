import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../routes/app_routes.dart';
import '../../services/haptic_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_tokens.dart';
import '../../state/app_state.dart';
import '../../state/app_state_scope.dart';
import '../../widgets/animations/fade_in_slide.dart';
import '../../widgets/animations/flip_card.dart';
import '../../widgets/games/game_header.dart';
import '../../widgets/games/game_scaffold.dart';
import '../../widgets/games/pressable_scale.dart';

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  final GlobalKey<FlipCardState> _flipCardKey = GlobalKey<FlipCardState>();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final payload = state.flashcardsPayload ?? {};
    final title = payload['title']?.toString() ?? 'Flashcards';
    final intro = payload['intro']?.toString();
    final cards = (payload['cards'] as List<dynamic>? ?? [])
        .map((item) => item as Map<String, dynamic>)
        .toList();

    final totalCards = cards.length;
    final card = cards.isNotEmpty && _currentIndex < cards.length
        ? cards[_currentIndex]
        : <String, dynamic>{};
    final front = card['front']?.toString() ?? 'Front';
    final back = card['back']?.toString() ?? 'Back';
    final hint = card['hint']?.toString();

    final tokens = context.tokens;
    final progress = totalCards == 0
        ? 0.0
        : ((_currentIndex + 1) / totalCards) * 100;
    final masteryAvg = state.mastery.isEmpty
        ? 0.65
        : state.mastery.values.reduce((a, b) => a + b) / state.mastery.length;

    final isLastCard = _currentIndex >= totalCards - 1;

    return GameScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GameHeader(
            title: title,
            subtitle: totalCards == 0
                ? 'Card 0 / 0'
                : 'Card ${_currentIndex + 1} of $totalCards',
            progress: progress,
            timerSeconds: 45,
            timerSeed: _currentIndex,
            streakCount: state.streakDays,
            masteryPercent: masteryAvg,
          ),
          SizedBox(height: tokens.spaceLg),

          // Intro text if present
          if (intro != null && intro.isNotEmpty) ...[
            FadeInSlide(
              delay: const Duration(milliseconds: 100),
              child: Container(
                padding: EdgeInsets.all(tokens.spaceMd),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: tokens.radiusXl,
                  boxShadow: tokens.cardShadow,
                ),
                child: Text(
                  intro,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: LearnyColors.neutralMedium,
                  ),
                ),
              ),
            ),
            SizedBox(height: tokens.spaceMd),
          ],

          // Flashcard with flip animation
          Expanded(
            child: FadeInSlide(
              delay: const Duration(milliseconds: 200),
              child: FlipCard(
                key: _flipCardKey,
                front: _FlashcardFace(
                  content: front,
                  hint: hint,
                  isFront: true,
                ),
                back: _FlashcardFace(content: back, isFront: false),
              ),
            ),
          ),

          SizedBox(height: tokens.spaceLg),

          // Action buttons
          FadeInSlide(
            delay: const Duration(milliseconds: 300),
            child: Row(
              children: [
                // Flip button
                Expanded(
                  child: PressableScale(
                    onTap: () {
                      HapticService.flip();
                      _flipCardKey.currentState?.flip();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: tokens.spaceMd),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: tokens.radiusFull,
                        border: Border.all(
                          color: LearnyColors.skyPrimary,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.rotateCw,
                            color: LearnyColors.skyPrimary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Flip Card',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: LearnyColors.skyPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Next button
                Expanded(
                  child: PressableScale(
                    onTap: () async =>
                        _handleNext(state, isLastCard, totalCards, cards),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: tokens.spaceMd),
                      decoration: BoxDecoration(
                        gradient: tokens.gradientAccent,
                        borderRadius: tokens.radiusFull,
                        boxShadow: tokens.buttonShadow,
                      ),
                      child: Center(
                        child: Text(
                          isLastCard ? 'Finish' : 'Got it! Next',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleNext(
    AppState state,
    bool isLastCard,
    int totalCards,
    List<Map<String, dynamic>> cards,
  ) async {
    if (isLastCard || totalCards == 0) {
      await state.completeFlashcardsGame(cards);
      if (!mounted) {
        return;
      }

      // Navigate to next game or results
      if (state.inPackSession) {
        final nextType = state.nextPackGameType;
        if (nextType != null) {
          state.advancePackGame();
          state.startGameType(nextType);
          Navigator.pushReplacementNamed(
            context,
            state.routeForGameType(nextType),
          );
          return;
        }
      }
      Navigator.pushReplacementNamed(context, AppRoutes.results);
    } else {
      // Go to next card
      _flipCardKey.currentState?.reset();
      setState(() {
        _currentIndex++;
      });
    }
  }
}

class _FlashcardFace extends StatelessWidget {
  const _FlashcardFace({
    required this.content,
    required this.isFront,
    this.hint,
  });

  final String content;
  final bool isFront;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(tokens.spaceLg),
      decoration: BoxDecoration(
        gradient: isFront
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [LearnyColors.mintLight, LearnyColors.skyLight],
              ),
        color: isFront ? Colors.white : null,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isFront ? LearnyColors.neutralSoft : LearnyColors.mintPrimary,
          width: 2,
        ),
        boxShadow: tokens.cardShadow,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Label
          Text(
            isFront ? 'Question' : 'Answer',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: LearnyColors.neutralLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: tokens.spaceMd),

          // Content
          Text(
            content,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: LearnyColors.neutralDark,
              height: 1.3,
            ),
          ),

          // Hint (front only)
          if (isFront && hint != null && hint!.isNotEmpty) ...[
            SizedBox(height: tokens.spaceMd),
            Text(
              hint!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: LearnyColors.neutralMedium,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          const Spacer(),

          // Tap to flip hint
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.rotateCw,
                size: 16,
                color: isFront
                    ? LearnyColors.neutralLight
                    : LearnyColors.neutralMedium,
              ),
              const SizedBox(width: 6),
              Text(
                'Tap to flip',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isFront
                      ? LearnyColors.neutralLight
                      : LearnyColors.neutralMedium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
