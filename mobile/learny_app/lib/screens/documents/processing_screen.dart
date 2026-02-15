import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_tokens.dart';
import '../../state/app_state_scope.dart';
import '../../widgets/animations/fade_in_slide.dart';
import '../../widgets/games/pressable_scale.dart';

class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({super.key});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  bool _redirected = false;

  static String _localizedStageLabel(
    L10n l,
    String? pipelineStage,
    bool hasFirstPlayableSignal,
  ) {
    if (hasFirstPlayableSignal &&
        pipelineStage != 'ready' &&
        pipelineStage != 'game_generation_failed') {
      return l.stageFirstGameReady;
    }
    return switch (pipelineStage) {
      'quick_scan_queued' => l.stageQuickScanQueue,
      'quick_scan_processing' => l.stageQuickScanProcessing,
      'awaiting_validation' => l.stageAwaitingValidation,
      'uploading' => l.processingStepUploading,
      'queued' => l.stageQueued,
      'ocr' => l.stageOcr,
      'concept_extraction_queued' => l.stageConceptQueue,
      'concept_extraction' => l.stageConceptExtraction,
      'learning_pack_queued' => l.stagePackQueue,
      'learning_pack_generation' => l.stagePackGeneration,
      'game_generation_queued' => l.stageGameQueue,
      'game_generation' => l.stageGameGeneration,
      'ready' => l.stageReady,
      'quick_scan_failed' => l.stageQuickScanFailed,
      'ocr_failed' => l.stageOcrFailed,
      'concept_extraction_failed' => l.stageConceptFailed,
      'learning_pack_failed' => l.stagePackFailed,
      'game_generation_failed' => l.stageGameFailed,
      'processing' => l.stageProcessing,
      'processed' => l.stageProcessed,
      _ => l.stageProcessing,
    };
  }

  static String _localizedStatus(
    L10n l,
    String? pipelineStage,
    bool hasFirstPlayableSignal,
    int progressPercent,
  ) {
    String message;
    if (hasFirstPlayableSignal &&
        pipelineStage != 'ready' &&
        pipelineStage != 'game_generation_failed') {
      message = l.statusFirstGameReady;
    } else {
      message = switch (pipelineStage) {
        'quick_scan_queued' => l.statusQuickScanQueued,
        'quick_scan_processing' => l.statusQuickScanProcessing,
        'awaiting_validation' => l.statusAwaitingValidation,
        'uploading' => l.statusUploadingDocument,
        'queued' => l.statusQueued,
        'ocr' => l.statusOcr,
        'concept_extraction_queued' => l.statusConceptQueueing,
        'concept_extraction' => l.statusConceptExtraction,
        'learning_pack_queued' => l.statusPackQueueing,
        'learning_pack_generation' => l.statusPackGeneration,
        'game_generation_queued' => l.statusGameQueueing,
        'game_generation' => l.statusGameGeneration,
        'ready' => l.statusReady,
        'quick_scan_failed' => l.statusQuickScanFailed,
        'ocr_failed' => l.statusOcrFailed,
        'concept_extraction_failed' => l.statusConceptExtractionFailed,
        'learning_pack_failed' => l.statusPackGenerationFailed,
        'game_generation_failed' => l.statusGameGenerationFailed,
        'processing' => l.statusProcessing,
        'processed' => l.statusGenerating,
        _ => l.statusProcessing,
      };
    }
    if (progressPercent > 0 && pipelineStage != 'uploading') {
      return l.statusWithProgress(progressPercent, message);
    }
    return message;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = AppStateScope.of(context);
    if (_redirected) return;

    if (state.hasReadyGeneratedGame) {
      final readyGameType = state.currentPackGameType;
      if (readyGameType != null) {
        _redirected = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          state.startGameType(readyGameType);
          Navigator.pushReplacementNamed(
            context,
            state.routeForGameType(readyGameType),
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final tokens = context.tokens;
    final l = L10n.of(context);
    final hasError = state.generationError != null;
    final isAwaitingScanValidation = state.awaitingScanValidation;
    final status = _localizedStatus(
      l,
      state.pipelineStage,
      state.hasFirstPlayableSignal,
      state.processingProgressPercent,
    );
    final transferProgress = state.uploadProgressPercent < 0
        ? 0
        : state.uploadProgressPercent > 100
        ? 100
        : state.uploadProgressPercent;
    final processingProgress = state.processingProgressPercent < 0
        ? 0
        : state.processingProgressPercent > 100
        ? 100
        : state.processingProgressPercent;
    final processingStageLabel = _localizedStageLabel(
      l,
      state.pipelineStage,
      state.hasFirstPlayableSignal,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(gradient: tokens.gradientWelcome),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
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
                        L10n.of(context).processingTitle,
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
              if (isAwaitingScanValidation) ...[
                FadeInSlide(
                  delay: const Duration(milliseconds: 100),
                  child: _ScanValidationState(
                    topicSuggestion: state.scanSuggestedTopic,
                    languageSuggestion: state.scanSuggestedLanguage,
                    confidence: state.scanSuggestionConfidence,
                    alternatives: state.scanSuggestionAlternatives,
                    model: state.scanSuggestionModel,
                  ),
                ),
              ] else if (hasError) ...[
                FadeInSlide(
                  delay: const Duration(milliseconds: 100),
                  child: _ErrorState(error: state.generationError!),
                ),
              ] else ...[
                FadeInSlide(
                  delay: const Duration(milliseconds: 100),
                  child: _ProcessingState(
                    status: status,
                    transferProgressPercent: transferProgress,
                    processingProgressPercent: processingProgress,
                    processingStageLabel: processingStageLabel,
                  ),
                ),
              ],

              const Spacer(),

              // Action buttons
              if (hasError) ...[
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
                          L10n.of(context).processingGoBack,
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProcessingState extends StatefulWidget {
  const _ProcessingState({
    required this.status,
    required this.transferProgressPercent,
    required this.processingProgressPercent,
    required this.processingStageLabel,
  });

  final String status;
  final int transferProgressPercent;
  final int processingProgressPercent;
  final String processingStageLabel;

  @override
  State<_ProcessingState> createState() => _ProcessingStateState();
}

class _ProcessingStateState extends State<_ProcessingState> {
  int _funFactIndex = 0;

  static List<(String, String, String)> _localizedFunFacts(L10n l) => [
    ('🧠', l.funFactBrainPowerTitle, l.funFactBrainPower),
    ('🐙', l.funFactOctopusTitle, l.funFactOctopus),
    ('🎒', l.funFactSchoolTitle, l.funFactSchool),
    ('🦋', l.funFactMemoryTitle, l.funFactMemory),
    ('🎮', l.funFactGameTitle, l.funFactGame),
    ('🌍', l.funFactLanguageTitle, l.funFactLanguage),
    ('🚀', l.funFactSpaceTitle, l.funFactSpace),
    ('🎵', l.funFactMusicTitle, l.funFactMusic),
    ('🦁', l.funFactAnimalTitle, l.funFactAnimal),
    ('✏️', l.funFactPencilTitle, l.funFactPencil),
    ('🌈', l.funFactColorTitle, l.funFactColor),
    ('🐘', l.funFactElephantTitle, l.funFactElephant),
    ('⚡', l.funFactQuickTitle, l.funFactQuick),
    ('🌙', l.funFactDreamTitle, l.funFactDream),
    ('🎯', l.funFactPracticeTitle, l.funFactPractice),
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
          _funFactIndex = _funFactIndex + 1;
        });
        _startFactRotation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l = L10n.of(context);
    final facts = _localizedFunFacts(l);
    final fact = facts[_funFactIndex % facts.length];
    final transferProgress = widget.transferProgressPercent / 100.0;
    final processingProgress = widget.processingProgressPercent / 100.0;

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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: LearnyColors.skyLight.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              widget.processingStageLabel,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: LearnyColors.skyPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          SizedBox(height: tokens.spaceSm),

          _ProgressRow(
            label: l.processingTransfer,
            percent: widget.transferProgressPercent,
            value: transferProgress,
          ),

          SizedBox(height: tokens.spaceSm),

          _ProgressRow(
            label: l.processingAI,
            percent: widget.processingProgressPercent,
            value: processingProgress,
          ),

          SizedBox(height: tokens.spaceSm),

          LinearProgressIndicator(
            value: processingProgress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(999),
          ),

          SizedBox(height: tokens.spaceSm),

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
          _ProcessingSteps(
            pipelineStage: AppStateScope.of(context).pipelineStage,
          ),

          SizedBox(height: tokens.spaceLg),

          // Fun fact card
          _FunFactCard(emoji: fact.$1, title: fact.$2, fact: fact.$3),
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.label,
    required this.percent,
    required this.value,
  });

  final String label;
  final int percent;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: LearnyColors.neutralMedium,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '$percent%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: LearnyColors.neutralMedium,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value,
          minHeight: 6,
          borderRadius: BorderRadius.circular(999),
        ),
      ],
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
  const _ProcessingSteps({required this.pipelineStage});

  final String? pipelineStage;

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    final steps = [
      (l.processingStepUploading, LucideIcons.upload),
      (l.processingStepProcessing, LucideIcons.fileSearch),
      (l.processingStepGenerating, LucideIcons.sparkles),
      (l.processingStepCreatingGames, LucideIcons.gamepad2),
    ];

    int currentStep = 0;
    switch (pipelineStage) {
      case 'quick_scan_queued':
      case 'quick_scan_processing':
        currentStep = 1;
        break;
      case 'awaiting_validation':
        currentStep = 2;
        break;
      case 'ocr':
      case 'concept_extraction_queued':
      case 'concept_extraction':
      case 'processing':
      case 'queued':
        currentStep = 1;
        break;
      case 'learning_pack_queued':
      case 'learning_pack_generation':
      case 'processed':
        currentStep = 2;
        break;
      case 'game_generation_queued':
      case 'game_generation':
      case 'ready':
        currentStep = 3;
        break;
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

class _ScanValidationState extends StatefulWidget {
  const _ScanValidationState({
    required this.topicSuggestion,
    required this.languageSuggestion,
    required this.confidence,
    required this.alternatives,
    required this.model,
  });

  final String? topicSuggestion;
  final String? languageSuggestion;
  final double confidence;
  final List<String> alternatives;
  final String? model;

  @override
  State<_ScanValidationState> createState() => _ScanValidationStateState();
}

class _ScanValidationStateState extends State<_ScanValidationState> {
  late final TextEditingController _topicController;
  late final TextEditingController _languageController;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _topicController = TextEditingController(
      text: widget.topicSuggestion ?? '',
    );
    _languageController = TextEditingController(
      text: widget.languageSuggestion ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant _ScanValidationState oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.topicSuggestion != widget.topicSuggestion &&
        _topicController.text.trim().isEmpty) {
      _topicController.text = widget.topicSuggestion ?? '';
    }
    if (oldWidget.languageSuggestion != widget.languageSuggestion &&
        _languageController.text.trim().isEmpty) {
      _languageController.text = widget.languageSuggestion ?? '';
    }
  }

  @override
  void dispose() {
    _topicController.dispose();
    _languageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final state = AppStateScope.of(context);
    final l = L10n.of(context);
    final confidencePercent = (widget.confidence * 100).round();
    final alternativesText = widget.alternatives.isEmpty
        ? l.processingNoAlternatives
        : widget.alternatives.join(', ');

    return Container(
      padding: EdgeInsets.all(tokens.spaceLg + 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: tokens.radiusXl,
        boxShadow: tokens.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l.processingValidateScanTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: LearnyColors.neutralDark,
            ),
          ),
          SizedBox(height: tokens.spaceSm),
          Text(
            l.processingValidateScanSubtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: LearnyColors.neutralMedium),
          ),
          SizedBox(height: tokens.spaceSm),
          Text(
            l.processingConfidenceLabel(
              confidencePercent,
              widget.model == null ? '' : ' • ${widget.model}',
            ),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: LearnyColors.skyPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: tokens.spaceMd),
          TextField(
            controller: _topicController,
            decoration: InputDecoration(labelText: l.processingTopicLabel),
          ),
          SizedBox(height: tokens.spaceSm),
          TextField(
            controller: _languageController,
            decoration: InputDecoration(labelText: l.processingLanguageLabel),
          ),
          SizedBox(height: tokens.spaceSm),
          Text(
            l.processingAlternativesLabel(alternativesText),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: LearnyColors.neutralMedium),
          ),
          SizedBox(height: tokens.spaceMd),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _submitting
                      ? null
                      : () async {
                          final topic = _topicController.text.trim();
                          final language = _languageController.text.trim();
                          if (topic.isEmpty || language.isEmpty) {
                            if (!context.mounted) {
                              return;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  l.processingTopicLanguageRequired,
                                ),
                              ),
                            );
                            return;
                          }
                          setState(() => _submitting = true);
                          await state.confirmCurrentDocumentScan(
                            topic: topic,
                            language: language,
                          );
                          if (!mounted) {
                            return;
                          }
                          setState(() => _submitting = false);
                        },
                  child: Text(
                    _submitting
                        ? l.processingStarting
                        : l.processingConfirmGenerate,
                  ),
                ),
              ),
              SizedBox(width: tokens.spaceSm),
              OutlinedButton(
                onPressed: _submitting
                    ? null
                    : () async {
                        setState(() => _submitting = true);
                        await state.rescanCurrentDocument();
                        if (!mounted) {
                          return;
                        }
                        setState(() => _submitting = false);
                      },
                child: Text(l.processingRescan),
              ),
            ],
          ),
        ],
      ),
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
            L10n.of(context).processingErrorTitle,
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
                    L10n.of(context).processingErrorHint,
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
