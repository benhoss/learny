import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../../routes/app_routes.dart';
import '../../state/app_state_scope.dart';
import '../../theme/app_assets.dart';
import '../../theme/app_theme.dart';
import '../shared/gradient_scaffold.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _redirected = false;
  bool _skipping = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = AppStateScope.of(context);
    if (_redirected || !state.onboardingHydrated) {
      return;
    }

    final target = state.onboardingResumeRoute;
    if (target != AppRoutes.welcome) {
      _redirected = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, target);
      });
    }
  }

  Future<void> _chooseRole(String role) async {
    final state = AppStateScope.of(context);
    await state.selectOnboardingRole(role);
    if (!mounted) return;
    final target = role == 'parent'
        ? AppRoutes.parentOnboarding
        : AppRoutes.howItWorks;
    Navigator.pushReplacementNamed(context, target);
  }

  Future<void> _debugSkip() async {
    setState(() => _skipping = true);
    try {
      final state = AppStateScope.of(context);
      final ok = await state.debugSkipOnboardingAutoLogin();
      if (!mounted) return;
      if (ok) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Auto login failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _skipping = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    if (!state.onboardingHydrated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return GradientScaffold(
      gradient: LearnyGradients.hero,
      child: Stack(
        children: [
          Positioned(
            right: -40,
            bottom: -80,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.16,
                child: Image.asset(AppImages.renderOnboarding, width: 260),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Welcome to Learny',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Choose your role to start onboarding.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: LearnyColors.slateMedium,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _chooseRole('child'),
                    child: const Text("I'm a learner"),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _chooseRole('parent'),
                    child: const Text("I'm a parent/guardian"),
                  ),
                ),
                if (kDebugMode) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: _skipping ? null : _debugSkip,
                      child: Text(
                        _skipping
                            ? 'Signing in test user...'
                            : 'Skip onboarding (debug: auto login test user)',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        throw StateError('This is test exception');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Verify Sentry Setup'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
