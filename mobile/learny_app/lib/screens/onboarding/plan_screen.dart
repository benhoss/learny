import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../state/app_state_scope.dart';
import '../../theme/app_theme.dart';
import '../shared/gradient_scaffold.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  final _codeController = TextEditingController();
  final _deviceController = TextEditingController(text: 'My phone');
  bool _busy = false;
  String? _error;
  bool _promptTracked = false;

  @override
  void dispose() {
    _codeController.dispose();
    _deviceController.dispose();
    super.dispose();
  }

  Future<void> _skip() async {
    final state = AppStateScope.of(context);
    await state.markLinkPromptSkipped();
    await state.saveOnboardingStep(
      step: 'completed',
      completedStep: 'parent_link_prompt',
    );
    final ok = await state.completeOnboarding(force: true);
    if (!ok) {
      if (!mounted) return;
      setState(() {
        _error =
            'Parent consent is required for this age group before finishing.';
      });
      return;
    }
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  Future<void> _linkNow() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final state = AppStateScope.of(context);
    await state.markLinkPromptAccepted(action: 'link_parent');
    final ok = await state.linkChildDeviceWithCode(
      code: _codeController.text.trim(),
      deviceName: _deviceController.text.trim().isEmpty
          ? 'My phone'
          : _deviceController.text.trim(),
    );
    if (!mounted) return;

    setState(() {
      _busy = false;
      _error = ok
          ? null
          : 'Invalid code. Ask your parent to generate a new one.';
    });

    if (ok) {
      final completed = await state.completeOnboarding();
      if (!completed) {
        if (!mounted) return;
        setState(() {
          _error =
              'Parent consent is required for this age group before finishing.';
        });
        return;
      }
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  Future<void> _saveProgress() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final state = AppStateScope.of(context);
    await state.markLinkPromptAccepted(action: 'save_progress');
    final ok = await state.completeOnboarding(force: true);
    if (!mounted) return;
    setState(() => _busy = false);
    if (!ok) {
      setState(() {
        _error =
            'Parent consent is required for this age group before finishing.';
      });
      return;
    }
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    if (!_promptTracked) {
      _promptTracked = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        AppStateScope.of(context).trackOnboardingEvent(
          role: AppStateScope.of(context).isScanFirstOnboarding
              ? 'guest'
              : 'child',
          eventName: 'link_prompt_shown',
          step: 'parent_link_prompt',
          instanceId: AppStateScope.of(context)
              .scanFirstCompletedSessions
              .toString(),
        );
      });
    }

    return GradientScaffold(
      gradient: LearnyGradients.hero,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Connect with a parent (optional)',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.welcome,
                  ),
                  child: const Text('Switch role'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose one: save progress, link with parent, or maybe later.',
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _busy ? null : _saveProgress,
              child: const Text('Save my progress'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: '6-digit parent code',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _deviceController,
              decoration: const InputDecoration(labelText: 'Device name'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _busy ? null : _linkNow,
              child: Text(_busy ? 'Linking...' : 'Link with parent'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 8),
            TextButton(
              onPressed: _busy ? null : _skip,
              child: const Text('Maybe later'),
            ),
          ],
        ),
      ),
    );
  }
}
