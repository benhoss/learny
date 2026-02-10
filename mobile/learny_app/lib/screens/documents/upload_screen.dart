import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../routes/app_routes.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state_scope.dart';
import 'game_type_selector.dart';
import '../shared/placeholder_screen.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _subjectController = TextEditingController();
  final _languageController = TextEditingController();
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

  @override
  void dispose() {
    _subjectController.dispose();
    _languageController.dispose();
    _goalController.dispose();
    _contextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final hasContext =
        _subjectController.text.trim().isNotEmpty ||
        _goalController.text.trim().isNotEmpty;
    return PlaceholderScreen(
      title: L10n.of(context).uploadTitle,
      subtitle: L10n.of(context).uploadSubtitle,
      gradient: LearnyGradients.trust,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: LearnyColors.slateLight.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.cloud_upload_rounded,
                  size: 60,
                  color: LearnyColors.coral,
                ),
                const SizedBox(height: 8),
                Text(L10n.of(context).uploadDragOrBrowse),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _subjectController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: L10n.of(context).uploadSubjectLabel,
              hintText: L10n.of(context).uploadSubjectHint,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _languageController,
            decoration: InputDecoration(
              labelText: L10n.of(context).uploadLanguageLabel,
              hintText: L10n.of(context).uploadLanguageHint,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _goalController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: L10n.of(context).uploadGoalLabel,
              hintText: L10n.of(context).uploadGoalHint,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _contextController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: L10n.of(context).uploadContextLabel,
              hintText: L10n.of(context).uploadContextHint,
            ),
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
            ? () async {
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
                  subject: _subjectController.text.trim(),
                  language: _languageController.text.trim(),
                  learningGoal: _goalController.text.trim(),
                  contextText: _contextController.text.trim(),
                );
                state.setPendingGameTypes(
                  List<String>.from(_selectedGameTypes),
                );
                state.generateQuizFromBytes(bytes: bytes, filename: file.name);
                if (!context.mounted) {
                  return;
                }
                Navigator.pushNamed(context, AppRoutes.processing);
              }
            : null,
        child: Text(L10n.of(context).uploadChooseFile),
      ),
    );
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

      _suggestionFeedback = L10n.of(context).uploadSuggestionFeedback(
        (confidence * 100).round(),
      );
    });
  }
}
