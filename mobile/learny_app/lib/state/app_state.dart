import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app/backend_config.dart';
import '../routes/app_routes.dart';
import '../data/fake_repositories.dart';
import '../models/achievement.dart';
import '../models/child_profile.dart';
import '../models/daily_learning_time.dart';
import '../models/document_item.dart';
import '../models/faq_item.dart';
import '../models/learning_pack.dart';
import '../models/notification_item.dart';
import '../models/parent_profile.dart';
import '../models/plan_option.dart';
import '../models/quiz_question.dart';
import '../models/quiz_session.dart';
import '../models/revision_prompt.dart';
import '../models/revision_session.dart';
import '../models/user_profile.dart';
import '../models/weak_area.dart';
import '../models/weekly_summary.dart';
import '../services/backend_client.dart';
import '../theme/app_theme.dart';

class AppState extends ChangeNotifier {
  AppState({
    FakeRepositories? repositories,
    BackendClient? backendClient,
    bool initializeBackendSession = true,
    Duration submitRetryDelay = const Duration(seconds: 2),
  }) : _repositories = repositories ?? FakeRepositories(),
       backend = backendClient ?? BackendClient(baseUrl: BackendConfig.baseUrl),
       _submitRetryDelay = submitRetryDelay {
    _load();
    if (initializeBackendSession) {
      _initializeBackendSession();
    }
  }

  final FakeRepositories _repositories;
  final BackendClient backend;
  final Duration _submitRetryDelay;

  late UserProfile profile;
  late ParentProfile parentProfile;
  late List<LearningPack> packs;
  late List<Achievement> achievements;
  late List<ChildProfile> children;
  late List<DocumentItem> documents;
  late List<NotificationItem> notifications;
  late Map<String, double> mastery;
  late WeeklySummary weeklySummary;
  late List<WeakArea> weakAreas;
  late List<DailyLearningTime> learningTimes;
  late String currentPlan;
  late List<PlanOption> planOptions;
  late List<FaqItem> faqs;
  late List<String> supportTopics;

  int streakDays = 0;
  int xpToday = 0;
  int totalXp = 0;
  int reviewDueCount = 0;
  List<String> reviewDueConceptKeys = [];
  GameOutcome? lastGameOutcome;
  String? lastResultSyncError;

  bool onboardingComplete = false;

  String? selectedPackId;
  QuizSession? quizSession;
  RevisionSession? revisionSession;
  String? lastDocumentId;
  bool inPackSession = false;
  PackSessionStage? packSessionStage;
  Map<String, dynamic>? flashcardsPayload;
  Map<String, dynamic>? matchingPayload;
  Map<String, Map<String, dynamic>> gamePayloads = {};
  Map<String, String> gameIds = {};
  List<String> packGameQueue = [];
  int packGameIndex = 0;
  String? currentGameType;
  String? currentGameTitle;
  String? lastAutoGameType;

  bool isGeneratingQuiz = false;
  String generationStatus = 'Idle';
  String? generationError;
  String? backendChildId;
  List<Uint8List> pendingImages = [];
  List<String> pendingImageNames = [];
  String? pendingSubject;
  String? pendingLanguage;
  String? pendingLearningGoal;
  String? pendingContextText;
  List<String> pendingGameTypes = [];
  String? currentGameId;
  bool isSyncingDocuments = false;
  String? documentSyncError;
  List<Map<String, dynamic>> _revisionSubmissionPayload = [];

  int _docCounter = 0;

  bool notificationsEnabled = true;
  bool soundEnabled = true;
  bool remindersEnabled = true;

  final String _demoEmail = BackendConfig.demoEmail;
  final String _demoPassword = BackendConfig.demoPassword;
  bool _backendSessionReady = false;
  bool _backendSessionInitializing = false;
  String? _lastLocalStreakAwardDate;

  void _load() {
    profile = _repositories.user.loadProfile();
    children = _repositories.user.loadChildren();
    packs = List<LearningPack>.from(_repositories.packs.loadPacks());
    achievements = _repositories.progress.loadAchievements();
    mastery = _repositories.progress.loadMastery();
    documents = List<DocumentItem>.from(
      _repositories.documents.loadDocuments(),
    );
    notifications = _repositories.notifications.loadNotifications();
    weeklySummary = _repositories.user.loadWeeklySummary();
    weakAreas = _repositories.user.loadWeakAreas();
    learningTimes = _repositories.user.loadLearningTimes();
    streakDays = _repositories.progress.loadStreakDays();
    xpToday = _repositories.progress.loadXpToday();
    totalXp = _repositories.progress.loadTotalXp();
    parentProfile = _repositories.account.loadParentProfile();
    currentPlan = _repositories.billing.loadCurrentPlan();
    planOptions = _repositories.billing.loadPlanOptions();
    faqs = _repositories.support.loadFaqs();
    supportTopics = _repositories.support.loadSupportTopics();
    selectedPackId = packs.isNotEmpty ? packs.first.id : null;
    _docCounter = documents.length;
  }

  void _initializeBackendSession() {
    if (_backendSessionInitializing || _backendSessionReady) {
      return;
    }
    _backendSessionInitializing = true;
    Future.microtask(() async {
      try {
        await _ensureBackendSession();
        _backendSessionReady = true;
        await _refreshReviewCount();
      } catch (_) {
        // Surface errors during upload instead of at boot time.
      } finally {
        _backendSessionInitializing = false;
      }
    });
  }

  LearningPack? get selectedPack {
    if (selectedPackId == null) {
      return null;
    }
    return packs.where((pack) => pack.id == selectedPackId).firstOrNull;
  }

  bool get hasReadyGeneratedGame {
    return !isGeneratingQuiz &&
        gamePayloads.isNotEmpty &&
        currentPackGameType != null;
  }

  void completeOnboarding() {
    onboardingComplete = true;
    notifyListeners();
  }

  void selectPack(String packId) {
    selectedPackId = packId;
    notifyListeners();
  }

  void startDocumentProcessing({
    required String title,
    required String subject,
  }) {
    _docCounter += 1;
    final newDoc = DocumentItem(
      id: 'doc-${_docCounter.toString().padLeft(3, '0')}',
      title: title,
      subject: subject,
      createdAt: DateTime.now(),
      statusLabel: 'Processing',
    );
    documents = [newDoc, ...documents];
    lastDocumentId = newDoc.id;
    notifyListeners();
  }

