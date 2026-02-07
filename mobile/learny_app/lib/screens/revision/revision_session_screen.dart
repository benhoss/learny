import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../state/app_state.dart';
import '../../state/app_state_scope.dart';
import '../../theme/app_theme.dart';
import '../shared/gradient_scaffold.dart';

class RevisionSessionScreen extends StatefulWidget {
  const RevisionSessionScreen({super.key});

  @override
  State<RevisionSessionScreen> createState() => _RevisionSessionScreenState();
}

class _RevisionSessionScreenState extends State<RevisionSessionScreen> {
  int? _selectedIndex;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = AppStateScope.of(context);
    if (state.revisionSession == null) {
      state.startRevision();
    }
  }

  Future<void> _submitAnswer(AppState state) async {
    final selected = _selectedIndex;
    if (selected == null) {
      return;
    }
    await state.answerRevisionPrompt(selected);
    if (state.revisionSession?.isComplete ?? false) {
      if (!mounted) {
        return;
      }
      Navigator.pushReplacementNamed(context, AppRoutes.revisionResults);
    } else {
      setState(() => _selectedIndex = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final session = state.revisionSession;
    if (session == null) {
      return GradientScaffold(
        gradient: LearnyGradients.hero,
        appBar: AppBar(title: const Text('Express Session')),
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Text(
              'No revision session is ready yet.\nUpload and complete a game to unlock revision.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
    final prompt = session.currentPrompt;
    final total = session.prompts.length;
    final progress = total == 0 ? 0.0 : (session.currentIndex / total);

    return GradientScaffold(
      gradient: LearnyGradients.hero,
      appBar: AppBar(title: const Text('Express Session')),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              session.subjectLabel,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: LearnyColors.slateMedium),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 16),
            Text(
              prompt?.prompt ?? 'Loading prompt...',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            if (prompt != null &&
                ((prompt.selectionReason ?? '').isNotEmpty ||
                    prompt.confidence != null)) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if ((prompt.selectionReason ?? '').isNotEmpty)
                    _ReasonChip(text: prompt.selectionReason!),
                  if (prompt.confidence != null)
                    _ReasonChip(
                      text: 'Confidence ${(prompt.confidence! * 100).round()}%',
                    ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            if (prompt != null)
              ...List.generate(
                prompt.options.length,
                (index) => _OptionTile(
                  text: prompt.options[index],
                  isSelected: _selectedIndex == index,
                  onTap: () => setState(() => _selectedIndex = index),
                ),
              ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: prompt == null
                    ? null
                    : () async => _submitAnswer(state),
                child: Text(
                  session.currentIndex + 1 >= total ? 'Finish' : 'Next',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReasonChip extends StatelessWidget {
  const _ReasonChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: LearnyColors.skyLight.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: LearnyColors.skyPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
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
      color: isSelected
          ? LearnyColors.teal.withValues(alpha: 0.2)
          : Colors.white,
      child: ListTile(
        leading: Icon(
          isSelected
              ? Icons.check_circle_rounded
              : Icons.radio_button_unchecked,
          color: isSelected ? LearnyColors.teal : LearnyColors.slateLight,
        ),
        title: Text(text),
        onTap: onTap,
      ),
    );
  }
}
