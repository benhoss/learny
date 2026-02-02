import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state_scope.dart';
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
    return PlaceholderScreen(
      title: 'Upload a File',
      subtitle: 'PDFs and images supported.',
      gradient: LearnyGradients.trust,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: LearnyColors.slateLight.withValues(alpha: 0.3)),
            ),
            child: const Column(
              children: [
                Icon(Icons.cloud_upload_rounded, size: 60, color: LearnyColors.coral),
                SizedBox(height: 8),
                Text('Drag & drop or browse'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const ListTile(
            leading: Icon(Icons.picture_as_pdf_rounded, color: LearnyColors.teal),
            title: Text('Math Worksheet.pdf'),
            subtitle: Text('2.1 MB'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _subjectController,
            decoration: const InputDecoration(
              labelText: 'Subject (optional)',
              hintText: 'e.g. French verbs',
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _languageController,
            decoration: const InputDecoration(
              labelText: 'Language (optional)',
              hintText: 'e.g. French',
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _goalController,
            decoration: const InputDecoration(
              labelText: 'Learning goal (optional)',
              hintText: 'e.g. Present tense conjugation',
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _contextController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Extra context (optional)',
              hintText: 'Short notes to guide quiz generation',
            ),
          ),
        ],
      ),
      primaryAction: ElevatedButton(
        onPressed: () async {
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
          state.generateQuizFromBytes(
            bytes: bytes,
            filename: file.name,
          );
          if (!context.mounted) {
            return;
          }
          Navigator.pushNamed(context, AppRoutes.processing);
        },
        child: const Text('Choose File'),
      ),
    );
  }
}
