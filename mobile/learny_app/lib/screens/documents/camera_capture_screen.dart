import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../routes/app_routes.dart';
import '../../state/app_state_scope.dart';
import '../../theme/app_theme.dart';
import '../../widgets/source_card.dart';
import '../shared/placeholder_screen.dart';

class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({super.key});

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
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
      if (!mounted) {
        return;
      }
      final state = AppStateScope.of(context);
      state.setPendingImage(
        bytes: bytes,
        filename: file.name.isEmpty ? 'capture.jpg' : file.name,
      );
      _startProcessing();
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
    final state = AppStateScope.of(context);
    state.setPendingImage(bytes: bytes, filename: file.name.isEmpty ? 'capture.jpg' : file.name);
    _startProcessing();
  }

  Future<void> _pickMultipleFromGallery() async {
    if (kIsWeb) {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
        withData: true,
        allowMultiple: true,
      );
      if (result == null || result.files.isEmpty) {
        return;
      }
      final state = AppStateScope.of(context);
      state.clearPendingImages();
      for (final file in result.files) {
        final bytes = file.bytes;
        if (bytes == null) {
          continue;
        }
        state.addPendingImage(
          bytes: bytes,
          filename: file.name.isEmpty ? 'capture.jpg' : file.name,
        );
      }
      if (!mounted) {
        return;
      }
      _startProcessing();
      return;
    }

    final files = await _picker.pickMultiImage(
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (files.isEmpty) {
      return;
    }
    final state = AppStateScope.of(context);
    state.clearPendingImages();
    for (final file in files) {
      final bytes = await file.readAsBytes();
      state.addPendingImage(
        bytes: bytes,
        filename: file.name.isEmpty ? 'capture.jpg' : file.name,
      );
    }
    if (!mounted) {
      return;
    }
    _startProcessing();
  }

  void _startProcessing() {
    // Start processing immediately - no review step
    final state = AppStateScope.of(context);
    state.generateQuizFromPendingImage();
    Navigator.pushNamed(context, AppRoutes.processing);
  }

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    
    return PlaceholderScreen(
      title: l.cameraCaptureTitle,
      subtitle: l.cameraCaptureSubtitle,
      gradient: LearnyGradients.trust,
      body: Column(
        children: [
          SourceCard(
            title: l.cameraCaptureTakePhoto,
            subtitle: 'Point at your page and snap!',
            icon: Icons.camera_alt_rounded,
            color: LearnyColors.coral,
            isPrimary: true,
            onTap: () => _pickImage(ImageSource.camera),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SourceCard(
                  title: 'Single Photo',
                  subtitle: 'From gallery',
                  icon: Icons.photo_outlined,
                  color: LearnyColors.skyPrimary,
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SourceCard(
                  title: 'Multiple',
                  subtitle: 'Choose pages',
                  icon: Icons.auto_awesome_motion_rounded,
                  color: LearnyColors.lavender,
                  onTap: _pickMultipleFromGallery,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.upload),
            icon: const Icon(Icons.description_outlined),
            label: Text(l.cameraCaptureUploadPdfInstead),
          ),
        ],
      ),
    );
  }
}
