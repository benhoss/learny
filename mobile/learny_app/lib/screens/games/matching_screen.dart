import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../routes/app_routes.dart';
import '../../services/haptic_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_tokens.dart';
import '../../state/app_state.dart';
import '../../state/app_state_scope.dart';
import '../../widgets/animations/fade_in_slide.dart';
import '../../widgets/games/game_header.dart';
import '../../widgets/games/game_scaffold.dart';
import '../../widgets/games/pressable_scale.dart';

class MatchingScreen extends StatefulWidget {
  const MatchingScreen({super.key});

  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen> {
  final Set<String> _matchedPairIds = {};
  String? _selectedId;
  String? _lastExplanation;
  int _explanationToken = 0;

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final payload = state.matchingPayload ?? {};
    final title = payload['title']?.toString() ?? L10n.of(context).matchingDefaultTitle;
    final intro = payload['intro']?.toString();
    final pairs = (payload['pairs'] as List<dynamic>? ?? [])
        .map((item) => item as Map<String, dynamic>)
        .toList();

    // Build items list with pair IDs
    final items = <_MatchItem>[];
    for (var i = 0; i < pairs.length; i++) {
      final pair = pairs[i];
      final left = pair['left']?.toString();
      final right = pair['right']?.toString();
      final explanation = pair['explanation']?.toString();
      final pairId = 'pair_$i';

      if (left != null) {
        items.add(
          _MatchItem(
            id: '${pairId}_left',
            text: left,
            pairId: pairId,
            explanation: explanation,
          ),
        );
      }
      if (right != null) {
        items.add(
          _MatchItem(
            id: '${pairId}_right',
            text: right,
            pairId: pairId,
            explanation: explanation,
          ),
        );
      }
    }

    // Shuffle items once on first build
    if (_shuffledItems == null || _shuffledItems!.length != items.length) {
      _shuffledItems = List.from(items)..shuffle();
    }

    final totalPairs = pairs.length;
    final allMatched = totalPairs > 0 && _matchedPairIds.length == totalPairs;
    final tokens = context.tokens;
    final progress = totalPairs == 0
        ? 0.0
        : (_matchedPairIds.length / totalPairs) * 100;

    return GameScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GameHeader(
            title: title,
            subtitle: intro?.isNotEmpty == true
                ? intro
                : L10n.of(context).matchingSubtitle,
            progress: progress,
            timerSeconds: 75,
            timerSeed: _matchedPairIds.length,
            streakCount: state.streakDays,
            masteryPercent: state.mastery.isEmpty
                ? 0.65
                : state.mastery.values.reduce((a, b) => a + b) /
                      state.mastery.length,
          ),
          SizedBox(height: tokens.spaceMd),

          // Instruction
          FadeInSlide(
            delay: const Duration(milliseconds: 100),
            child: Text(
              L10n.of(context).matchingSubtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: LearnyColors.neutralMedium,
              ),
            ),
          ),

          SizedBox(height: tokens.spaceMd),

          // Explanation card (shows when match is made)
          if (_lastExplanation != null && _lastExplanation!.isNotEmpty) ...[
            _ExplanationCard(
              explanation: _lastExplanation!,
              onDismiss: () => setState(() => _lastExplanation = null),
            ),
            SizedBox(height: tokens.spaceMd),
          ],

