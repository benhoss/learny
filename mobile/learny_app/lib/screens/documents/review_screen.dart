import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
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
    final hasContext = _subjectController.text.trim().isNotEmpty ||
        _goalController.text.trim().isNotEmpty;
    return PlaceholderScreen(
      title: 'Review Capture',
      subtitle: 'Crop, rotate, or retake if needed.',
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
                    child: Icon(Icons.photo, size: 80, color: LearnyColors.slateLight),
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
            label: const Text('Add Another Page'),
          ),
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
          state.setPendingGameTypes(List<String>.from(_selectedGameTypes));
          state.generateQuizFromPendingImage();
          Navigator.pushNamed(context, AppRoutes.processing);
        }
            : null,
        child: const Text('Looks Good'),
      ),
      secondaryAction: OutlinedButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.cameraCapture),
        child: const Text('Retake'),
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
    state.addPendingImage(bytes: bytes, filename: file.name.isEmpty ? 'capture.jpg' : file.name);
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
          decoration: const InputDecoration(
            labelText: 'Subject (optional)',
            hintText: 'e.g. French verbs',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: languageController,
          decoration: const InputDecoration(
            labelText: 'Language (optional)',
            hintText: 'e.g. French',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: goalController,
          onChanged: (_) => onContextChanged(),
          decoration: const InputDecoration(
            labelText: 'Learning goal (optional)',
            hintText: 'e.g. Present tense conjugation',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: contextController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Extra context (optional)',
            hintText: 'Short notes to guide quiz generation',
          ),
        ),
      ],
    );
  }
}
