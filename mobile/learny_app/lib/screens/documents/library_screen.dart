import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state_scope.dart';
import '../shared/placeholder_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  bool _loadedOnce = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadedOnce) {
      return;
    }
    _loadedOnce = true;
    AppStateScope.of(context).refreshDocumentsFromBackend();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    return PlaceholderScreen(
      title: 'Document Library',
      subtitle: 'Your uploaded worksheets and PDFs.',
      gradient: LearnyGradients.trust,
      body: Column(
        children: [
          if (state.isSyncingDocuments)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: LinearProgressIndicator(),
            ),
          if (state.documentSyncError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                state.documentSyncError!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: LearnyColors.coral),
              ),
            ),
          ...state.documents.map(
            (doc) => _LibraryItem(
              title: doc.title,
              subtitle: '${doc.subject} • ${doc.statusLabel}',
              onRegenerate: () => state.regenerateDocument(doc.id),
            ),
          ),
        ],
      ),
      primaryAction: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.cameraCapture),
        child: const Text('Add New Document'),
      ),
      secondaryAction: OutlinedButton(
        onPressed: () => state.refreshDocumentsFromBackend(),
        child: const Text('Sync Library'),
      ),
    );
  }
}

class _LibraryItem extends StatelessWidget {
  const _LibraryItem({
    required this.title,
    required this.subtitle,
    required this.onRegenerate,
  });

  final String title;
  final String subtitle;
  final VoidCallback onRegenerate;

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
        trailing: IconButton(
          icon: const Icon(Icons.refresh_rounded, color: LearnyColors.teal),
          onPressed: onRegenerate,
          tooltip: 'Re-generate quiz',
        ),
      ),
    );
  }
}
