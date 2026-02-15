import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../routes/app_routes.dart';
import '../../state/app_state_scope.dart';
import '../../theme/app_assets.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_tokens.dart';
import '../../widgets/animations/fade_in_slide.dart';
import '../../widgets/games/pressable_scale.dart';
import '../shared/gradient_scaffold.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _redirected = false;
  bool _skipping = false;
  bool _isInteracting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = AppStateScope.of(context);
    if (_redirected || _isInteracting || !state.onboardingHydrated) {
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
    setState(() => _isInteracting = true);
    final state = AppStateScope.of(context);
    await state.selectOnboardingRole(role);
    if (!mounted) return;
    final target = role == 'parent'
        ? AppRoutes.parentOnboarding
        : AppRoutes.howItWorks;
    Navigator.pushNamed(context, target).then((_) {
      if (mounted) setState(() => _isInteracting = false);
    });
  }

  Future<void> _startScanFirst() async {
    setState(() => _isInteracting = true);
    final state = AppStateScope.of(context);
    await state.startScanFirstOnboarding();
    if (!mounted) return;
    Navigator.pushNamed(context, AppRoutes.upload).then((_) {
      if (mounted) setState(() => _isInteracting = false);
    });
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
    final tokens = context.tokens;

    if (!state.onboardingHydrated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return GradientScaffold(
      gradient: LearnyGradients.hero,
      child: Stack(
        children: [
          // Background Illustration
          Positioned(
            right: -40,
            bottom: -80,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.16,
                child: Image.asset(AppImages.renderOnboarding, width: 300),
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(tokens.spaceLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 1),
                  
                  // Header Section
                  FadeInSlide(
                    duration: const Duration(milliseconds: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: tokens.cardShadow,
                          ),
                          child: const Icon(
                            LucideIcons.graduationCap, 
                            size: 32, 
                            color: LearnyColors.skyPrimary
                          ),
                        ),
                        SizedBox(height: tokens.spaceLg),
                        Text(
                          'Welcome to\nLearny',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: LearnyColors.neutralDark,
                            height: 1.1,
                          ),
                        ),
                        SizedBox(height: tokens.spaceMd),
                        Text(
                          'Your personal AI study companion.\nScan homework, generate quizzes, and master any subject.',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: LearnyColors.neutralMedium,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Actions Section
                  FadeInSlide(
                    delay: const Duration(milliseconds: 200),
                    child: Column(
                      children: [
                        // Primary: Scan Homework (Guest Flow)
                        PressableScale(
                          onTap: _startScanFirst,
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(tokens.spaceMd),
                            decoration: BoxDecoration(
                              gradient: tokens.gradientAccent,
                              borderRadius: tokens.radiusXl,
                              boxShadow: tokens.buttonShadow,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(LucideIcons.scanLine, color: Colors.white),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Scan Homework',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        'Try it now without an account',
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.9),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(LucideIcons.arrowRight, color: Colors.white),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: tokens.spaceMd),

                        // Secondary: Student Flow
                        PressableScale(
                          onTap: () => _chooseRole('child'),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: tokens.spaceMd),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: tokens.radiusFull,
                              border: Border.all(color: LearnyColors.skyPrimary, width: 2),
                            ),
                            child: const Center(
                              child: Text(
                                "I'm a Student",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: LearnyColors.skyPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: tokens.spaceMd),

                        // Tertiary: Parent Flow
                        TextButton(
                          onPressed: () => _chooseRole('parent'),
                          child: Text(
                            "I'm a Parent / Guardian",
                            style: TextStyle(
                              color: LearnyColors.neutralMedium,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (kDebugMode)
                    FadeInSlide(
                      delay: const Duration(milliseconds: 400),
                      child: Center(
                        child: TextButton(
                          onPressed: _skipping ? null : _debugSkip,
                          child: Text(
                            _skipping ? 'Signing in...' : 'Debug: Skip Onboarding',
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
