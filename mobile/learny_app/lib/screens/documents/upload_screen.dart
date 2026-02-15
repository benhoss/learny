import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../routes/app_routes.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_tokens.dart';
import '../../state/app_state_scope.dart';
import '../../widgets/animations/fade_in_slide.dart';
import 'game_type_selector.dart';
import '../shared/gradient_scaffold.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final ImagePicker _picker = ImagePicker();
  final _titleController = TextEditingController();
  final _subjectController = TextEditingController();
  final _topicController = TextEditingController();
  final _languageController = TextEditingController();
  final _gradeController = TextEditingController();
  final _collectionsController = TextEditingController();
  final _tagsController = TextEditingController();
  final _goalController = TextEditingController();
  final _contextController = TextEditingController();
  final List<String> _selectedGameTypes = [
    'flashcards',
    'quiz',
    'matching',
    'true_false',
    'fill_blank',
    'ordering',
    'multiple_select',
    'short_answer',
  ];
  bool _isSuggestingMetadata = false;
  String? _suggestionFeedback;
  bool _showAdvancedOptions = false;

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    _topicController.dispose();
    _languageController.dispose();
    _gradeController.dispose();
    _collectionsController.dispose();
    _tagsController.dispose();
    _goalController.dispose();
    _contextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final l = L10n.of(context);
    final tokens = context.tokens;
    final canPop = Navigator.of(context).canPop();
    
    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await state.resetOnboarding();
        if (context.mounted) {
          if (canPop) {
            Navigator.of(context).pop();
          } else {
            Navigator.pushReplacementNamed(context, AppRoutes.welcome);
          }
        }
      },
      child: GradientScaffold(
        gradient: LearnyGradients.trust,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () async {
              await state.resetOnboarding();
              if (!context.mounted) return;
              if (canPop) {
                Navigator.of(context).pop();
              } else {
                Navigator.pushReplacementNamed(context, AppRoutes.welcome);
              }
            },
          ),
          title: Text(l.appTitle),
        ),
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.all(tokens.spaceLg),
            children: [
              // Header Section
              FadeInSlide(
                delay: const Duration(milliseconds: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.uploadTitle,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: LearnyColors.neutralDark,
                      ),
                    ),
                    SizedBox(height: tokens.spaceXs),
                    Text(
                      l.uploadSubtitle,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: LearnyColors.neutralMedium,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: tokens.spaceLg),
              
              // Camera Capture - Primary Option
              FadeInSlide(
                delay: const Duration(milliseconds: 200),
                child: _UploadOptionCard(
                  title: l.cameraCaptureTakePhoto,
                  subtitle: 'Best for physical homework & books',
                  icon: LucideIcons.camera,
                  color: LearnyColors.coral,
                  isPrimary: true,
                  onTap: () => _capturePhoto(state),
                ),
              ),
              
              SizedBox(height: tokens.spaceMd),
              
              // Gallery and Files - Secondary Options
              FadeInSlide(
                delay: const Duration(milliseconds: 300),
                child: Row(
                  children: [
                    Expanded(
                      child: _UploadOptionCard(
                        title: 'Gallery',
                        subtitle: 'Pick photos',
                        icon: LucideIcons.image,
                        color: LearnyColors.skyPrimary,
                        isCompact: true,
                        onTap: () => _chooseFromCameraRoll(state),
                      ),
                    ),
                    SizedBox(width: tokens.spaceMd),
                    Expanded(
                      child: _UploadOptionCard(
                        title: 'Files',
                        subtitle: 'PDFs or docs',
                        icon: LucideIcons.fileText,
                        color: LearnyColors.mintPrimary,
                        isCompact: true,
                        onTap: () => _pickAndUploadDocument(state),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: tokens.spaceXl),
              
              // Divider with optional text
              FadeInSlide(
                delay: const Duration(milliseconds: 400),
                child: Row(
                  children: [
                    Expanded(child: Divider(color: LearnyColors.neutralSoft)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: tokens.spaceMd),
                      child: Text(
                        'Optional',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: LearnyColors.neutralLight,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: LearnyColors.neutralSoft)),
                  ],
                ),
              ),
              
              SizedBox(height: tokens.spaceLg),
              
              // Additional Details Section
              FadeInSlide(
                delay: const Duration(milliseconds: 500),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Additional Details',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: LearnyColors.neutralDark,
                      ),
                    ),
                    SizedBox(height: tokens.spaceXs),
                    Text(
                      'Add details now to help us generate a better quiz, or skip for now.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: LearnyColors.neutralMedium,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: tokens.spaceMd),
              
              if (!_showAdvancedOptions)
                FadeInSlide(
                  delay: const Duration(milliseconds: 600),
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() => _showAdvancedOptions = true),
                    icon: const Icon(LucideIcons.plus),
                    label: const Text('Add details now'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(double.infinity, 52),
                      side: BorderSide(color: LearnyColors.skyPrimary, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: tokens.radiusLg,
                      ),
                    ),
                  ),
                ),
              
              if (_showAdvancedOptions) ...[
                SizedBox(height: tokens.spaceMd),
                
                FadeInSlide(
                  delay: const Duration(milliseconds: 700),
                  child: _buildTextField(
                    controller: _titleController,
                    label: l.uploadTitleLabel,
                    hint: l.uploadTitleHint,
                    icon: LucideIcons.fileText,
                  ),
                ),
                
                SizedBox(height: tokens.spaceMd),
                
                FadeInSlide(
                  delay: const Duration(milliseconds: 750),
                  child: _buildTextField(
                    controller: _subjectController,
                    label: l.uploadSubjectLabel,
                    hint: l.uploadSubjectHint,
                    icon: LucideIcons.bookOpen,
                  ),
                ),
                
                SizedBox(height: tokens.spaceMd),
                
                FadeInSlide(
                  delay: const Duration(milliseconds: 800),
                  child: _buildTextField(
                    controller: _topicController,
                    label: l.processingTopicLabel,
                    hint: l.uploadTopicHint,
                    icon: LucideIcons.tag,
                  ),
                ),
                
                SizedBox(height: tokens.spaceMd),
                
                FadeInSlide(
                  delay: const Duration(milliseconds: 850),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _languageController,
                          label: l.uploadLanguageLabel,
                          hint: l.uploadLanguageHint,
                          icon: LucideIcons.globe,
                        ),
                      ),
                      SizedBox(width: tokens.spaceMd),
                      Expanded(
                        child: _buildTextField(
                          controller: _gradeController,
                          label: l.uploadGradeLabel,
                          hint: l.uploadGradeHint,
                          icon: LucideIcons.graduationCap,
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: tokens.spaceMd),
                
                FadeInSlide(
                  delay: const Duration(milliseconds: 900),
                  child: _buildTextField(
                    controller: _goalController,
                    label: l.uploadGoalLabel,
                    hint: l.uploadGoalHint,
                    icon: LucideIcons.target,
                  ),
                ),
                
                SizedBox(height: tokens.spaceMd),
                
                FadeInSlide(
                  delay: const Duration(milliseconds: 950),
                  child: _buildTextField(
                    controller: _contextController,
                    label: l.uploadContextLabel,
                    hint: l.uploadContextHint,
                    icon: LucideIcons.textCursorInput,
                    maxLines: 3,
                  ),
                ),
                
                SizedBox(height: tokens.spaceLg),
                
                // AI Suggest Button
                FadeInSlide(
                  delay: const Duration(milliseconds: 1000),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LearnyGradients.cta,
                      borderRadius: tokens.radiusLg,
                      boxShadow: [
                        BoxShadow(
                          color: LearnyColors.skyPrimary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isSuggestingMetadata
                            ? null
                            : () => _suggestMetadata(state),
                        borderRadius: tokens.radiusLg,
                        child: Padding(
                          padding: EdgeInsets.all(tokens.spaceMd),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_isSuggestingMetadata)
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              else
                                Icon(
                                  LucideIcons.sparkles,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              SizedBox(width: tokens.spaceSm),
                              Text(
                                _isSuggestingMetadata
                                    ? l.uploadAnalyzing
                                    : l.uploadSuggestMetadata,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                if (_suggestionFeedback != null) ...[
                  SizedBox(height: tokens.spaceSm),
                  FadeInSlide(
                    delay: const Duration(milliseconds: 1050),
                    child: Text(
                      _suggestionFeedback!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: LearnyColors.mintPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                
                SizedBox(height: tokens.spaceLg),
                
                // Game Type Selector
                FadeInSlide(
                  delay: const Duration(milliseconds: 1100),
                  child: GameTypeSelector(
                    selectedTypes: _selectedGameTypes,
                    onSelectionChanged: (types) {
                      setState(() {
                        _selectedGameTypes
                          ..clear()
                          ..addAll(types);
                      });
                    },
                  ),
                ),
              ],
              
              SizedBox(height: tokens.spaceXl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: LearnyColors.neutralLight, size: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: LearnyColors.neutralSoft),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: LearnyColors.neutralSoft),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: LearnyColors.skyPrimary, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }


  Future<void> _capturePhoto(AppState state) async {
    if (kIsWeb) {
      return _pickImageFromWeb(state);
    }
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (file == null) {
      return;
    }
    final bytes = await file.readAsBytes();
    if (!mounted) {
      return;
    }
    state.setPendingImage(
      bytes: bytes,
      filename: file.name.isEmpty ? 'capture.jpg' : file.name,
    );
    _startProcessing(state);
  }

  Future<void> _chooseFromCameraRoll(AppState state) async {
    if (kIsWeb) {
      return _pickImageFromWeb(state);
    }
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (file == null) {
      return;
    }
    final bytes = await file.readAsBytes();
    if (!mounted) {
      return;
    }
    state.setPendingImage(
      bytes: bytes,
      filename: file.name.isEmpty ? 'capture.jpg' : file.name,
    );
    _startProcessing(state);
  }

  Future<void> _pickImageFromWeb(AppState state) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) {
      return;
    }
    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) {
      return;
    }
    if (!mounted) {
      return;
    }
    state.setPendingImage(
      bytes: bytes,
      filename: file.name.isEmpty ? 'capture.jpg' : file.name,
    );
    _startProcessing(state);
  }

  void _startProcessing(AppState state) {
    // Set context and game types from form fields before processing
    state.setPendingContext(
      title: _titleController.text.trim(),
      subject: _subjectController.text.trim(),
      topic: _topicController.text.trim(),
      language: _languageController.text.trim(),
      gradeLevel: _gradeController.text.trim(),
      collections: _collectionsController.text
          .split(',')
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toSet()
          .toList(),
      tags: _tagsController.text
          .split(',')
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toSet()
          .toList(),
      learningGoal: _goalController.text.trim(),
      contextText: _contextController.text.trim(),
    );
    state.setPendingGameTypes(
      List<String>.from(_selectedGameTypes),
    );
    state.generateQuizFromPendingImage();
    Navigator.pushNamed(context, AppRoutes.processing);
  }

  Future<void> _pickAndUploadDocument(AppState state) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) {
      return;
    }
    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) {
      return;
    }

    state.setPendingContext(
      title: _titleController.text.trim(),
      subject: _subjectController.text.trim(),
      topic: _topicController.text.trim(),
      language: _languageController.text.trim(),
      gradeLevel: _gradeController.text.trim(),
      collections: _collectionsController.text
          .split(',')
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toSet()
          .toList(),
      tags: _tagsController.text
          .split(',')
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toSet()
          .toList(),
      learningGoal: _goalController.text.trim(),
      contextText: _contextController.text.trim(),
    );
    state.setPendingGameTypes(
      List<String>.from(_selectedGameTypes),
    );
    state.generateQuizFromBytes(bytes: bytes, filename: file.name);
    if (!mounted) {
      return;
    }
    Navigator.pushNamed(context, AppRoutes.processing);
  }

  Future<void> _suggestMetadata(AppState state) async {
    setState(() {
      _isSuggestingMetadata = true;
      _suggestionFeedback = null;
    });

    final suggestion = await state.suggestDocumentMetadata(
      filename: 'uploaded-file',
      contextText: _contextController.text.trim(),
      languageHint: _languageController.text.trim(),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSuggestingMetadata = false;
      if (suggestion == null) {
        _suggestionFeedback = L10n.of(context).uploadSuggestionUnavailable;
        return;
      }

      final subject = suggestion['subject']?.toString() ?? '';
      final language = suggestion['language']?.toString() ?? '';
      final learningGoal = suggestion['learning_goal']?.toString() ?? '';
      final title = suggestion['title']?.toString() ?? '';
      final confidence = (suggestion['confidence'] as num?)?.toDouble() ?? 0.0;

      if (_titleController.text.trim().isEmpty && title.isNotEmpty) {
        _titleController.text = title;
      }
      if (_subjectController.text.trim().isEmpty && subject.isNotEmpty) {
        _subjectController.text = subject;
      }
      if (_topicController.text.trim().isEmpty && subject.isNotEmpty) {
        _topicController.text = subject;
      }
      if (_languageController.text.trim().isEmpty && language.isNotEmpty) {
        _languageController.text = language;
      }
      if (_goalController.text.trim().isEmpty && learningGoal.isNotEmpty) {
        _goalController.text = learningGoal;
      }

      _suggestionFeedback = L10n.of(context).uploadSuggestionFeedback(
        (confidence * 100).round(),
      );
    });
  }
}

class _UploadOptionCard extends StatelessWidget {
  const _UploadOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isPrimary = false,
    this.isCompact = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isPrimary;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: tokens.radiusXl,
        child: Container(
          padding: EdgeInsets.all(isCompact ? tokens.spaceMd : tokens.spaceLg),
          decoration: BoxDecoration(
            color: isPrimary ? color.withValues(alpha: 0.08) : Colors.white,
            borderRadius: tokens.radiusXl,
            border: Border.all(
              color: isPrimary 
                  ? color.withValues(alpha: 0.4) 
                  : LearnyColors.neutralSoft,
              width: isPrimary ? 2 : 1,
            ),
            boxShadow: isPrimary ? [
              BoxShadow(
                color: color.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ] : null,
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isCompact ? 10 : 14),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: tokens.radiusMd,
                ),
                child: Icon(
                  icon,
                  size: isCompact ? 24 : 32,
                  color: color,
                ),
              ),
              SizedBox(width: isCompact ? tokens.spaceSm : tokens.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: LearnyColors.neutralDark,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: LearnyColors.neutralMedium,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                color: color,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
