import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../routes/app_routes.dart';
import '../../state/app_state_scope.dart';
import '../../theme/app_assets.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_tokens.dart';
import '../../widgets/animations/fade_in_slide.dart';
import '../../widgets/animations/logo_animation.dart';
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
          // Background decorative circles
          _BackgroundDecorations(),
          
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: tokens.spaceLg),
              child: Column(
                children: [
                  const Spacer(flex: 1),
                  
                  // Hero Logo Section with Animation
                  FadeInSlide(
                    duration: const Duration(milliseconds: 800),
                    child: Column(
                      children: [
                        // Animated Logo
                        LogoAnimation(
                          size: 140,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: WiggleAnimation(
                              child: Image.asset(
                                AppImages.foxMascot,
                                width: 80,
                                height: 80,
                              ),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: tokens.spaceXl),
                        
                        // App name with gradient text
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [LearnyColors.coral, LearnyColors.peach],
                          ).createShader(bounds),
                          child: Text(
                            'Learny',
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                        ),
                        
                        SizedBox(height: tokens.spaceSm),
                        
                        // Tagline
                        Text(
                          'Your AI Study Companion',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: LearnyColors.neutralMedium,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 1),

                  // Features preview with icons
                  FadeInSlide(
                    delay: const Duration(milliseconds: 300),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _FeatureChip(
                          icon: LucideIcons.scanLine,
                          label: 'Scan',
                          delay: 400,
                        ),
                        _FeatureChip(
                          icon: LucideIcons.brain,
                          label: 'Learn',
                          delay: 500,
                        ),
                        _FeatureChip(
                          icon: LucideIcons.trophy,
                          label: 'Master',
                          delay: 600,
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 1),

                  // Actions Section
                  FadeInSlide(
                    delay: const Duration(milliseconds: 500),
                    child: Column(
                      children: [
                        // Primary: Scan Homework (Guest Flow)
                        PressableScale(
                          onTap: _startScanFirst,
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(tokens.spaceMd),
                            decoration: BoxDecoration(
                              gradient: LearnyGradients.cta,
                              borderRadius: tokens.radiusXl,
                              boxShadow: [
                                BoxShadow(
                                  color: LearnyColors.coral.withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(LucideIcons.scanLine, color: Colors.white, size: 24),
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
                                        'Try it now — no account needed!',
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.9),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(LucideIcons.arrowRight, color: Colors.white, size: 20),
                                ),
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
                            padding: EdgeInsets.symmetric(vertical: tokens.spaceMd + 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: tokens.radiusFull,
                              border: Border.all(color: LearnyColors.tealPrimary, width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                  color: LearnyColors.tealPrimary.withValues(alpha: 0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  LucideIcons.smile,
                                  color: LearnyColors.tealPrimary,
                                  size: 22,
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  "I'm a Student",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 17,
                                    color: LearnyColors.tealPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: tokens.spaceMd),

                        // Tertiary: Parent Flow
                        PressableScale(
                          onTap: () => _chooseRole('parent'),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: tokens.spaceMd),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.7),
                              borderRadius: tokens.radiusFull,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  LucideIcons.users,
                                  color: LearnyColors.neutralMedium,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "I'm a Parent / Guardian",
                                  style: TextStyle(
                                    color: LearnyColors.neutralMedium,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: tokens.spaceXl),

                  if (kDebugMode)
                    FadeInSlide(
                      delay: const Duration(milliseconds: 700),
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
                  
                  SizedBox(height: tokens.spaceMd),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Background decorative circles for visual interest
class _BackgroundDecorations extends StatelessWidget {
  const _BackgroundDecorations();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top right decorative circle
        Positioned(
          right: -30,
          top: 80,
          child: _DecorativeCircle(
            size: 120,
            color: LearnyColors.peach.withValues(alpha: 0.5),
            delay: 0,
          ),
        ),
        // Bottom left decorative circle
        Positioned(
          left: -40,
          bottom: 120,
          child: _DecorativeCircle(
            size: 100,
            color: LearnyColors.tealLight.withValues(alpha: 0.3),
            delay: 200,
          ),
        ),
        // Bottom right decorative circle
        Positioned(
          right: 20,
          bottom: 60,
          child: _DecorativeCircle(
            size: 60,
            color: LearnyColors.purpleLight.withValues(alpha: 0.3),
            delay: 400,
          ),
        ),
      ],
    );
  }
}

class _DecorativeCircle extends StatefulWidget {
  const _DecorativeCircle({
    required this.size,
    required this.color,
    required this.delay,
  });

  final double size;
  final Color color;
  final int delay;

  @override
  State<_DecorativeCircle> createState() => _DecorativeCircleState();
}

class _DecorativeCircleState extends State<_DecorativeCircle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: child,
        );
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color,
        ),
      ),
    );
  }
}

/// Feature chip showing app capabilities
class _FeatureChip extends StatelessWidget {
  const _FeatureChip({
    required this.icon,
    required this.label,
    required this.delay,
  });

  final IconData icon;
  final String label;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return FadeInSlide(
      delay: Duration(milliseconds: delay),
      duration: const Duration(milliseconds: 500),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: LearnyColors.coral,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: LearnyColors.neutralMedium,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
