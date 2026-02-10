import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
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

  String _localizedDocStatus(BuildContext context, String status) {
    final l = L10n.of(context);
    return switch (status) {
      'quick_scan_queued' => l.docStatusQuickScanQueued,
      'quick_scan_processing' => l.docStatusQuickScanProcessing,
      'quick_scan_failed' => l.docStatusQuickScanFailed,
      'awaiting_validation' => l.docStatusAwaitingValidation,
      'queued' => l.docStatusQueued,
      'processing' => l.docStatusProcessing,
      'processed' => l.docStatusProcessed,
      'ready' => l.docStatusReady,
      'failed' => l.docStatusFailed,
      _ => l.docStatusUnknown,
    };
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    return PlaceholderScreen(
      title: L10n.of(context).libraryTitle,
      subtitle: L10n.of(context).librarySubtitle,
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
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: LearnyColors.coral),
              ),
            ),
          ...state.documents.map(
            (doc) => _LibraryItem(
              title: doc.title,
              subtitle:
                  '${doc.subject} • ${_localizedDocStatus(context, doc.statusLabel)}',
              onRegenerate: () => state.regenerateDocument(doc.id),
            ),
          ),
        ],
      ),
      primaryAction: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.cameraCapture),
        child: Text(L10n.of(context).libraryAddNew),
      ),
      secondaryAction: OutlinedButton(
        onPressed: () => state.refreshDocumentsFromBackend(),
        child: Text(L10n.of(context).librarySyncButton),
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
          child: Icon(
            Icons.insert_drive_file_rounded,
            color: LearnyColors.teal,
          ),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: IconButton(
          icon: const Icon(Icons.refresh_rounded, color: LearnyColors.teal),
          onPressed: onRegenerate,
          tooltip: L10n.of(context).libraryRegenerateTooltip,
        ),
      ),
    );
  }
}