  void completeDocumentProcessing() {
    final docId = lastDocumentId;
    if (docId == null) {
      return;
    }
    documents = documents
        .map(
          (doc) => doc.id == docId ? doc.copyWith(statusLabel: 'Ready') : doc,
        )
        .toList();
    final doc = documents.firstWhere((item) => item.id == docId);
    _addPackFromDocument(doc);
    notifyListeners();
  }

  void _addPackFromDocument(DocumentItem doc) {
    final style = _packStyleForSubject(doc.subject);
    final newPack = LearningPack(
      id: 'pack-${doc.id}',
      title: doc.title,
      subject: doc.subject,
      itemCount: 12,
      minutes: 10,
      icon: style.icon,
      color: style.color,
      progress: 0.0,
    );
    packs = [newPack, ...packs];
    selectedPackId = newPack.id;
  }

  _PackStyle _packStyleForSubject(String subject) {
    final normalized = subject.toLowerCase();
    if (normalized.contains('math')) {
      return _PackStyle(Icons.calculate_rounded, LearnyColors.coral);
    }
    if (normalized.contains('science')) {
      return _PackStyle(Icons.science_rounded, LearnyColors.teal);
    }
    if (normalized.contains('geography')) {
      return _PackStyle(Icons.public_rounded, LearnyColors.purple);
    }
    return _PackStyle(Icons.auto_stories_rounded, LearnyColors.coralLight);
  }

  void startQuiz({String? packId}) {
    final id =
        packId ?? selectedPackId ?? (packs.isNotEmpty ? packs.first.id : null);
    if (id == null) {
      return;
    }
    selectedPackId = id;
    currentGameType = 'quiz';
    currentGameTitle = 'Quick Quiz';
    currentGameId = null;
    lastGameOutcome = null;
    lastResultSyncError = null;
    quizSession = QuizSession(
      packId: id,
      questions: _repositories.packs.loadQuestions(id),
    );
    notifyListeners();
  }

  void startPackSession({String? packId}) {
    inPackSession = true;
    packSessionStage = PackSessionStage.flashcards;
    final id =
        packId ?? selectedPackId ?? (packs.isNotEmpty ? packs.first.id : null);
    if (id != null) {
      selectedPackId = id;
    }
    if (packGameQueue.isEmpty) {
      _setPackGameQueue(['flashcards', 'quiz', 'matching']);
    }
    notifyListeners();
  }

  String? startReviewFromDueConcepts() {
    if (packs.isEmpty) {
      return null;
    }
    final dueConcepts = reviewDueConceptKeys.toSet();
    LearningPack? targetPack;
    if (dueConcepts.isNotEmpty) {
      targetPack = packs.firstWhere(
        (pack) => pack.conceptKeys.any(dueConcepts.contains),
        orElse: () => packs.first,
      );
    } else {
      targetPack = selectedPack ?? packs.first;
    }

    startPackSession(packId: targetPack.id);
    final firstType = currentPackGameType ?? 'quiz';
    startGameType(firstType);
    return routeForGameType(firstType);
  }

  void advancePackSession(PackSessionStage stage) {
    if (!inPackSession) {
      return;
    }
    packSessionStage = stage;
    notifyListeners();
  }

  void completePackSession() {
    if (!inPackSession) {
      return;
    }
    // Pack progress is derived from backend mastery and should not be faked locally.
  }

  void endPackSession() {
    inPackSession = false;
    packSessionStage = null;
    packGameQueue = [];
    packGameIndex = 0;
    gameIds = {};
    notifyListeners();
  }

  Future<void> startRevision({String? packId}) async {
    final id =
        packId ?? selectedPackId ?? (packs.isNotEmpty ? packs.first.id : null);
    if (id == null) {
      return;
    }
    selectedPackId = id;
    final pack = packs.firstWhere(
      (item) => item.id == id,
      orElse: () => packs.first,
    );
    _revisionSubmissionPayload = [];

    revisionSession = _buildFallbackRevisionSession(
      packId: id,
      subjectLabel: '${pack.subject} • ${pack.title}',
    );
    notifyListeners();

    try {
      final session = await _ensureBackendSession();
      final payload = await backend.startRevisionSession(
        childId: session.childId,
        limit: 5,
      );
      final data = payload['data'];
      if (data is Map<String, dynamic>) {
        final backendSession = _buildBackendRevisionSession(data);
        if (backendSession != null && backendSession.prompts.isNotEmpty) {
          revisionSession = backendSession;
          _revisionSubmissionPayload = [];
          notifyListeners();
        }
      }
    } catch (_) {
      // Keep local fallback session if backend revision session is unavailable.
    }
  }

  Future<void> answerRevisionPrompt(int selectedIndex) async {
    final session = revisionSession;
    if (session == null) {
      return;
    }
    final prompt = session.currentPrompt;
    if (prompt == null) {
      return;
    }
    if (selectedIndex == prompt.correctIndex) {
      session.correctCount += 1;
      if (session.backendSessionId == null) {
        xpToday += 3;
        totalXp += 3;
      }
    }
    _revisionSubmissionPayload = [
      ..._revisionSubmissionPayload,
      {'item_id': prompt.id, 'selected_index': selectedIndex, 'latency_ms': 0},
    ];
    session.currentIndex += 1;
    if (session.isComplete) {
      await _syncCompletedRevisionSession(session);
    }
    notifyListeners();
  }

  void resetRevision() {
    revisionSession = null;
    _revisionSubmissionPayload = [];
    notifyListeners();
  }

  RevisionSession _buildFallbackRevisionSession({
    required String packId,
    required String subjectLabel,
  }) {
    return RevisionSession(
      prompts: _repositories.packs.loadRevisionPrompts(packId),
      subjectLabel: subjectLabel,
      durationMinutes: 5,
    );
  }

