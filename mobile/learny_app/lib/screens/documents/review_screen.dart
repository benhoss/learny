import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final _titleController = TextEditingController();
  final _subjectController = TextEditingController();
  final _topicController = TextEditingController();
  final _languageController = TextEditingController();
  final _gradeController = TextEditingController();
  final _collectionsController = TextEditingController();
  final _tagsController = TextEditingController();
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
  void initState() {
    super.initState();
    _loadSavedGrade();
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoSuggestIfNeeded());
  }

  Future<void> _loadSavedGrade() async {
    final prefs = await SharedPreferences.getInstance();
    final savedGrade = prefs.getString('default_grade');
    if (savedGrade != null && savedGrade.isNotEmpty && mounted) {
      _gradeController.text = savedGrade;
      setState(() {}); // Trigger rebuild for button state
    }
  }

  Future<void> _saveGrade(String grade) async {
    if (grade.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('default_grade', grade.trim());
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
    // Grade is now optional  
    final hasContext =
        (_subjectController.text.trim().isNotEmpty ||
            _topicController.text.trim().isNotEmpty ||
            _goalController.text.trim().isNotEmpty) &&
        _languageController.text.trim().isNotEmpty;
    final hasImages = state.pendingImages.isNotEmpty;
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
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 12),
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
          const SizedBox(height: 8),
          _ReviewContextFields(
            titleController: _titleController,
            subjectController: _subjectController,
            topicController: _topicController,
            languageController: _languageController,
            gradeController: _gradeController,
            collectionsController: _collectionsController,
            tagsController: _tagsController,
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
        onPressed: (hasContext && hasImages)
            ? () {
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
                _saveGrade(_gradeController.text); // Save for next time
                state.generateQuizFromPendingImage();
                Navigator.pushNamed(context, AppRoutes.processing);
              }
            : null,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
        ),
        child: Text(L10n.of(context).reviewLooksGood),
      ),
      secondaryAction: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _addAnotherPage(),
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: Text(L10n.of(context).reviewAddPage),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: () => _showSourceSheet(replaceExisting: true),
              child: Text(L10n.of(context).reviewRetake),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addAnotherPage() async {
    await _showSourceSheet(replaceExisting: false);
  }

  Future<void> _showSourceSheet({required bool replaceExisting}) async {
    if (!mounted) {
      return;
    }
    final l = L10n.of(context);
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded),
                title: Text(l.cameraCaptureTakePhoto),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickImageForReview(
                    source: ImageSource.camera,
                    replaceExisting: replaceExisting,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(l.cameraCaptureChooseSinglePhoto),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickImageForReview(
                    source: ImageSource.gallery,
                    replaceExisting: replaceExisting,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: Text(l.uploadChooseFile),
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.pushNamed(context, AppRoutes.upload);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImageForReview({
    required ImageSource source,
    required bool replaceExisting,
  }) async {
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
      if (replaceExisting) {
        state.setPendingImage(
          bytes: bytes,
          filename: file.name.isEmpty ? 'capture.jpg' : file.name,
        );
      } else {
        state.addPendingImage(
          bytes: bytes,
          filename: file.name.isEmpty ? 'capture.jpg' : file.name,
        );
      }
      _didAutoSuggest = false;
      _autoSuggestIfNeeded();
      return;
    }

    final file = await _picker.pickImage(
      source: source,
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
    if (replaceExisting) {
      state.setPendingImage(
        bytes: bytes,
        filename: file.name.isEmpty ? 'capture.jpg' : file.name,
      );
    } else {
      state.addPendingImage(
        bytes: bytes,
        filename: file.name.isEmpty ? 'capture.jpg' : file.name,
      );
    }
    _didAutoSuggest = false;
    _autoSuggestIfNeeded();
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

      _suggestionFeedback = L10n.of(context).reviewSuggestionFeedback(
        (confidence * 100).round(),
      );
    });
  }
}

class _ReviewContextFields extends StatefulWidget {
  const _ReviewContextFields({
    required this.titleController,
    required this.subjectController,
    required this.topicController,
    required this.languageController,
    required this.gradeController,
    required this.collectionsController,
    required this.tagsController,
    required this.goalController,
    required this.contextController,
    required this.onContextChanged,
  });

  final TextEditingController titleController;
  final TextEditingController subjectController;
  final TextEditingController topicController;
  final TextEditingController languageController;
  final TextEditingController gradeController;
  final TextEditingController collectionsController;
  final TextEditingController tagsController;
  final TextEditingController goalController;
  final TextEditingController contextController;
  final VoidCallback onContextChanged;

  @override
  State<_ReviewContextFields> createState() => _ReviewContextFieldsState();
}

class _ReviewContextFieldsState extends State<_ReviewContextFields> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        TextField(
          controller: widget.titleController,
          decoration: InputDecoration(
            labelText: L10n.of(context).uploadTitleLabel,
            hintText: L10n.of(context).uploadTitleHint,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: widget.subjectController,
          onChanged: (_) => widget.onContextChanged(),
          decoration: InputDecoration(
            labelText: L10n.of(context).uploadSubjectLabel,
            hintText: L10n.of(context).uploadSubjectHint,
          ),
        ),
        if (!_showAll)
          Center(
            child: TextButton.icon(
              onPressed: () => setState(() => _showAll = true),
              icon: const Icon(Icons.expand_more_rounded),
              label: const Text('Show more details'),
            ),
          ),
        if (_showAll) ...[
          const SizedBox(height: 8),
          TextField(
            controller: widget.topicController,
            onChanged: (_) => widget.onContextChanged(),
            decoration: InputDecoration(
              labelText: L10n.of(context).processingTopicLabel,
              hintText: L10n.of(context).uploadTopicHint,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: widget.languageController,
            decoration: InputDecoration(
              labelText: L10n.of(context).uploadLanguageLabel,
              hintText: L10n.of(context).uploadLanguageHint,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: widget.gradeController,
            decoration: InputDecoration(
              labelText: L10n.of(context).uploadGradeLabel,
              hintText: L10n.of(context).uploadGradeHint,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: widget.collectionsController,
            decoration: InputDecoration(
              labelText: L10n.of(context).uploadCollectionsLabel,
              hintText: L10n.of(context).uploadCollectionsHint,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: widget.tagsController,
            decoration: InputDecoration(
              labelText: L10n.of(context).uploadTagsLabel,
              hintText: L10n.of(context).uploadTagsHint,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: widget.goalController,
            onChanged: (_) => widget.onContextChanged(),
            decoration: InputDecoration(
              labelText: L10n.of(context).uploadGoalLabel,
              hintText: L10n.of(context).uploadGoalHint,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: widget.contextController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: L10n.of(context).uploadContextLabel,
              hintText: L10n.of(context).uploadContextHint,
            ),
          ),
          Center(
            child: TextButton.icon(
              onPressed: () => setState(() => _showAll = false),
              icon: const Icon(Icons.expand_less_rounded),
              label: const Text('Show less'),
            ),
          ),
        ],
      ],
    );
  }
}
