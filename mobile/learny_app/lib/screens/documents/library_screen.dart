import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state_scope.dart';
import '../shared/placeholder_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    return PlaceholderScreen(
      title: 'Document Library',
      subtitle: 'Your uploaded worksheets and PDFs.',
      gradient: LearnyGradients.trust,
      body: Column(
        children: state.documents
            .map(
              (doc) => _LibraryItem(
                title: doc.title,
                subtitle: '${doc.subject} • ${doc.statusLabel}',
              ),
            )
            .toList(),
      ),
      primaryAction: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.cameraCapture),
        child: const Text('Add New Document'),
      ),
    );
  }
}

class _LibraryItem extends StatelessWidget {
  const _LibraryItem({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: LearnyColors.sky,
          child: Icon(Icons.insert_drive_file_rounded, color: LearnyColors.teal),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}