  RevisionSession? _buildBackendRevisionSession(Map<String, dynamic> data) {
    final rawItems = data['items'] as List<dynamic>? ?? [];
    final prompts = rawItems
        .whereType<Map<String, dynamic>>()
        .map((item) {
          final options = (item['options'] as List<dynamic>? ?? [])
              .map((option) => option.toString())
              .where((option) => option.isNotEmpty)
              .toList();
          final promptId = item['id']?.toString() ?? '';
          final promptText = item['prompt']?.toString() ?? '';
          final correctIndex = (item['correct_index'] as num?)?.toInt() ?? 0;
          if (promptId.isEmpty || promptText.isEmpty || options.length < 2) {
            return null;
          }

          return RevisionPrompt(
            id: promptId,
            prompt: promptText,
            options: options,
            correctIndex: correctIndex.clamp(0, options.length - 1),
          );
        })
        .whereType<RevisionPrompt>()
        .toList();

    if (prompts.isEmpty) {
      return null;
    }

    return RevisionSession(
      backendSessionId: data['id']?.toString(),
      prompts: prompts,
      subjectLabel: data['subject_label']?.toString() ?? 'Quick Revision',
      durationMinutes: (data['duration_minutes'] as num?)?.toInt() ?? 5,
    );
  }

  Future<void> _syncCompletedRevisionSession(RevisionSession session) async {
    final backendSessionId = session.backendSessionId;
    if (backendSessionId == null || _revisionSubmissionPayload.isEmpty) {
      return;
    }

    try {
      final backendSession = await _ensureBackendSession();
      final payload = await backend.submitRevisionSession(
        childId: backendSession.childId,
        sessionId: backendSessionId,
        results: List<Map<String, dynamic>>.from(_revisionSubmissionPayload),
      );
      final data = payload['data'];
      if (data is Map<String, dynamic>) {
        final xpEarned = (data['xp_earned'] as num?)?.toInt() ?? 0;
        final correctItems = (data['correct_items'] as num?)?.toInt();
        if (xpEarned > 0) {
          xpToday += xpEarned;
          totalXp += xpEarned;
        }
        if (correctItems != null) {
          session.correctCount = correctItems;
        }
      }
      _revisionSubmissionPayload = [];
      await _refreshReviewCount();
    } catch (error) {
      lastResultSyncError = error.toString();
      notifyListeners();
    }
  }

  Future<void> generateQuizFromAsset({
    required String assetPath,
    required String filename,
  }) async {
    final bytes = await rootBundle.load(assetPath);
    await generateQuizFromBytes(
      bytes: bytes.buffer.asUint8List(),
      filename: filename,
    );
  }

  Future<void> generateQuizFromPendingImage() async {
    if (pendingImages.isEmpty) {
      throw BackendException('No image selected.');
    }
    await generateQuizFromImages(
      images: List<Uint8List>.from(pendingImages),
      filenames: List<String>.from(pendingImageNames),
    );
    pendingImages = [];
    pendingImageNames = [];
  }

  void setPendingImage({required Uint8List bytes, required String filename}) {
    pendingImages = [bytes];
    pendingImageNames = [filename];
    notifyListeners();
  }

  void addPendingImage({required Uint8List bytes, required String filename}) {
    pendingImages = [...pendingImages, bytes];
    pendingImageNames = [...pendingImageNames, filename];
    notifyListeners();
  }

  void clearPendingImages() {
    pendingImages = [];
    pendingImageNames = [];
    notifyListeners();
  }

  void setPendingContext({
    String? subject,
    String? language,
    String? learningGoal,
    String? contextText,
  }) {
    pendingSubject = subject;
    pendingLanguage = language;
    pendingLearningGoal = learningGoal;
    pendingContextText = contextText;
    notifyListeners();
  }

