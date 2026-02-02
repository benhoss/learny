import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state.dart';
import '../../state/app_state_scope.dart';
import '../shared/gradient_scaffold.dart';

class MatchingScreen extends StatefulWidget {
  const MatchingScreen({super.key});

  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen> {
  final Map<String, String> _matches = {};
  final Map<String, String> _explanations = {};
  String? _selectedLeft;
  String? _selectedRight;
  String? _lastExplanation;
  int _explanationToken = 0;

  void _tryMatch(Map<String, String> pairMap) {
    final left = _selectedLeft;
    final right = _selectedRight;
    if (left == null || right == null) {
      return;
    }
    final correctRight = pairMap[left];
    if (correctRight == right) {
      _matches[left] = right;
      final explanation = _explanations[left];
      setState(() {
        if (explanation != null && explanation.isNotEmpty) {
          _lastExplanation = explanation;
          _explanationToken += 1;
        }
        _selectedLeft = null;
        _selectedRight = null;
      });
      final token = _explanationToken;
      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted || _explanationToken != token) {
          return;
        }
        setState(() => _lastExplanation = null);
      });
      return;
    }
    setState(() {
      _selectedLeft = null;
      _selectedRight = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Not a match. Try again.'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final payload = state.matchingPayload ?? {};
    final title = payload['title']?.toString() ?? 'Matching Game';
    final intro = payload['intro']?.toString();
    final pairs = (payload['pairs'] as List<dynamic>? ?? [])
        .map((item) => item as Map<String, dynamic>)
        .toList();
    final leftItems = <String>[];
    final rightItems = <String>[];
    final pairMap = <String, String>{};
    for (final pair in pairs) {
      final left = pair['left']?.toString();
      final right = pair['right']?.toString();
      final explanation = pair['explanation']?.toString();
      if (left != null) {
        leftItems.add(left);
        if (explanation != null) {
          _explanations[left] = explanation;
        }
      }
      if (right != null) {
        rightItems.add(right);
      }
      if (left != null && right != null) {
        pairMap[left] = right;
      }
    }
    final allMatched = leftItems.isNotEmpty && _matches.length == leftItems.length;
    final shuffledRight = List<String>.from(rightItems)..shuffle();
    return GradientScaffold(
      gradient: LearnyGradients.hero,
      appBar: AppBar(title: Text(title)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              intro?.isNotEmpty == true ? intro! : 'Match the items',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            if (_lastExplanation != null && _lastExplanation!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: LearnyColors.teal.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: LearnyColors.teal.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_rounded, color: LearnyColors.teal),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _lastExplanation!,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: LearnyColors.slateDark),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      color: LearnyColors.teal,
                      onPressed: () => setState(() => _lastExplanation = null),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            Expanded(
              child: leftItems.isEmpty || rightItems.isEmpty
                  ? GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      children: const [
                        _MatchCard(label: '1/2'),
                        _MatchCard(label: 'Pie chart'),
                        _MatchCard(label: '3/4'),
                        _MatchCard(label: 'Bar chart'),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: ListView.separated(
                            itemCount: leftItems.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final label = leftItems[index];
                              final matched = _matches.containsKey(label);
                              return _MatchCard(
                                label: label,
                                isSelected: _selectedLeft == label,
                                isMatched: matched,
                                onTap: matched
                                    ? null
                                    : () {
                                        setState(() {
                                          _selectedLeft = label;
                                          _tryMatch(pairMap);
                                        });
                                      },
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ListView.separated(
                            itemCount: shuffledRight.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final label = shuffledRight[index];
                              final matched = _matches.containsValue(label);
                              return _MatchCard(
                                label: label,
                                isSelected: _selectedRight == label,
                                isMatched: matched,
                                onTap: matched
                                    ? null
                                    : () {
                                        setState(() {
                                          _selectedRight = label;
                                          _tryMatch(pairMap);
                                        });
                                      },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: !allMatched
                    ? null
                    : () {
                      if (state.inPackSession) {
                        state.advancePackSession(PackSessionStage.results);
                      }
                      Navigator.pushNamed(context, AppRoutes.results);
                    },
                child: const Text('Finish Round'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({
    required this.label,
    this.isSelected = false,
    this.isMatched = false,
    this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool isMatched;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bg = isMatched
        ? LearnyColors.teal.withValues(alpha: 0.2)
        : isSelected
            ? LearnyColors.coral.withValues(alpha: 0.2)
            : Colors.white;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isMatched
                ? LearnyColors.teal
                : isSelected
                    ? LearnyColors.coral
                    : Colors.transparent,
          ),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
