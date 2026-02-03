import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../routes/app_routes.dart';
import '../../state/app_state_scope.dart';
import '../../theme/app_theme.dart';
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
      Navigator.pushNamed(context, AppRoutes.review);
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
    Navigator.pushNamed(context, AppRoutes.review);
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
      Navigator.pushNamed(context, AppRoutes.review);
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
    Navigator.pushNamed(context, AppRoutes.review);
  }

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: 'Snap Homework',
      subtitle: 'Frame the worksheet and snap a photo.',
      gradient: LearnyGradients.trust,
      body: Container(
        height: 220,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: LearnyColors.slateLight.withValues(alpha: 0.3)),
        ),
        child: const Center(
          child: Icon(Icons.camera_alt_rounded, size: 60, color: LearnyColors.slateLight),
        ),
      ),
      primaryAction: ElevatedButton(
        onPressed: () => _pickImage(ImageSource.camera),
        child: const Text('Take Photo'),
      ),
      secondaryAction: Column(
        children: [
          OutlinedButton(
            onPressed: () => _pickImage(ImageSource.gallery),
            child: const Text('Choose Single Photo'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _pickMultipleFromGallery,
            child: const Text('Choose Multiple Pages'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.upload),
            child: const Text('Upload PDF Instead'),
          ),
        ],
      ),
    );
  }
}
