import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_tokens.dart';
import '../../state/app_state_scope.dart';
import '../../widgets/animations/fade_in_slide.dart';
import '../../widgets/games/pressable_scale.dart';

class ProcessingScreen extends StatelessWidget {
  const ProcessingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final tokens = context.tokens;
    final readyGameType = state.currentPackGameType;
    final isReady = state.hasReadyGeneratedGame;
    final hasError = state.generationError != null;
    final status = state.generationStatus;
    final ctaLabel = _startLabelForType(readyGameType);

    return Container(
      decoration: BoxDecoration(gradient: tokens.gradientWelcome),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(tokens.spaceLg),
          child: Column(
            children: [
              // Header
              FadeInSlide(
                child: Row(
                  children: [
                    PressableScale(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: tokens.radiusMd,
                          boxShadow: tokens.cardShadow,
                        ),
                        child: const Icon(
                          LucideIcons.arrowLeft,
                          color: LearnyColors.neutralDark,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        isReady ? 'Ready to Learn!' : 'Creating Your Quiz',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: LearnyColors.neutralDark,
                            ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Main content
              if (isReady) ...[
                FadeInSlide(
                  delay: const Duration(milliseconds: 100),
                  child: _SuccessState(),
                ),
              ] else if (hasError) ...[
                FadeInSlide(
                  delay: const Duration(milliseconds: 100),
                  child: _ErrorState(error: state.generationError!),
                ),
              ] else ...[
                FadeInSlide(
                  delay: const Duration(milliseconds: 100),
                  child: _ProcessingState(status: status),
                ),
              ],

              const Spacer(),

              // Action buttons
              if (isReady) ...[
                FadeInSlide(
                  delay: const Duration(milliseconds: 200),
                  child: PressableScale(
                    onTap: readyGameType == null
                        ? null
                        : () {
                            state.startGameType(readyGameType);
                            Navigator.pushNamed(
                              context,
                              state.routeForGameType(readyGameType),
                            );
                          },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: tokens.spaceMd),
                      decoration: BoxDecoration(
                        gradient: tokens.gradientAccent,
                        borderRadius: tokens.radiusFull,
                        boxShadow: tokens.buttonShadow,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            LucideIcons.play,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            ctaLabel,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ] else if (hasError) ...[
                FadeInSlide(
                  delay: const Duration(milliseconds: 200),
                  child: PressableScale(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: tokens.spaceMd),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: tokens.radiusFull,
                        border: Border.all(
                          color: LearnyColors.skyPrimary,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Go Back',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: LearnyColors.skyPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],

              SizedBox(height: tokens.spaceLg),
            ],
          ),
        ),
      ),
    );
  }

  String _startLabelForType(String? type) {
    switch (type) {
      case 'flashcards':
        return 'Start Flashcards';
      case 'matching':
        return 'Start Matching';
      case 'true_false':
        return 'Start True/False';
      case 'multiple_select':
        return 'Start Multi-Select';
      case 'fill_blank':
        return 'Start Fill-in-the-Blank';
      case 'short_answer':
        return 'Start Short Answer';
      case 'ordering':
        return 'Start Ordering Game';
      case 'quiz':
        return 'Start the Quiz';
      default:
        return 'Start Learning';
    }
  }
}

class _ProcessingState extends StatefulWidget {
  const _ProcessingState({required this.status});

  final String status;

  @override
  State<_ProcessingState> createState() => _ProcessingStateState();
}

class _ProcessingStateState extends State<_ProcessingState> {
  int _funFactIndex = 0;

  static const _funFacts = [
    (
      '🧠',
      'Brain Power',
      'Your brain uses about 20% of your body\'s energy, even though it\'s only 2% of your weight!',
    ),
    (
      '🐙',
      'Octopus Smarts',
      'Octopuses have 9 brains! One central brain and a mini-brain in each of their 8 arms.',
    ),
    (
      '🎒',
      'School History',
      'The world\'s oldest school is in Morocco - it\'s been teaching students since 859 AD!',
    ),
    (
      '🦋',
      'Memory Trick',
      'You remember things better when you learn them right before sleep. Sweet dreams = smart dreams!',
    ),
    (
      '🎮',
      'Game Learning',
      'Playing educational games can improve memory by up to 30%. You\'re doing great!',
    ),
    (
      '🌍',
      'Language Fun',
      'Kids who learn multiple subjects together remember 40% more than studying one at a time.',
    ),
    (
      '🚀',
      'Space Fact',
      'Astronauts study for years! NASA training takes about 2 years of intense learning.',
    ),
    (
      '🎵',
      'Music & Math',
      'Learning music helps with math! Both use patterns and counting in similar ways.',
    ),
    (
      '🦁',
      'Animal Teachers',
      'Meerkats teach their babies how to eat scorpions by bringing them dead ones first!',
    ),
    (
      '✏️',
      'Pencil Power',
      'The average pencil can write about 45,000 words. That\'s a lot of homework!',
    ),
    (
      '🌈',
      'Color Memory',
      'You remember colorful things better! That\'s why highlighters help you study.',
    ),
    (
      '🐘',
      'Elephant Memory',
      'Elephants really do have great memories - they can remember friends for decades!',
    ),
    (
      '⚡',
      'Quick Learner',
      'Your brain can process an image in just 13 milliseconds. Faster than a blink!',
    ),
    (
      '🌙',
      'Dream Learning',
      'Your brain replays what you learned during the day while you dream!',
    ),
    (
      '🎯',
      'Practice Perfect',
      'It takes about 10,000 hours of practice to become an expert at something.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startFactRotation();
  }

  void _startFactRotation() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _funFactIndex = (_funFactIndex + 1) % _funFacts.length;
        });
        _startFactRotation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final fact = _funFacts[_funFactIndex];

    return Container(
      padding: EdgeInsets.all(tokens.spaceLg + 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: tokens.radiusXl,
        boxShadow: tokens.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated processing indicator
          _AnimatedProcessingIcon(),

          SizedBox(height: tokens.spaceLg),

          // Status text
          Text(
            widget.status,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: LearnyColors.neutralDark,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: tokens.spaceMd),

          // Pipeline steps
          _ProcessingSteps(currentStatus: widget.status),

          SizedBox(height: tokens.spaceLg),

          // Fun fact card
          _FunFactCard(emoji: fact.$1, title: fact.$2, fact: fact.$3),
        ],
      ),
    );
  }
}

class _FunFactCard extends StatefulWidget {
  const _FunFactCard({
    required this.emoji,
    required this.title,
    required this.fact,
  });

  final String emoji;
  final String title;
  final String fact;

  @override
  State<_FunFactCard> createState() => _FunFactCardState();
}

class _FunFactCardState extends State<_FunFactCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  String _currentEmoji = '';
  String _currentTitle = '';
  String _currentFact = '';

  @override
  void initState() {
    super.initState();
    _currentEmoji = widget.emoji;
    _currentTitle = widget.title;
    _currentFact = widget.fact;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void didUpdateWidget(_FunFactCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fact != widget.fact) {
      _controller.reverse().then((_) {
        setState(() {
          _currentEmoji = widget.emoji;
          _currentTitle = widget.title;
          _currentFact = widget.fact;
        });
        _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: EdgeInsets.all(tokens.spaceMd),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                LearnyColors.sunshineLight.withValues(alpha: 0.6),
                LearnyColors.mintLight.withValues(alpha: 0.4),
              ],
            ),
            borderRadius: tokens.radiusLg,
            border: Border.all(
              color: LearnyColors.sunshine.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_currentEmoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentTitle,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: LearnyColors.neutralDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currentFact,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: LearnyColors.neutralMedium,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedProcessingIcon extends StatefulWidget {
  @override
  State<_AnimatedProcessingIcon> createState() =>
      _AnimatedProcessingIconState();
}

class _AnimatedProcessingIconState extends State<_AnimatedProcessingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer rotating ring
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _controller.value * 2 * 3.14159,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: LearnyColors.skyLight, width: 4),
                  ),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: LearnyColors.skyPrimary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // Center icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [LearnyColors.skyLight, LearnyColors.mintLight],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.brain,
              color: LearnyColors.skyPrimary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProcessingSteps extends StatelessWidget {
  const _ProcessingSteps({required this.currentStatus});

  final String currentStatus;

  @override
  Widget build(BuildContext context) {
    final steps = [
      ('Uploading', LucideIcons.upload, 'Uploading'),
      ('Processing', LucideIcons.fileSearch, 'Processing'),
      ('Generating', LucideIcons.sparkles, 'Generating'),
      ('Creating games', LucideIcons.gamepad2, 'Creating'),
    ];

    int currentStep = 0;
    if (currentStatus.contains('Processing') ||
        currentStatus.contains('queue')) {
      currentStep = 1;
    } else if (currentStatus.contains('Generating') ||
        currentStatus.contains('learning')) {
      currentStep = 2;
    } else if (currentStatus.contains('Creating') ||
        currentStatus.contains('games')) {
      currentStep = 3;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          _StepDot(
            icon: steps[i].$2,
            isActive: i <= currentStep,
            isCurrent: i == currentStep,
          ),
          if (i < steps.length - 1)
            Container(
              width: 24,
              height: 2,
              color: i < currentStep
                  ? LearnyColors.mintPrimary
                  : LearnyColors.neutralSoft,
            ),
        ],
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.icon,
    required this.isActive,
    required this.isCurrent,
  });

  final IconData icon;
  final bool isActive;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isActive ? LearnyColors.mintLight : LearnyColors.neutralSoft,
        shape: BoxShape.circle,
        border: isCurrent
            ? Border.all(color: LearnyColors.mintPrimary, width: 2)
            : null,
      ),
      child: Icon(
        icon,
        size: 16,
        color: isActive ? LearnyColors.mintPrimary : LearnyColors.neutralLight,
      ),
    );
  }
}