  void setPendingGameTypes(List<String> types) {
    pendingGameTypes = types;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> suggestDocumentMetadata({
    String? filename,
    String? contextText,
    String? languageHint,
  }) async {
    try {
      final session = await _ensureBackendSession();
      final payload = await backend.suggestDocumentMetadata(
        childId: session.childId,
        filename: filename,
        contextText: contextText,
        languageHint: languageHint,
      );
      final data = payload['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> generateQuizFromBytes({
    required Uint8List bytes,
    required String filename,
  }) async {
    generationError = null;
    isGeneratingQuiz = true;
    generationStatus = 'Uploading document...';
    notifyListeners();

    try {
      final session = await _ensureBackendSession();
      final document = await backend.uploadDocument(
        childId: session.childId,
        bytes: bytes,
        filename: filename,
        subject: pendingSubject,
        language: pendingLanguage,
        gradeLevel: BackendConfig.childGrade,
        learningGoal: pendingLearningGoal,
        contextText: pendingContextText,
        requestedGameTypes: pendingGameTypes,
      );
      lastDocumentId = _extractId(document);

      generationStatus = 'Processing and generating quiz...';
      notifyListeners();

      await _pollForPackAndQuiz(session.childId, lastDocumentId);
      generationStatus = 'Quiz ready!';
    } catch (error) {
      generationError = error.toString();
      generationStatus = 'Generation failed';
    } finally {
      isGeneratingQuiz = false;
      pendingSubject = null;
      pendingLanguage = null;
      pendingLearningGoal = null;
      pendingContextText = null;
      pendingGameTypes = [];
      notifyListeners();
    }
  }

  Future<void> generateQuizFromImages({
    required List<Uint8List> images,
    required List<String> filenames,
  }) async {
    generationError = null;
    isGeneratingQuiz = true;
    generationStatus = 'Uploading document...';
    notifyListeners();

    try {
      final session = await _ensureBackendSession();
      final document = await backend.uploadDocumentBatch(
        childId: session.childId,
        files: images,
        filenames: filenames,
        subject: pendingSubject,
        language: pendingLanguage,
        gradeLevel: BackendConfig.childGrade,
        learningGoal: pendingLearningGoal,
        contextText: pendingContextText,
        requestedGameTypes: pendingGameTypes,
      );
      lastDocumentId = _extractId(document);

      generationStatus = 'Processing and generating quiz...';
      notifyListeners();

      await _pollForPackAndQuiz(session.childId, lastDocumentId);
      generationStatus = 'Quiz ready!';
    } catch (error) {
      generationError = error.toString();
      generationStatus = 'Generation failed';
    } finally {
      isGeneratingQuiz = false;
      pendingSubject = null;
      pendingLanguage = null;
      pendingLearningGoal = null;
      pendingContextText = null;
      pendingGameTypes = [];
      notifyListeners();
    }
  }

  Future<_BackendSession> _ensureBackendSession() async {
    if (backend.token == null) {
      try {
        await backend.login(email: _demoEmail, password: _demoPassword);
      } catch (error) {
        try {
          await backend.register(
            name: BackendConfig.demoName,
            email: _demoEmail,
            password: _demoPassword,
          );
        } catch (registerError) {
          if (_isEmailTaken(registerError)) {
            await backend.login(email: _demoEmail, password: _demoPassword);
          } else {
            rethrow;
          }
        }
      }
    }

    if (backendChildId == null) {
      final children = await backend.listChildren();
      final selectedChild = children.firstWhere(
        (child) => child['name']?.toString() == BackendConfig.childName,
        orElse: () =>
            children.isNotEmpty ? children.first : <String, dynamic>{},
      );
      backendChildId = _extractId(selectedChild);
      _syncGamificationFromBackendChild(selectedChild);

      if (backendChildId == null) {
        final created = await backend.createChild(
          name: BackendConfig.childName,
          gradeLevel: BackendConfig.childGrade,
        );
        backendChildId = _extractId(created);
        _syncGamificationFromBackendChild(created);
        if (backendChildId == null && children.isEmpty) {
          final refreshed = await backend.listChildren();
          if (refreshed.isNotEmpty) {
            _syncGamificationFromBackendChild(
              refreshed.first as Map<String, dynamic>,
            );
          }
          backendChildId = refreshed.isNotEmpty
              ? _extractId(refreshed.first)
              : null;
        }
      }
    }

    final childId = backendChildId;
    if (childId == null) {
      throw BackendException('No child profile available.');
    }

    return _BackendSession(childId: childId);
  }

  void _syncGamificationFromBackendChild(Map<String, dynamic> child) {
    var changed = false;
    final backendStreak = (child['streak_days'] as num?)?.toInt();
    final backendTotalXp = (child['total_xp'] as num?)?.toInt();

    if (backendStreak != null && backendStreak != streakDays) {
      streakDays = backendStreak;
      changed = true;
    }
    if (backendTotalXp != null && backendTotalXp != totalXp) {
      totalXp = backendTotalXp;
      changed = true;
    }

    if (changed) {
      notifyListeners();
    }
  }

  bool _isEmailTaken(Object error) {
    return error.toString().toLowerCase().contains(
      'email has already been taken',
    );
  }

  String? _extractId(Map<String, dynamic> data) {
    final value = data['_id'] ?? data['id'];
    if (value is Map) {
      final oid = value[r'$oid'] ?? value['oid'];
      return oid?.toString();
    }
    return value?.toString();
  }

  Future<void> _pollForPackAndQuiz(String childId, String? documentId) async {
    if (documentId == null) {
      throw BackendException('Missing document ID.');
    }

    // Exponential backoff: starts at 3s, grows to max 15s.
    // ~60 attempts gives roughly 3-5 minutes depending on backoff growth.
    const maxAttempts = 60;
    var delay = const Duration(seconds: 3);
    const maxDelay = Duration(seconds: 15);

    for (var attempt = 0; attempt < maxAttempts; attempt += 1) {
      final doc = await backend.getDocument(
        childId: childId,
        documentId: documentId,
      );
      final status = doc['status']?.toString();
      final pipelineStage = doc['pipeline_stage']?.toString();
      final progressHint = (doc['progress_hint'] as num?)?.toInt();

      // Update status message based on document status
      final stageMessage = _generationStatusForStage(
        pipelineStage: pipelineStage,
        status: status,
        progressHint: progressHint,
      );
      if (stageMessage != null) {
        generationStatus = stageMessage;
        notifyListeners();
      }

      if (status == 'failed') {
        throw BackendException('Document processing failed.');
      }

      // Only check for packs once document processing is complete
      if (status == 'processed' || status == 'ready') {
        final packs = await backend.listLearningPacks(
          childId: childId,
          documentId: documentId,
        );

        if (packs.isNotEmpty) {
          final pack = packs.first as Map<String, dynamic>;
          final packId = _extractId(pack);
          if (packId == null) {
            throw BackendException('Pack missing id.');
          }
          selectedPackId = packId;
          _syncPackFromBackend(pack, selectPack: true);

          generationStatus = 'Creating games and quizzes...';
          notifyListeners();

          final games = await backend.listGames(
            childId: childId,
            packId: packId,
          );
          final payloadsByType = <String, Map<String, dynamic>>{};
          final idsByType = <String, String>{};
          for (final entry in games.cast<Map<String, dynamic>>()) {
            final status = entry['status']?.toString();
            final type = entry['type']?.toString();
            final payload = entry['payload'];
            final id = _extractId(entry);
            if (status == 'ready' &&
                type != null &&
                payload is Map<String, dynamic>) {
              payloadsByType[type] = payload;
              if (id != null) idsByType[type] = id;
            }
          }
          gamePayloads = payloadsByType;
          gameIds = idsByType;
          flashcardsPayload = payloadsByType['flashcards'];
          matchingPayload = payloadsByType['matching'];
          _setPackGameQueue(payloadsByType.keys.toList());

          final selectedType = _pickNextGameType(packGameQueue);
          if (selectedType != null) {
            final selectedIndex = packGameQueue.indexOf(selectedType);
            if (selectedIndex >= 0) {
              packGameIndex = selectedIndex;
            }
            startGameType(selectedType);
            return;
          }
        }
      }

      await Future.delayed(delay);
      delay = Duration(
        seconds: (delay.inSeconds * 1.5).round().clamp(3, maxDelay.inSeconds),
      );
    }

    throw BackendException('Quiz generation timed out. Please try again.');
  }

  String? _generationStatusForStage({
    required String? pipelineStage,
    required String? status,
    required int? progressHint,
  }) {
    final prefix = progressHint == null ? '' : '$progressHint% • ';
    return switch (pipelineStage) {
      'queued' => '${prefix}Waiting in queue...',
      'ocr' => '${prefix}Reading your document...',
      'concept_extraction_queued' => '${prefix}Preparing concepts...',
      'concept_extraction' => '${prefix}Extracting key concepts...',
      'learning_pack_queued' => '${prefix}Preparing learning pack...',
      'learning_pack_generation' => '${prefix}Building learning pack...',
      'game_generation_queued' => '${prefix}Preparing games...',
      'game_generation' => '${prefix}Generating games and quizzes...',
      'ready' => '100% • Quiz ready!',
      'ocr_failed' => 'OCR failed. Please retry.',
      'concept_extraction_failed' => 'Concept extraction failed. Please retry.',
      'learning_pack_failed' => 'Pack generation failed. Please retry.',
      'game_generation_failed' => 'Game generation failed. Please retry.',
      _ => switch (status) {
        'queued' => '${prefix}Waiting in queue...',
        'processing' => '${prefix}Processing document...',
        'processed' => '${prefix}Generating learning content...',
        'ready' => '100% • Quiz ready!',
        _ => null,
      },
    };
  }

  void _syncPackFromBackend(
    Map<String, dynamic> pack, {
    bool selectPack = false,
  }) {
    final newPack = _learningPackFromBackend(pack);
    if (newPack == null) {
      return;
    }

    final existingIndex = packs.indexWhere((item) => item.id == newPack.id);
    if (existingIndex >= 0) {
      final updated = List<LearningPack>.from(packs);
      updated[existingIndex] = newPack;
      packs = updated;
    } else {
      packs = [newPack, ...packs];
    }

    if (selectPack || selectedPackId == null) {
      selectedPackId = newPack.id;
    }
  }

  LearningPack? _learningPackFromBackend(Map<String, dynamic> pack) {
    final packId = _extractId(pack) ?? pack['_id']?.toString() ?? '';
    if (packId.isEmpty) {
      return null;
    }
    final title = pack['title']?.toString() ?? 'Learning Pack';
    final summary = pack['summary']?.toString();
    final content = pack['content'] as Map<String, dynamic>?;
    final items = content?['items'] as List<dynamic>? ?? [];
    final conceptKeys = (content?['concepts'] as List<dynamic>? ?? [])
        .map(
          (concept) =>
              (concept as Map<String, dynamic>)['key']?.toString() ??
              concept['concept_key']?.toString() ??
              '',
        )
        .where((key) => key.isNotEmpty)
        .toSet()
        .toList();
    final subject = summary?.split(' ').first ?? 'Homework';
    final masteryPct = (pack['mastery_percentage'] as num?)?.toInt() ?? 0;
    final conceptsMastered = (pack['concepts_mastered'] as num?)?.toInt() ?? 0;
    final conceptsTotal = (pack['concepts_total'] as num?)?.toInt() ?? 0;

    final style = _packStyleForSubject(subject);
    final newPack = LearningPack(
      id: packId,
      title: title,
      subject: subject,
      itemCount: items.length,
      minutes: 10,
      icon: style.icon,
      color: style.color,
      progress: masteryPct / 100.0,
      conceptsMastered: conceptsMastered,
      conceptsTotal: conceptsTotal,
      conceptKeys: conceptKeys,
    );

    return newPack;
  }

  Future<void> _refreshPacksFromBackend() async {
    final childId = backendChildId;
    if (childId == null) {
      return;
    }

    try {
      final data = await backend.listLearningPacks(childId: childId);
      if (data.isEmpty) {
        return;
      }

      final before = packs
          .map((pack) {
            return '${pack.id}:${pack.progress}:${pack.conceptsMastered}:${pack.conceptsTotal}';
          })
          .join('|');

      for (final entry in data.whereType<Map<String, dynamic>>()) {
        _syncPackFromBackend(entry);
      }

      final after = packs
          .map((pack) {
            return '${pack.id}:${pack.progress}:${pack.conceptsMastered}:${pack.conceptsTotal}';
          })
          .join('|');

      if (before != after) {
        notifyListeners();
      }
    } catch (_) {
      // Ignore transient refresh failures.
    }
  }

  void _loadQuizFromPayload(Map<String, dynamic> game) {
    currentGameId = _extractId(game);
    final packId =
        _extractId({'_id': game['learning_pack_id']}) ??
        game['learning_pack_id']?.toString() ??
        selectedPackId ??
        '';
    final type = game['type']?.toString() ?? 'quiz';
    final payload = game['payload'] as Map<String, dynamic>? ?? {};
    currentGameType = type;
    currentGameTitle = payload['title']?.toString();
    lastAutoGameType = type;
    final mapped = <QuizQuestion>[];

    if (type == 'ordering') {
      final items = payload['items'] as List<dynamic>? ?? [];
      for (final item in items) {
        final data = item as Map<String, dynamic>;
        final sequence = (data['sequence'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList();
        if (sequence.isEmpty) {
          continue;
        }
        final shuffled = List<String>.from(sequence)..shuffle();
        mapped.add(
          QuizQuestion(
            id: data['id']?.toString() ?? UniqueKey().toString(),
            prompt: data['prompt']?.toString() ?? 'Put these in order',
            options: shuffled,
            correctIndex: 0,
            orderedSequence: sequence,
            hint: data['hint']?.toString(),
            explanation: data['explanation']?.toString(),
            topic: data['topic']?.toString(),
          ),
        );
      }
    } else {
      final questions = payload['questions'] as List<dynamic>? ?? [];
      for (final item in questions) {
        final data = item as Map<String, dynamic>;
        if (type == 'true_false') {
          mapped.add(
            QuizQuestion(
              id: data['id']?.toString() ?? UniqueKey().toString(),
              prompt: data['statement']?.toString() ?? '',
              options: const ['True', 'False'],
              correctIndex: (data['answer'] == true) ? 0 : 1,
              explanation: data['explanation']?.toString(),
              topic: data['topic']?.toString(),
            ),
          );
        } else if (type == 'multiple_select') {
          final indices = (data['answer_indices'] as List<dynamic>? ?? [])
              .map((e) => (e as num).toInt())
              .toList();
          mapped.add(
            QuizQuestion(
              id: data['id']?.toString() ?? UniqueKey().toString(),
              prompt: data['prompt']?.toString() ?? '',
              options: (data['choices'] as List<dynamic>? ?? [])
                  .map((e) => e.toString())
                  .toList(),
              correctIndex: indices.isNotEmpty ? indices.first : 0,
              correctIndices: indices,
              hint: data['hint']?.toString(),
              explanation: data['explanation']?.toString(),
              topic: data['topic']?.toString(),
            ),
          );
        } else if (type == 'fill_blank' || type == 'short_answer') {
          mapped.add(
            QuizQuestion(
              id: data['id']?.toString() ?? UniqueKey().toString(),
              prompt: data['prompt']?.toString() ?? '',
              options: const [],
              correctIndex: 0,
              answerText: data['answer']?.toString(),
              acceptedAnswers:
                  (data['accepted_answers'] as List<dynamic>? ?? [])
                      .map((e) => e.toString())
                      .toList(),
              hint: data['hint']?.toString(),
              explanation: data['explanation']?.toString(),
              topic: data['topic']?.toString(),
            ),
          );
        } else {
          mapped.add(
            QuizQuestion(
              id: data['id']?.toString() ?? UniqueKey().toString(),
              prompt: data['prompt']?.toString() ?? '',
              options: (data['choices'] as List<dynamic>? ?? [])
                  .map((e) => e.toString())
                  .toList(),
              correctIndex: (data['answer_index'] as int?) ?? 0,
              hint: data['hint']?.toString(),
              explanation: data['explanation']?.toString(),
              topic: data['topic']?.toString(),
            ),
          );
        }
      }
    }

    quizSession = QuizSession(packId: packId, questions: mapped);
  }

  void startGameType(String type) {
    final payload = gamePayloads[type];
    currentGameType = type;
    currentGameId = gameIds[type];
    currentGameTitle = payload?['title']?.toString();
    lastGameOutcome = null;
    lastResultSyncError = null;

    if (type == 'flashcards') {
      if (payload != null) {
        flashcardsPayload = payload;
      }
      notifyListeners();
      return;
    }

    if (type == 'matching') {
      if (payload != null) {
        matchingPayload = payload;
      }
      notifyListeners();
      return;
    }

    if (payload != null) {
      _loadQuizFromPayload({
        'type': type,
        'payload': payload,
        '_id': gameIds[type],
      });
      notifyListeners();
      return;
    }
    startQuiz();
  }

  String? _pickNextGameType(List<String> availableTypes) {
    if (availableTypes.isEmpty) {
      return null;
    }
    if (availableTypes.length == 1) {
      return availableTypes.first;
    }
    final random = Random();
    var choice = availableTypes[random.nextInt(availableTypes.length)];
    if (lastAutoGameType != null && choice == lastAutoGameType) {
      final fallback = availableTypes
          .where((type) => type != lastAutoGameType)
          .toList();
      if (fallback.isNotEmpty) {
        choice = fallback[random.nextInt(fallback.length)];
      }
    }
    return choice;
  }

  void advancePackGame() {
    if (!inPackSession) {
      return;
    }
    if (packGameIndex + 1 < packGameQueue.length) {
      packGameIndex += 1;
      notifyListeners();
    }
  }

  String? get currentPackGameType {
    if (packGameQueue.isEmpty || packGameIndex >= packGameQueue.length) {
      return null;
    }
    return packGameQueue[packGameIndex];
  }

  String? get nextPackGameType {
    if (packGameQueue.isEmpty || packGameIndex + 1 >= packGameQueue.length) {
      return null;
    }
    return packGameQueue[packGameIndex + 1];
  }

  String routeForGameType(String type) {
    if (type == 'flashcards') {
      return AppRoutes.flashcards;
    }
    if (type == 'matching') {
      return AppRoutes.matching;
    }
    return AppRoutes.quiz;
  }

  void _setPackGameQueue(List<String> availableTypes) {
    const preferredOrder = [
      'flashcards',
      'quiz',
      'true_false',
      'multiple_select',
      'fill_blank',
      'short_answer',
      'ordering',
      'matching',
    ];
    final normalized = availableTypes.toSet();
    final ordered = preferredOrder.where(normalized.contains).toList();
    if (ordered.isEmpty) {
      packGameQueue = ['flashcards', 'quiz', 'matching'];
    } else {
      packGameQueue = ordered;
    }
    packGameIndex = 0;
  }

  Future<void> completeFlashcardsGame(List<Map<String, dynamic>> cards) async {
    final results = cards
        .where((card) => (card['front']?.toString().trim().isNotEmpty ?? false))
        .map(
          (card) => <String, dynamic>{
            'correct': true,
            'prompt': card['front']?.toString() ?? '',
            'topic': card['topic']?.toString(),
            'response': 'Reviewed',
            'expected': card['back']?.toString() ?? '',
          },
        )
        .toList();
    await _recordAndSubmitGameCompletion(
      gameType: currentGameType ?? 'flashcards',
      totalQuestions: results.length,
      correctAnswers: results.length,
      results: results,
    );
  }

  Future<void> completeMatchingGame(List<Map<String, dynamic>> pairs) async {
    final results = pairs
        .where(
          (pair) =>
              (pair['left']?.toString().trim().isNotEmpty ?? false) &&
              (pair['right']?.toString().trim().isNotEmpty ?? false),
        )
        .map(
          (pair) => <String, dynamic>{
            'correct': true,
            'prompt': pair['left']?.toString() ?? '',
            'topic': pair['topic']?.toString(),
            'response': pair['right']?.toString() ?? '',
            'expected': pair['right']?.toString() ?? '',
          },
        )
        .toList();
    await _recordAndSubmitGameCompletion(
      gameType: currentGameType ?? 'matching',
      totalQuestions: results.length,
      correctAnswers: results.length,
      results: results,
    );
  }

  Future<void> _recordAndSubmitGameCompletion({
    required String gameType,
    required int totalQuestions,
    required int correctAnswers,
    required List<Map<String, dynamic>> results,
  }) async {
    final xpEstimate = correctAnswers * 10;

    lastGameOutcome = GameOutcome(
      gameType: gameType,
      totalQuestions: totalQuestions,
      correctAnswers: correctAnswers,
      xpEarned: xpEstimate,
    );
    lastResultSyncError = null;

    await _submitGameResults(
      gameType: gameType,
      totalQuestions: totalQuestions,
      correctAnswers: correctAnswers,
      results: results,
    );
  }

  Future<void> answerCurrentQuestion(int selectedIndex) async {
    final session = quizSession;
    if (session == null) {
      return;
    }
    final question = session.currentQuestion;
    if (question == null) {
      return;
    }
    final index = session.currentIndex;
    final isCorrect = selectedIndex == question.correctIndex;
    if (isCorrect) {
      session.correctCount += 1;
    } else {
      session.incorrectIndices.add(index);
    }
    session.results.add({
      'correct': isCorrect,
      'prompt': question.prompt,
      'topic': question.topic,
      'response': question.options.isNotEmpty
          ? question.options[selectedIndex]
          : '',
      'expected': question.options.isNotEmpty
          ? question.options[question.correctIndex]
          : '',
    });
    session.currentIndex += 1;
    if (session.isComplete) {
      await _recordAndSubmitGameCompletion(
        gameType: currentGameType ?? 'quiz',
        totalQuestions: session.questions.length,
        correctAnswers: session.correctCount,
        results: List<Map<String, dynamic>>.from(session.results),
      );
    }
    notifyListeners();
  }

  Future<void> answerCurrentQuestionMulti(List<int> selectedIndices) async {
    final session = quizSession;
    if (session == null) {
      return;
    }
    final question = session.currentQuestion;
    if (question == null) {
      return;
    }
    final index = session.currentIndex;
    final correct = (question.correctIndices ?? [question.correctIndex])
        .toSet();
    final selected = selectedIndices.toSet();
    final isCorrect =
        selected.isNotEmpty &&
        selected.length == correct.length &&
        selected.containsAll(correct);
    if (isCorrect) {
      session.correctCount += 1;
    } else {
      session.incorrectIndices.add(index);
    }
    final responseText = selectedIndices
        .map((i) => i < question.options.length ? question.options[i] : '')
        .join(', ');
    final expectedText = correct
        .map((i) => i < question.options.length ? question.options[i] : '')
        .join(', ');
    session.results.add({
      'correct': isCorrect,
      'prompt': question.prompt,
      'topic': question.topic,
      'response': responseText,
      'expected': expectedText,
    });
    session.currentIndex += 1;
    if (session.isComplete) {
      await _recordAndSubmitGameCompletion(
        gameType: currentGameType ?? 'quiz',
        totalQuestions: session.questions.length,
        correctAnswers: session.correctCount,
        results: List<Map<String, dynamic>>.from(session.results),
      );
    }
    notifyListeners();
  }

  Future<void> answerCurrentQuestionText(String value) async {
    final session = quizSession;
    if (session == null) {
      return;
    }
    final question = session.currentQuestion;
    if (question == null) {
      return;
    }
    final index = session.currentIndex;
    final normalized = value.trim().toLowerCase();
    final answers = <String>{};
    if (question.answerText != null) {
      answers.add(question.answerText!.trim().toLowerCase());
    }
    for (final item in question.acceptedAnswers ?? <String>[]) {
      answers.add(item.trim().toLowerCase());
    }
    final isCorrect = answers.contains(normalized);
    if (isCorrect) {
      session.correctCount += 1;
    } else {
      session.incorrectIndices.add(index);
    }
    session.results.add({
      'correct': isCorrect,
      'prompt': question.prompt,
      'topic': question.topic,
      'response': value,
      'expected': question.answerText ?? '',
    });
    session.currentIndex += 1;
    if (session.isComplete) {
      await _recordAndSubmitGameCompletion(
        gameType: currentGameType ?? 'quiz',
        totalQuestions: session.questions.length,
        correctAnswers: session.correctCount,
        results: List<Map<String, dynamic>>.from(session.results),
      );
    }
    notifyListeners();
  }

  Future<void> answerCurrentQuestionOrdering(List<String> ordered) async {
    final session = quizSession;
    if (session == null) {
      return;
    }
    final question = session.currentQuestion;
    if (question == null || question.orderedSequence == null) {
      return;
    }
    final index = session.currentIndex;
    final expected = question.orderedSequence!;
    final isCorrect =
        ordered.length == expected.length &&
        List.generate(
          ordered.length,
          (index) => ordered[index] == expected[index],
        ).every((v) => v);
    if (isCorrect) {
      session.correctCount += 1;
    } else {
      session.incorrectIndices.add(index);
    }
    session.results.add({
      'correct': isCorrect,
      'prompt': question.prompt,
      'topic': question.topic,
      'response': ordered.join(' → '),
      'expected': expected.join(' → '),
    });
    session.currentIndex += 1;
    if (session.isComplete) {
      await _recordAndSubmitGameCompletion(
        gameType: currentGameType ?? 'ordering',
        totalQuestions: session.questions.length,
        correctAnswers: session.correctCount,
        results: List<Map<String, dynamic>>.from(session.results),
      );
    }
    notifyListeners();
  }

  Future<void> _submitGameResults({
    required String gameType,
    required int totalQuestions,
    required int correctAnswers,
    required List<Map<String, dynamic>> results,
  }) async {
    if (results.isEmpty) {
      return;
    }

    final childId = backendChildId;
    final session = quizSession;
    final packId = session != null && session.packId.isNotEmpty
        ? session.packId
        : selectedPackId;
    final gameId = currentGameId;
    if (childId == null || packId == null || gameId == null) {
      _applyLocalGamificationFallback(correctAnswers: correctAnswers);
      lastResultSyncError =
          'Game result sync skipped: missing childId/packId/gameId.';
      debugPrint(lastResultSyncError);
      notifyListeners();
      await _refreshReviewCount();
      return;
    }

    Object? lastError;
    for (var attempt = 0; attempt < 2; attempt += 1) {
      try {
        final response = await backend.submitGameResult(
          childId: childId,
          packId: packId,
          gameId: gameId,
          gameType: gameType,
          results: results,
          totalQuestions: totalQuestions,
          correctAnswers: correctAnswers,
        );

        final streak = (response['streak_days'] as num?)?.toInt();
        final total = (response['total_xp'] as num?)?.toInt();
        final xpEarned = (response['xp_earned'] as num?)?.toInt();
        if (streak != null) {
          streakDays = streak;
          _lastLocalStreakAwardDate = DateTime.now().toIso8601String().split(
            'T',
          )[0];
        }
        if (total != null) {
          totalXp = total;
        }
        if (xpEarned != null) {
          xpToday += xpEarned;
        }
        if (lastGameOutcome != null && xpEarned != null) {
          lastGameOutcome = lastGameOutcome!.copyWith(xpEarned: xpEarned);
        }
        lastResultSyncError = null;
        notifyListeners();
        await _refreshReviewCount();
        await _refreshPacksFromBackend();
        return;
      } catch (error) {
        lastError = error;
        if (attempt == 0) {
          await Future.delayed(_submitRetryDelay);
        }
      }
    }

    _applyLocalGamificationFallback(correctAnswers: correctAnswers);
    lastResultSyncError = lastError.toString();
    debugPrint('Game result submission failed: $lastError');
    notifyListeners();
    await _refreshReviewCount();
  }

  Future<void> _refreshReviewCount() async {
    final childId = backendChildId;
    if (childId == null) {
      return;
    }

    try {
      final response = await backend.fetchReviewQueue(childId: childId);
      if (response != null) {
        reviewDueCount = (response['total_due'] as num?)?.toInt() ?? 0;
        reviewDueConceptKeys = (response['data'] as List<dynamic>? ?? [])
            .whereType<Map<String, dynamic>>()
            .map((item) => item['concept_key']?.toString() ?? '')
            .where((key) => key.isNotEmpty)
            .toSet()
            .toList();
        notifyListeners();
      }
    } catch (_) {
      // Ignore transient refresh failures.
    }
  }

  void _applyLocalGamificationFallback({required int correctAnswers}) {
    final fallbackXp = correctAnswers * 10;
    if (fallbackXp > 0) {
      xpToday += fallbackXp;
      totalXp += fallbackXp;
      if (lastGameOutcome != null) {
        lastGameOutcome = lastGameOutcome!.copyWith(xpEarned: fallbackXp);
      }
    }

    final today = DateTime.now().toIso8601String().split('T')[0];
    if (_lastLocalStreakAwardDate != today) {
      streakDays = (streakDays <= 0) ? 1 : streakDays + 1;
      _lastLocalStreakAwardDate = today;
    }
  }

  void resetQuiz() {
    quizSession = null;
    flashcardsPayload = null;
    matchingPayload = null;
    currentGameType = null;
    currentGameTitle = null;
    currentGameId = null;
    lastResultSyncError = null;
    notifyListeners();
  }

  Future<void> refreshDocumentsFromBackend() async {
    isSyncingDocuments = true;
    documentSyncError = null;
    notifyListeners();

    try {
      final session = await _ensureBackendSession();
      final data = await backend.listDocuments(childId: session.childId);
      documents = data.cast<Map<String, dynamic>>().map((doc) {
        final id = _extractId(doc) ?? '';
        final title = doc['original_filename']?.toString() ?? 'Homework';
        final subject = doc['subject']?.toString() ?? 'Homework';
        final status = doc['status']?.toString() ?? 'unknown';
        final createdAt =
            DateTime.tryParse(doc['created_at']?.toString() ?? '') ??
            DateTime.now();
        return DocumentItem(
          id: id,
          title: title,
          subject: subject,
          createdAt: createdAt,
          statusLabel: _statusLabelForDocument(status),
        );
      }).toList();
    } catch (error) {
      documentSyncError = error.toString();
    } finally {
      isSyncingDocuments = false;
      notifyListeners();
    }
  }

  String _statusLabelForDocument(String status) {
    switch (status) {
      case 'queued':
        return 'Queued';
      case 'processing':
        return 'Processing';
      case 'processed':
        return 'Processed';
      case 'ready':
        return 'Ready';
      case 'failed':
        return 'Failed';
      default:
        return 'Unknown';
    }
  }

  Future<void> regenerateDocument(String documentId) async {
    final session = await _ensureBackendSession();
    await backend.regenerateDocument(
      childId: session.childId,
      documentId: documentId,
    );
    documents = documents
        .map(
          (doc) =>
              doc.id == documentId ? doc.copyWith(statusLabel: 'Queued') : doc,
        )
        .toList();
    notifyListeners();
  }

  Future<void> retryIncorrectQuestions() async {
    final session = quizSession;
    if (session == null || session.incorrectIndices.isEmpty) {
      return;
    }
    final packId = session.packId.isNotEmpty
        ? session.packId
        : (selectedPackId ?? '');
    if (packId.isEmpty) {
      throw BackendException('Missing learning pack id for retry.');
    }
    if (currentGameId != null) {
      final backendSession = await _ensureBackendSession();
      final retryGame = await backend.createRetryGame(
        childId: backendSession.childId,
        packId: packId,
        gameId: currentGameId!,
        questionIndices: session.incorrectIndices,
      );
      _loadQuizFromPayload(retryGame);
      notifyListeners();
      return;
    }

    final questions = session.incorrectIndices
        .where((index) => index >= 0 && index < session.questions.length)
        .map((index) => session.questions[index])
        .toList();
    if (questions.isEmpty) {
      return;
    }
    currentGameTitle = 'Retry Mistakes';
    quizSession = QuizSession(packId: packId, questions: questions);
    notifyListeners();
  }

  void toggleNotifications(bool value) {
    notificationsEnabled = value;
    notifyListeners();
  }

  void toggleSound(bool value) {
    soundEnabled = value;
    notifyListeners();
  }

  void toggleReminders(bool value) {
    remindersEnabled = value;
    notifyListeners();
  }

  void markNotificationRead(String id) {
    notifications = notifications
        .map((item) => item.id == id ? item.copyWith(isRead: true) : item)
        .toList();
    notifyListeners();
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    if (isEmpty) {
      return null;
    }
    return first;
  }
}

class _PackStyle {
  const _PackStyle(this.icon, this.color);

  final IconData icon;
  final Color color;
}

class GameOutcome {
  const GameOutcome({
    required this.gameType,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.xpEarned,
  });

  final String gameType;
  final int totalQuestions;
  final int correctAnswers;
  final int xpEarned;

  GameOutcome copyWith({
    String? gameType,
    int? totalQuestions,
    int? correctAnswers,
    int? xpEarned,
  }) {
    return GameOutcome(
      gameType: gameType ?? this.gameType,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      xpEarned: xpEarned ?? this.xpEarned,
    );
  }
}

enum PackSessionStage { flashcards, quiz, matching, results }

class _BackendSession {
  const _BackendSession({required this.childId});

  final String childId;
}
