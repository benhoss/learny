import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/document_item.dart';
import '../../models/learning_pack.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_tokens.dart';
import '../../state/app_state.dart';
import '../../state/app_state_scope.dart';
import '../shared/placeholder_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  bool _loadedOnce = false;
  String _query = '';
  late final TextEditingController _searchController;
  final Set<String> _selectedSubjects = {};
  final Set<String> _selectedTopics = {};
  final Set<String> _selectedGrades = {};
  final Set<String> _selectedLanguages = {};

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: _query);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadedOnce) {
      return;
    }
    _loadedOnce = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      AppStateScope.of(context).refreshDocumentsFromBackend();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
    final l = L10n.of(context);
    final List<DocumentItem> documents = List.of(state.documents)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final List<LearningPack> packs = List.of(state.packs);
    final hasFilters =
        _selectedSubjects.isNotEmpty ||
        _selectedTopics.isNotEmpty ||
        _selectedGrades.isNotEmpty ||
        _selectedLanguages.isNotEmpty;
    final hasQuery = _query.trim().isNotEmpty;
    final activeSearch = hasQuery || hasFilters;

    final subjectOptions = _uniqueValues(documents.map((d) => d.subject));
    final topicOptions = _uniqueValues(documents.map((d) => d.topic));
    final gradeOptions = _uniqueValues(documents.map((d) => d.gradeLevel ?? ''));
    final languageOptions = _uniqueValues(documents.map((d) => d.language ?? ''));

    final filteredDocuments = documents.where((doc) {
      if (_selectedSubjects.isNotEmpty && !_selectedSubjects.contains(doc.subject)) {
        return false;
      }
      if (_selectedTopics.isNotEmpty && !_selectedTopics.contains(doc.topic)) {
        return false;
      }
      if (_selectedGrades.isNotEmpty &&
          !_selectedGrades.contains(doc.gradeLevel ?? '')) {
        return false;
      }
      if (_selectedLanguages.isNotEmpty &&
          !_selectedLanguages.contains(doc.language ?? '')) {
        return false;
      }
      if (!hasQuery) {
        return true;
      }
      final haystack = [
        doc.title,
        doc.subject,
        doc.topic,
        doc.language ?? '',
        doc.gradeLevel ?? '',
        ...doc.collections,
        ...doc.tags,
      ].join(' ').toLowerCase();
      return haystack.contains(_query.toLowerCase());
    }).toList();

    final filteredPacks = packs.where((pack) {
      if (_selectedSubjects.isNotEmpty && !_selectedSubjects.contains(pack.subject)) {
        return false;
      }
      if (_selectedTopics.isNotEmpty &&
          (pack.topic == null || !_selectedTopics.contains(pack.topic))) {
        return false;
      }
      if (_selectedGrades.isNotEmpty &&
          (pack.gradeLevel == null ||
              !_selectedGrades.contains(pack.gradeLevel))) {
        return false;
      }
      if (_selectedLanguages.isNotEmpty &&
          (pack.language == null ||
              !_selectedLanguages.contains(pack.language))) {
        return false;
      }
      if (!hasQuery) {
        return true;
      }
      final haystack = [
        pack.title,
        pack.subject,
        pack.topic ?? '',
        pack.language ?? '',
        pack.gradeLevel ?? '',
        ...pack.collections,
      ].join(' ').toLowerCase();
      return haystack.contains(_query.toLowerCase());
    }).toList();

    final unclassifiedDocuments = documents.where((doc) {
      final subjectEmpty = doc.subject.trim().isEmpty || doc.subject == 'General';
      final topicEmpty = doc.topic.trim().isEmpty || doc.topic == 'General';
      return subjectEmpty || topicEmpty || (doc.gradeLevel ?? '').isEmpty;
    }).toList();

    return PlaceholderScreen(
      title: l.libraryTitle,
      subtitle: l.librarySubtitle,
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
          _LibrarySearchBar(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
            hintText: l.librarySearchHint,
          ),
          const SizedBox(height: 10),
          _LibraryFiltersRow(
            subjectCount: _selectedSubjects.length,
            topicCount: _selectedTopics.length,
            gradeCount: _selectedGrades.length,
            languageCount: _selectedLanguages.length,
            onSubjectTap: () => _openFilterSheet(
              context,
              title: l.libraryFilterSubject,
              options: subjectOptions,
              selected: _selectedSubjects,
            ),
            onTopicTap: () => _openFilterSheet(
              context,
              title: l.libraryFilterTopic,
              options: topicOptions,
              selected: _selectedTopics,
            ),
            onGradeTap: () => _openFilterSheet(
              context,
              title: l.libraryFilterGrade,
              options: gradeOptions,
              selected: _selectedGrades,
            ),
            onLanguageTap: () => _openFilterSheet(
              context,
              title: l.libraryFilterLanguage,
              options: languageOptions,
              selected: _selectedLanguages,
            ),
            onClear: hasFilters
                ? () => setState(() {
                      _selectedSubjects.clear();
                      _selectedTopics.clear();
                      _selectedGrades.clear();
                      _selectedLanguages.clear();
                    })
                : null,
            clearLabel: l.libraryClearFilters,
          ),
          const SizedBox(height: 12),
          if (activeSearch) ...[
            _SectionHeader(title: l.libraryDocumentsSection),
            if (filteredDocuments.isEmpty)
              Text(
                l.libraryNoDocumentsMatch,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: LearnyColors.slateMedium),
              ),
            ...filteredDocuments.map(
              (doc) => _LibraryItem(
                title: doc.title,
                subtitle:
                    '${doc.subject} • ${doc.topic} • ${_localizedDocStatus(context, doc.statusLabel)}',
                onRegenerate: () => state.regenerateDocument(doc.id),
              ),
            ),
            const SizedBox(height: 8),
            _SectionHeader(title: l.libraryPacksSection),
            if (filteredPacks.isEmpty)
              Text(
                l.libraryNoPacksMatch,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: LearnyColors.slateMedium),
              ),
            ...filteredPacks.map(
              (pack) => _PackItem(pack: pack),
            ),
          ] else ...[
            _SectionHeader(
              title: l.librarySmartCategoriesTitle,
              subtitle: l.librarySmartCategoriesSubtitle,
            ),
            ..._buildSmartCategories(context, documents, state),
            const SizedBox(height: 12),
            _SectionHeader(
              title: l.libraryCollectionsTitle,
              subtitle: l.libraryCollectionsSubtitle,
            ),
            ..._buildCollections(context, documents, state),
            const SizedBox(height: 12),
            _SectionHeader(
              title: l.libraryRecentUploadsTitle,
              subtitle: l.libraryRecentUploadsSubtitle,
            ),
            ...documents.take(5).map(
              (doc) => _LibraryItem(
                title: doc.title,
                subtitle:
                    '${doc.subject} • ${doc.topic} • ${_localizedDocStatus(context, doc.statusLabel)}',
                onRegenerate: () => state.regenerateDocument(doc.id),
              ),
            ),
            if (unclassifiedDocuments.isNotEmpty) ...[
              const SizedBox(height: 12),
              _SectionHeader(
                title: l.libraryUnclassifiedTitle,
                subtitle: l.libraryUnclassifiedSubtitle,
              ),
              ...unclassifiedDocuments.map(
                (doc) => _LibraryItem(
                  title: doc.title,
                  subtitle:
                      '${doc.subject} • ${_localizedDocStatus(context, doc.statusLabel)}',
                  onRegenerate: () => state.regenerateDocument(doc.id),
                ),
              ),
            ],
          ],
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

  List<Widget> _buildSmartCategories(
    BuildContext context,
    List<DocumentItem> documents,
    AppState state,
  ) {
    final Map<String, Map<String, List<DocumentItem>>> grouped = {};
    for (final doc in documents) {
      final subject = doc.subject.trim().isEmpty ? 'General' : doc.subject;
      final topic = doc.topic.trim().isEmpty ? 'General' : doc.topic;
      grouped.putIfAbsent(subject, () => {});
      grouped[subject]!.putIfAbsent(topic, () => []);
      grouped[subject]![topic]!.add(doc);
    }

    final subjectEntries = grouped.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return subjectEntries.map((subjectEntry) {
      final topicEntries = subjectEntry.value.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subjectEntry.key,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          ...topicEntries.map((topicEntry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topicEntry.key,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: LearnyColors.slateMedium),
                ),
                const SizedBox(height: 4),
                ...topicEntry.value.map(
                  (doc) => _LibraryItem(
                    title: doc.title,
                    subtitle:
                        '${doc.subject} • ${doc.topic} • ${_localizedDocStatus(context, doc.statusLabel)}',
                    onRegenerate: () => state.regenerateDocument(doc.id),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            );
          }),
        ],
      );
    }).toList();
  }

  List<Widget> _buildCollections(
    BuildContext context,
    List<DocumentItem> documents,
    AppState state,
  ) {
    final Map<String, List<DocumentItem>> grouped = {};
    for (final doc in documents) {
      for (final collection in doc.collections) {
        grouped.putIfAbsent(collection, () => []);
        grouped[collection]!.add(doc);
      }
    }

    if (grouped.isEmpty) {
      return [
        Text(
          L10n.of(context).libraryCollectionsEmpty,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: LearnyColors.slateMedium),
        ),
      ];
    }

    final entries = grouped.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return entries.map((entry) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.key,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          ...entry.value.map(
            (doc) => _LibraryItem(
              title: doc.title,
              subtitle:
                  '${doc.subject} • ${doc.topic} • ${_localizedDocStatus(context, doc.statusLabel)}',
              onRegenerate: () => state.regenerateDocument(doc.id),
            ),
          ),
          const SizedBox(height: 8),
        ],
      );
    }).toList();
  }

  List<String> _uniqueValues(Iterable<String> values) {
    return values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  Future<void> _openFilterSheet(
    BuildContext context, {
    required String title,
    required List<String> options,
    required Set<String> selected,
  }) async {
    if (options.isEmpty) {
      return;
    }
    final tokens = context.tokens;
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.all(tokens.spaceLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final isSelected = selected.contains(option);
                    return CheckboxListTile(
                      value: isSelected,
                      title: Text(option),
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (_) {
                        setState(() {
                          if (isSelected) {
                            selected.remove(option);
                          } else {
                            selected.add(option);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() => selected.clear());
                      },
                      child: Text(L10n.of(context).libraryFilterClear),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(L10n.of(context).libraryFilterDone),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: LearnyColors.slateMedium),
            ),
          ],
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

class _LibrarySearchBar extends StatelessWidget {
  const _LibrarySearchBar({
    required this.controller,
    required this.onChanged,
    required this.hintText,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search_rounded),
        hintText: hintText,
      ),
    );
  }
}

class _LibraryFiltersRow extends StatelessWidget {
  const _LibraryFiltersRow({
    required this.subjectCount,
    required this.topicCount,
    required this.gradeCount,
    required this.languageCount,
    required this.onSubjectTap,
    required this.onTopicTap,
    required this.onGradeTap,
    required this.onLanguageTap,
    required this.onClear,
    required this.clearLabel,
  });

  final int subjectCount;
  final int topicCount;
  final int gradeCount;
  final int languageCount;
  final VoidCallback onSubjectTap;
  final VoidCallback onTopicTap;
  final VoidCallback onGradeTap;
  final VoidCallback onLanguageTap;
  final VoidCallback? onClear;
  final String clearLabel;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _FilterChipButton(
          label: L10n.of(context).libraryFilterSubject,
          count: subjectCount,
          onTap: onSubjectTap,
        ),
        _FilterChipButton(
          label: L10n.of(context).libraryFilterTopic,
          count: topicCount,
          onTap: onTopicTap,
        ),
        _FilterChipButton(
          label: L10n.of(context).libraryFilterGrade,
          count: gradeCount,
          onTap: onGradeTap,
        ),
        _FilterChipButton(
          label: L10n.of(context).libraryFilterLanguage,
          count: languageCount,
          onTap: onLanguageTap,
        ),
        if (onClear != null)
          TextButton(
            onPressed: onClear,
            child: Text(clearLabel),
          ),
      ],
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    required this.count,
    required this.onTap,
  });

  final String label;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = count > 0 ? '$label ($count)' : label;
    return ActionChip(
      label: Text(text),
      onPressed: onTap,
      backgroundColor: LearnyColors.neutralSoft,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }
}

class _PackItem extends StatelessWidget {
  const _PackItem({required this.pack});

  final LearningPack pack;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: pack.color.withValues(alpha: 0.2),
          child: Icon(pack.icon, color: pack.color),
        ),
        title: Text(pack.title),
        subtitle: Text('${pack.subject} • ${pack.topic ?? 'General'}'),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () {
          final state = AppStateScope.of(context);
          state.selectPack(pack.id);
          Navigator.pushNamed(context, AppRoutes.packDetail);
        },
      ),
    );
  }
}
