import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/document_item.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state_scope.dart';

class PacksScreen extends StatelessWidget {
  const PacksScreen({super.key});

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

  String _topicLabelForDocument(BuildContext context, String subject, String? language) {
    final normalizedSubject = subject.trim().isEmpty ? 'General' : subject.trim();

    if (normalizedSubject == 'Language' && language != null && language.trim().isNotEmpty) {
      return _localizedSubject(context, language.trim());
    }

    return _localizedSubject(context, normalizedSubject);
  }

  String _localizedSubject(BuildContext context, String subject) {
    final locale = Localizations.localeOf(context);
    final code = locale.languageCode;

    switch (code) {
      case 'fr':
        return switch (subject) {
          'Math' => 'Maths',
          'Science' => 'Sciences',
          'History' => 'Histoire',
          'Geography' => 'Géographie',
          'Language' => 'Langue',
          'General' => 'Général',
          _ => subject,
        };
      case 'nl':
        return switch (subject) {
          'Math' => 'Wiskunde',
          'Science' => 'Wetenschappen',
          'History' => 'Geschiedenis',
          'Geography' => 'Aardrijkskunde',
          'Language' => 'Taal',
          'General' => 'Algemeen',
          _ => subject,
        };
      default:
        return subject;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final l = L10n.of(context);
    final packs = state.packs;
    final documents = List.of(state.documents)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final Map<String, List<DocumentItem>> docsByTopic = {};
    for (final doc in documents) {
      final label = _topicLabelForDocument(context, doc.subject, doc.language);
      docsByTopic.putIfAbsent(label, () => []).add(doc);
    }

    final topicEntries = docsByTopic.entries.toList()
      ..sort((a, b) {
        final aDoc = a.value.isNotEmpty ? a.value.first : null;
        final bDoc = b.value.isNotEmpty ? b.value.first : null;
        if (aDoc == null || bDoc == null) return 0;
        return bDoc.createdAt.compareTo(aDoc.createdAt);
      });

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          l.packsTitle,
          style: Theme.of(context)
              .textTheme
              .headlineLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          l.packsSubtitle,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: LearnyColors.slateMedium),
        ),
        const SizedBox(height: 16),
        if (topicEntries.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l.packsLibraryByTopicTitle,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.library),
                child: Text(l.packsViewLibrary),
              ),
            ],
          ),
          Text(
            l.packsLibraryByTopicSubtitle,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: LearnyColors.slateMedium),
          ),
          const SizedBox(height: 12),
          ...topicEntries.map((entry) {
            final topic = entry.key;
            final docs = entry.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topic,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                ...docs.map(
                  (doc) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: LearnyColors.sky,
                        child: Icon(
                          Icons.insert_drive_file_rounded,
                          color: LearnyColors.teal,
                        ),
                      ),
                      title: Text(doc.title),
                      subtitle: Text(
                        _localizedDocStatus(context, doc.statusLabel),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.refresh_rounded,
                          color: LearnyColors.teal,
                        ),
                        onPressed: () => state.regenerateDocument(doc.id),
                        tooltip: l.libraryRegenerateTooltip,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
              ],
            );
          }),
          const SizedBox(height: 16),
        ],
        ...packs.map(
          (pack) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: pack.color.withValues(alpha: 0.2),
                child: Icon(pack.icon, color: pack.color),
              ),
              title: Text(pack.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.packsItemsMinutes(pack.itemCount, pack.minutes)),
                  if (pack.conceptsTotal > 0) ...[
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pack.progress,
                        minHeight: 6,
                        backgroundColor: LearnyColors.neutralSoft,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          pack.progress >= 0.8
                              ? LearnyColors.mintPrimary
                              : pack.progress >= 0.5
                                  ? LearnyColors.skyPrimary
                                  : LearnyColors.sunshine,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l.packsMasteryProgress(
                        (pack.progress * 100).round(),
                        pack.conceptsMastered,
                        pack.conceptsTotal,
                      ),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: LearnyColors.slateMedium,
                          ),
                    ),
                  ],
                ],
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                state.selectPack(pack.id);
                Navigator.pushNamed(context, AppRoutes.packDetail);
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.packSession),
          child: Text(l.packsStartSession),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.library),
          child: Text(l.packsViewLibrary),
        ),
      ],
    );
  }
}