class _SuccessState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      padding: EdgeInsets.all(tokens.spaceLg + 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: tokens.radiusXl,
        boxShadow: tokens.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Success icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [LearnyColors.mintLight, LearnyColors.success],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.check, color: Colors.white, size: 40),
          ),

          SizedBox(height: tokens.spaceLg),

          Text(
            'Your Quiz is Ready!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: LearnyColors.neutralDark,
            ),
          ),

          SizedBox(height: tokens.spaceSm),

          Text(
            'Jump in while the material is fresh.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: LearnyColors.neutralMedium),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: tokens.spaceMd),

          Container(
            padding: EdgeInsets.all(tokens.spaceMd),
            decoration: BoxDecoration(
              color: LearnyColors.mintLight.withValues(alpha: 0.5),
              borderRadius: tokens.radiusLg,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.sparkles,
                  color: LearnyColors.mintPrimary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Personalized games created from your document',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: LearnyColors.neutralMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      padding: EdgeInsets.all(tokens.spaceLg + 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: tokens.radiusXl,
        boxShadow: tokens.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Error icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: LearnyColors.coralLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.alertCircle,
              color: LearnyColors.coral,
              size: 40,
            ),
          ),

          SizedBox(height: tokens.spaceLg),

          Text(
            'Something went wrong',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: LearnyColors.neutralDark,
            ),
          ),

          SizedBox(height: tokens.spaceSm),

          Text(
            error,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: LearnyColors.neutralMedium),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: tokens.spaceMd),

          Container(
            padding: EdgeInsets.all(tokens.spaceMd),
            decoration: BoxDecoration(
              color: LearnyColors.coralLight.withValues(alpha: 0.3),
              borderRadius: tokens.radiusLg,
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.lightbulb,
                  color: LearnyColors.coral,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Try uploading a clearer image or a different document.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: LearnyColors.neutralMedium,
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
}
