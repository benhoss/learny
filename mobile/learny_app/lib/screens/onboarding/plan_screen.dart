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

  @override
  void dispose() {
    _codeController.dispose();
    _deviceController.dispose();
    super.dispose();
  }

  Future<void> _skip() async {
    final state = AppStateScope.of(context);
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

  @override
  Widget build(BuildContext context) {
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
            const Text('You can skip this now and do it later in settings.'),
            const SizedBox(height: 20),
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
              child: Text(_busy ? 'Linking...' : 'Link device now'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 8),
            TextButton(
              onPressed: _busy ? null : _skip,
              child: const Text('Skip for now'),
            ),
          ],
        ),
      ),
    );
  }
}
