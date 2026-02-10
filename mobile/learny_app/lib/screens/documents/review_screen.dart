import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state.dart';
import '../../state/app_state_scope.dart';
import 'game_type_selector.dart';
import '../shared/placeholder_screen.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final _subjectController = TextEditingController();
  final _languageController = TextEditingController();
  final _goalController = TextEditingController();
  final _contextController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
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
  bool _didAutoSuggest = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _languageController.dispose();
    _goalController.dispose();
    _contextController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoSuggestIfNeeded());
  }

  void _autoSuggestIfNeeded() {
    if (!mounted || _didAutoSuggest || _isSuggestingMetadata) {
      return;
    }
    final state = AppStateScope.of(context);
    if (state.pendingImages.isEmpty) {
      return;
    }
    _didAutoSuggest = true;
    _suggestMetadata(state);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final hasContext =
        _subjectController.text.trim().isNotEmpty ||
        _goalController.text.trim().isNotEmpty;
    return PlaceholderScreen(
      title: L10n.of(context).reviewScreenTitle,
      subtitle: L10n.of(context).reviewScreenSubtitle,
      gradient: LearnyGradients.trust,
      body: Column(
        children: [
          state.pendingImages.isEmpty
              ? Container(
                  height: 240,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.photo,
                      size: 80,
                      color: LearnyColors.slateLight,
                    ),
                  ),
                )
              : SizedBox(
                  height: 240,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.pendingImages.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.memory(
                          state.pendingImages[index],
                          width: 200,
                          height: 240,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _addAnotherPage(),
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: Text(L10n.of(context).reviewAddPage),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _isSuggestingMetadata
                ? null
                : () => _suggestMetadata(state),
            icon: _isSuggestingMetadata
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome_rounded),
            label: Text(
              _isSuggestingMetadata
                  ? L10n.of(context).uploadAnalyzing
                  : L10n.of(context).uploadSuggestMetadata,
            ),
          ),
          if (_suggestionFeedback != null) ...[
            const SizedBox(height: 8),
            Text(
              _suggestionFeedback!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: LearnyColors.slateMedium),
            ),
          ],
          _ReviewContextFields(
            subjectController: _subjectController,
            languageController: _languageController,
            goalController: _goalController,
            contextController: _contextController,
            onContextChanged: () => setState(() {}),
          ),
          const SizedBox(height: 12),
          GameTypeSelector(
            selectedTypes: _selectedGameTypes,
            onSelectionChanged: (types) {
              setState(() {
                _selectedGameTypes
                  ..clear()
                  ..addAll(types);
              });
            },
          ),
        ],
      ),
      primaryAction: ElevatedButton(
        onPressed: hasContext
            ? () {
                state.setPendingContext(
                  subject: _subjectController.text.trim(),
                  language: _languageController.text.trim(),
                  learningGoal: _goalController.text.trim(),
                  contextText: _contextController.text.trim(),
                );
                state.setPendingGameTypes(
                  List<String>.from(_selectedGameTypes),
                );
                state.generateQuizFromPendingImage();
                Navigator.pushNamed(context, AppRoutes.processing);
              }
            : null,
        child: Text(L10n.of(context).reviewLooksGood),
      ),
      secondaryAction: OutlinedButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.cameraCapture),
        child: Text(L10n.of(context).reviewRetake),
      ),
    );
  }

  Future<void> _addAnotherPage() async {
    final state = AppStateScope.of(context);
    if (kIsWeb) {
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
      state.addPendingImage(
        bytes: bytes,
        filename: file.name.isEmpty ? 'capture.jpg' : file.name,
      );
      return;
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
    state.addPendingImage(
      bytes: bytes,
      filename: file.name.isEmpty ? 'capture.jpg' : file.name,
    );
  }

  Future<void> _suggestMetadata(AppState state) async {
    setState(() {
      _isSuggestingMetadata = true;
      _suggestionFeedback = null;
    });

    final suggestion = await state.suggestDocumentMetadata(
      filename: state.pendingImageNames.isNotEmpty
          ? state.pendingImageNames.first
          : 'capture.jpg',
      contextText: _contextController.text.trim(),
      languageHint: _languageController.text.trim(),
      imageBytes: state.pendingImages.isNotEmpty
          ? state.pendingImages.first
          : null,
      imageFilename: state.pendingImageNames.isNotEmpty
          ? state.pendingImageNames.first
          : null,
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
      final confidence = (suggestion['confidence'] as num?)?.toDouble() ?? 0.0;

      if (_subjectController.text.trim().isEmpty && subject.isNotEmpty) {
        _subjectController.text = subject;
      }
      if (_languageController.text.trim().isEmpty && language.isNotEmpty) {
        _languageController.text = language;
      }
      if (_goalController.text.trim().isEmpty && learningGoal.isNotEmpty) {
        _goalController.text = learningGoal;
      }

      _suggestionFeedback = L10n.of(context).reviewSuggestionFeedback(
        (confidence * 100).round(),
      );
    });
  }
}

class _ReviewContextFields extends StatelessWidget {
  const _ReviewContextFields({
    required this.subjectController,
    required this.languageController,
    required this.goalController,
    required this.contextController,
    required this.onContextChanged,
  });

  final TextEditingController subjectController;
  final TextEditingController languageController;
  final TextEditingController goalController;
  final TextEditingController contextController;
  final VoidCallback onContextChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        TextField(
          controller: subjectController,
          onChanged: (_) => onContextChanged(),
          decoration: InputDecoration(
            labelText: L10n.of(context).uploadSubjectLabel,
            hintText: L10n.of(context).uploadSubjectHint,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: languageController,
          decoration: InputDecoration(
            labelText: L10n.of(context).uploadLanguageLabel,
            hintText: L10n.of(context).uploadLanguageHint,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: goalController,
          onChanged: (_) => onContextChanged(),
          decoration: InputDecoration(
            labelText: L10n.of(context).uploadGoalLabel,
            hintText: L10n.of(context).uploadGoalHint,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: contextController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: L10n.of(context).uploadContextLabel,
            hintText: L10n.of(context).uploadContextHint,
          ),
        ),
      ],
    );
  }
}