          // Grid of matching items
          Expanded(
            child: items.isEmpty
                ? Center(child: Text(L10n.of(context).matchingNoItems))
                : FadeInSlide(
                    delay: const Duration(milliseconds: 200),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.5,
                          ),
                      itemCount: _shuffledItems!.length,
                      itemBuilder: (context, index) {
                        final item = _shuffledItems![index];
                        final isMatched = _matchedPairIds.contains(item.pairId);
                        final isSelected = _selectedId == item.id;

                        return _MatchTile(
                          item: item,
                          isSelected: isSelected,
                          isMatched: isMatched,
                          onTap: isMatched ? null : () => _handleSelect(item),
                        );
                      },
                    ),
                  ),
          ),

          // Progress indicator
          FadeInSlide(
            delay: const Duration(milliseconds: 300),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: tokens.spaceMd),
              child: Center(
                child: Text(
                  L10n.of(context).matchingProgress(_matchedPairIds.length, totalPairs),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: LearnyColors.neutralLight,
                  ),
                ),
              ),
            ),
          ),

          // Continue button (when all matched)
          if (allMatched) ...[
            FadeInSlide(
              delay: const Duration(milliseconds: 100),
              child: PressableScale(
                onTap: () async => _handleComplete(state, pairs),
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
                      L10n.of(context).matchingContinue,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<_MatchItem>? _shuffledItems;

  void _handleSelect(_MatchItem item) {
    if (_selectedId == null) {
      // First selection
      HapticService.select();
      setState(() => _selectedId = item.id);
    } else if (_selectedId == item.id) {
      // Deselect
      setState(() => _selectedId = null);
    } else {
      // Check for match
      final selectedItem = _shuffledItems!.firstWhere(
        (i) => i.id == _selectedId,
      );

      if (selectedItem.pairId == item.pairId) {
        // Match found!
        HapticService.matchFound();
        final explanation = item.explanation ?? selectedItem.explanation;
        setState(() {
          _matchedPairIds.add(item.pairId);
          _selectedId = null;
          if (explanation != null && explanation.isNotEmpty) {
            _lastExplanation = explanation;
            _explanationToken++;
          }
        });

        // Auto-dismiss explanation after 3 seconds
        final token = _explanationToken;
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted && _explanationToken == token) {
            setState(() => _lastExplanation = null);
          }
        });
      } else {
        // No match - briefly show error then reset
        HapticService.noMatch();
        setState(() => _selectedId = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(L10n.of(context).matchingMismatch),
            backgroundColor: LearnyColors.coral.withValues(alpha: 0.9),
            duration: const Duration(milliseconds: 800),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _handleComplete(
    AppState state,
    List<Map<String, dynamic>> pairs,
  ) async {
    await state.completeMatchingGame(pairs);
    if (!mounted) {
      return;
    }

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
  }
}

class _MatchItem {
  const _MatchItem({
    required this.id,
    required this.text,
    required this.pairId,
    this.explanation,
  });

  final String id;
  final String text;
  final String pairId;
  final String? explanation;
}

class _MatchTile extends StatelessWidget {
  const _MatchTile({
    required this.item,
    required this.isSelected,
    required this.isMatched,
    this.onTap,
  });

  final _MatchItem item;
  final bool isSelected;
  final bool isMatched;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    Color bgColor;
    Color borderColor;

    if (isMatched) {
      bgColor = LearnyColors.mintLight;
      borderColor = LearnyColors.mintPrimary;
    } else if (isSelected) {
      bgColor = LearnyColors.skyLight;
      borderColor = LearnyColors.skyPrimary;
    } else {
      bgColor = Colors.white;
      borderColor = LearnyColors.neutralSoft;
    }

    return PressableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.all(tokens.spaceMd),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: tokens.radiusXl,
          border: Border.all(color: borderColor, width: 2),
          boxShadow: isMatched || isSelected ? tokens.cardShadow : null,
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                item.text,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: LearnyColors.neutralDark,
                ),
              ),
            ),
            // Animated checkmark badge for matched items
            if (isMatched)
              Positioned(top: -4, right: -4, child: _AnimatedCheckBadge()),
          ],
        ),
      ),
    );
  }
}

class _AnimatedCheckBadge extends StatefulWidget {
  @override
  State<_AnimatedCheckBadge> createState() => _AnimatedCheckBadgeState();
}

class _AnimatedCheckBadgeState extends State<_AnimatedCheckBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: LearnyColors.mintPrimary,
          shape: BoxShape.circle,
        ),
        child: const Icon(LucideIcons.check, color: Colors.white, size: 14),
      ),
    );
  }
}

class _ExplanationCard extends StatelessWidget {
  const _ExplanationCard({required this.explanation, required this.onDismiss});

  final String explanation;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return FadeInSlide(
      child: Container(
        padding: EdgeInsets.all(tokens.spaceMd),
        decoration: BoxDecoration(
          color: LearnyColors.mintLight,
          borderRadius: tokens.radiusLg,
          border: Border.all(color: LearnyColors.mintPrimary),
        ),
        child: Row(
          children: [
            const Icon(
              LucideIcons.lightbulb,
              color: LearnyColors.mintPrimary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                explanation,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: LearnyColors.neutralDark,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(LucideIcons.x, size: 18),
              color: LearnyColors.mintPrimary,
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ),
      ),
    );
  }
}
