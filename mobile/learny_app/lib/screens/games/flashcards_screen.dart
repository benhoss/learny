import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state.dart';
import '../../state/app_state_scope.dart';
import '../shared/gradient_scaffold.dart';

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  bool _showBack = false;

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final payload = state.flashcardsPayload ?? {};
    final title = payload['title']?.toString() ?? 'Flashcards';
    final intro = payload['intro']?.toString();
    final cards = (payload['cards'] as List<dynamic>? ?? [])
        .map((item) => item as Map<String, dynamic>)
        .toList();
    final card = cards.isNotEmpty ? cards.first : <String, dynamic>{};
    final front = card['front']?.toString() ?? 'Front';
    final back = card['back']?.toString() ?? 'Back';
    final hint = card['hint']?.toString();

    return GradientScaffold(
      gradient: LearnyGradients.hero,
      appBar: AppBar(title: Text(title)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (intro != null && intro.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  intro,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: LearnyColors.slateMedium),
                ),
              ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 20,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: () => setState(() => _showBack = !_showBack),
                child: Column(
                  children: [
                    Text(
                      _showBack ? 'Back' : 'Front',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: LearnyColors.slateLight),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _showBack ? back : front,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    if (hint != null && hint.isNotEmpty && !_showBack) ...[
                      const SizedBox(height: 12),
                      Text(
                        hint,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: LearnyColors.slateMedium),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      'Tap to flip',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: LearnyColors.slateMedium),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _showBack = !_showBack),
                    child: Text(_showBack ? 'Show Front' : 'Show Back'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (state.inPackSession) {
                        final nextType = state.nextPackGameType;
                        if (nextType != null) {
                          state.advancePackGame();
                          state.startGameType(nextType);
                          Navigator.pushNamed(context, state.routeForGameType(nextType));
                          return;
                        }
                      }
                      state.startQuiz();
                      Navigator.pushNamed(context, AppRoutes.quiz);
                    },
                    child: const Text('Next'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
