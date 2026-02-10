import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app/backend_config.dart';
import '../routes/app_routes.dart';
import '../models/activity_item.dart';
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
import '../models/school_assessment.dart';
import '../models/user_profile.dart';
import '../models/weak_area.dart';
import '../models/weekly_summary.dart';
import '../services/backend_client.dart';
import '../theme/app_theme.dart';

class AppState extends ChangeNotifier {
  AppState({
    BackendClient? backendClient,
    bool initializeBackendSession = true,
    Duration submitRetryDelay = const Duration(seconds: 2),
  }) : backend = backendClient ?? BackendClient(baseUrl: BackendConfig.baseUrl),
       _submitRetryDelay = submitRetryDelay {
    _load();
    if (initializeBackendSession) {
      _initializeBackendSession();
    }
  }

  final BackendClient backend;
  final Duration _submitRetryDelay;

  late UserProfile profile;
  late ParentProfile parentProfile;
  late List<LearningPack> packs;
  late List<Achievement> achievements;
  late List<ActivityItem> activities;
  late List<ChildProfile> children;
  late List<DocumentItem> documents;
  late List<SchoolAssessment> schoolAssessments;
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
  List<Map<String, dynamic>> homeRecommendations = [];
  GameOutcome? lastGameOutcome;
  String? lastResultSyncError;

  Locale? locale;

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
  int uploadProgressPercent = 0;
  int processingProgressPercent = 0;
  String processingStageLabel = 'Waiting';
  String? generationError;
  String? backendChildId;
  List<Uint8List> pendingImages = [];
  List<String> pendingImageNames = [];
  String? pendingSubject;
  String? pendingTitle;
  String? pendingLanguage;
  String? pendingLearningGoal;
  String? pendingContextText;
  List<String> pendingGameTypes = [];
  String? currentGameId;
  String? pipelineStage;
  bool hasFirstPlayableSignal = false;
  bool awaitingScanValidation = false;
  String? scanSuggestedTopic;
  String? scanSuggestedLanguage;
  double scanSuggestionConfidence = 0.0;
  List<String> scanSuggestionAlternatives = [];
  String? scanSuggestionModel;
  bool isSwitchingChild = false;
  bool isSyncingDocuments = false;
  String? documentSyncError;
  bool isSyncingActivities = false;
  String? activitySyncError;
  bool hasMoreActivities = true;
  List<Map<String, dynamic>> _revisionSubmissionPayload = [];
  Map<String, dynamic>? activeQuizSessionData;

  int _docCounter = 0;

  bool notificationsEnabled = true;
  bool soundEnabled = true;
  bool remindersEnabled = true;
  bool memoryPersonalizationEnabled = true;
  bool recommendationWhyEnabled = true;
  String recommendationWhyLevel = 'detailed';
  DateTime? lastMemoryResetAt;
  String? lastMemoryResetScope;
  bool memorySettingsBusy = false;
  String? memorySettingsError;

  final String _demoEmail = BackendConfig.demoEmail;
  final String _demoPassword = BackendConfig.demoPassword;
  bool _backendSessionReady = false;
  bool _backendSessionInitializing = false;
  int _activityPage = 1;
  static const int _activityPerPage = 20;

  void _load() {
    profile = const UserProfile(
      id: 'pending',
      name: 'Learner',
      avatarAsset: 'assets/avatars/avatar_1.png',
      gradeLabel: BackendConfig.childGrade,
      planName: 'Starter',
    );
    children = const [];
    packs = const [];
    achievements = const [];
    activities = const [];
    mastery = const {};
    documents = const [];
    schoolAssessments = const [];
    notifications = const [];
    weeklySummary = const WeeklySummary(
      minutesSpent: 0,
      newBadges: 0,
      sessionsCompleted: 0,
      topSubject: 'N/A',
    );
    weakAreas = const [];
    learningTimes = _emptyLearningTimes();
    streakDays = 0;
    xpToday = 0;
    totalXp = 0;
    parentProfile = const ParentProfile(name: 'Parent', email: '');
    currentPlan = 'Starter';
    planOptions = const [];
    faqs = const [];
    supportTopics = const [];
    selectedPackId = null;
    _docCounter = 0;
    activitySyncError = null;
    hasMoreActivities = true;
    _activityPage = 1;
    uploadProgressPercent = 0;
    processingProgressPercent = 0;
    processingStageLabel = 'Waiting';
    awaitingScanValidation = false;
    scanSuggestedTopic = null;
    scanSuggestedLanguage = null;
    scanSuggestionConfidence = 0.0;
    scanSuggestionAlternatives = [];
    scanSuggestionModel = null;
    activeQuizSessionData = null;
    memoryPersonalizationEnabled = true;
    recommendationWhyEnabled = true;
    recommendationWhyLevel = 'detailed';
    lastMemoryResetAt = null;
    lastMemoryResetScope = null;
    memorySettingsBusy = false;
    memorySettingsError = null;
  }

  static const Set<String> supportedLanguages = {'en', 'fr', 'nl'};

  void setLocale(Locale? newLocale) {
    if (newLocale == locale) return;
    locale = newLocale;
    notifyListeners();
  }

  void _syncLocaleFromLanguage(String? languageCode) {
    if (languageCode != null && supportedLanguages.contains(languageCode)) {
      setLocale(Locale(languageCode));
    }
  }

  ChildProfile? get selectedChildProfile {
    final id = backendChildId;
    if (id == null) return null;
    return children.where((c) => c.id == id).firstOrNull;
  }

  Future<void> selectChild(String childId) async {
    if (childId == backendChildId) return;
    isSwitchingChild = true;
    notifyListeners();

    try {
      backendChildId = childId;

      final child = children.where((c) => c.id == childId).firstOrNull;
      if (child != null) {
        profile = profile.copyWith(
          name: child.name,
          gradeLabel: child.gradeLabel,
        );
        _syncLocaleFromLanguage(child.preferredLanguage);
      }

      // Clear session state
      quizSession = null;
      flashcardsPayload = null;
      matchingPayload = null;
      gamePayloads = {};
      gameIds = {};
      selectedPackId = null;
      currentGameType = null;
      currentGameTitle = null;
      currentGameId = null;
      lastGameOutcome = null;
      lastResultSyncError = null;
      inPackSession = false;
      packSessionStage = null;
      packGameQueue = [];
      packGameIndex = 0;
      revisionSession = null;
      activeQuizSessionData = null;
      homeRecommendations = [];

      await _hydrateFromBackend();
      await _refreshReviewCount();
      await refreshActivitiesFromBackend();
      await _refreshMemoryPreferences();
      await _refreshHomeRecommendations();
    } finally {
      isSwitchingChild = false;
      notifyListeners();
    }
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
        await _hydrateFromBackend();
        await _refreshReviewCount();
        await refreshActivitiesFromBackend();
        await _refreshMemoryPreferences();
        await _refreshHomeRecommendations();
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

  List<DailyLearningTime> _emptyLearningTimes() {
    return const [
      DailyLearningTime(dayLabel: 'Mon', minutes: 0),
      DailyLearningTime(dayLabel: 'Tue', minutes: 0),
      DailyLearningTime(dayLabel: 'Wed', minutes: 0),
      DailyLearningTime(dayLabel: 'Thu', minutes: 0),
      DailyLearningTime(dayLabel: 'Fri', minutes: 0),
      DailyLearningTime(dayLabel: 'Sat', minutes: 0),
      DailyLearningTime(dayLabel: 'Sun', minutes: 0),
    ];
  }

  Future<void> prepareQuizSetup({String? packId}) async {
    final id =
        packId ?? selectedPackId ?? (packs.isNotEmpty ? packs.first.id : null);
    if (id == null) {
      return;
    }
    selectedPackId = id;
    currentGameType = 'quiz';
    currentGameTitle = 'Quiz';
    currentGameId = null;
    lastGameOutcome = null;
    lastResultSyncError = null;
    activeQuizSessionData = null;

    if (!gamePayloads.containsKey('quiz')) {
      await _loadReadyGamesForPack(id);
    }

    final payload = gamePayloads['quiz'];
    currentGameId = gameIds['quiz'];
    currentGameTitle = payload?['title']?.toString() ?? currentGameTitle;

    await _refreshActiveQuizSession();
    notifyListeners();
  }

  Future<bool> startQuizFromSetup({
    required int questionCount,
    String? packId,
  }) async {
    await prepareQuizSetup(packId: packId);

    final childId = backendChildId;
    final resolvedPackId = selectedPackId;
    final gameId = currentGameId;
    if (childId == null || resolvedPackId == null || gameId == null) {
      return false;
    }

    try {
      final payload = await backend.createQuizSession(
        childId: childId,
        packId: resolvedPackId,
        gameId: gameId,
        questionCount: questionCount,
      );
      final data = payload['data'];
      if (data is! Map<String, dynamic>) {
        return false;
      }
      activeQuizSessionData = data;
      return _hydrateQuizSessionFromBackend(data);
    } catch (error) {
      lastResultSyncError = error.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> resumeQuizFromSetup({String? packId}) async {
    await prepareQuizSetup(packId: packId);
    final data = activeQuizSessionData;
    if (data == null) {
      return false;
    }
    return _hydrateQuizSessionFromBackend(data);
  }

  Future<void> startQuiz({String? packId}) async {
    if ((currentGameType ?? 'quiz') == 'quiz') {
      final resumed = await resumeQuizFromSetup(packId: packId);
      if (resumed) {
        return;
      }
      await startQuizFromSetup(questionCount: 10, packId: packId);
      return;
    }

    final id =
        packId ?? selectedPackId ?? (packs.isNotEmpty ? packs.first.id : null);
    if (id == null) {
      return;
    }
    selectedPackId = id;
    lastResultSyncError = null;

    if (!gamePayloads.containsKey(currentGameType)) {
      await _loadReadyGamesForPack(id);
    }

    final payload = currentGameType == null
        ? null
        : gamePayloads[currentGameType!];
    if (payload != null && currentGameType != null) {
      _loadQuizFromPayload({
        'type': currentGameType,
        'payload': payload,
        '_id': gameIds[currentGameType],
        'learning_pack_id': id,
      });
    } else {
      quizSession = QuizSession(packId: id, questions: const []);
    }
    notifyListeners();
  }

  bool get hasActiveQuizSession => activeQuizSessionData != null;

  int get activeQuizRemainingCount {
    final data = activeQuizSessionData;
    if (data == null) {
      return 0;
    }
    final requested = (data['requested_question_count'] as num?)?.toInt() ?? 0;
    final current = (data['current_index'] as num?)?.toInt() ?? 0;
    return max(0, requested - current);
  }

  Future<void> _refreshActiveQuizSession() async {
    final childId = backendChildId;
    final gameId = currentGameId;
    final packId = selectedPackId;
    if (childId == null || gameId == null || packId == null) {
      activeQuizSessionData = null;
      return;
    }

    try {
      final session = await backend.fetchActiveQuizSession(childId: childId);
      if (session == null) {
        activeQuizSessionData = null;
        return;
      }

      final sessionGameId = session['game_id']?.toString();
      final sessionPackId = session['learning_pack_id']?.toString();
      final status = session['status']?.toString() ?? '';
      final resumable =
          (status == 'active' || status == 'paused') &&
          sessionGameId == gameId &&
          sessionPackId == packId;
      activeQuizSessionData = resumable ? session : null;
    } catch (_) {
      activeQuizSessionData = null;
    }
  }

  bool _hydrateQuizSessionFromBackend(Map<String, dynamic> data) {
    final payload = gamePayloads['quiz'];
    final gameId = currentGameId;
    final packId = selectedPackId;
    if (payload == null || gameId == null || packId == null) {
      return false;
    }

    final sessionId = data['id']?.toString();
    final questionIndices = (data['question_indices'] as List<dynamic>? ?? [])
        .map((item) => (item as num?)?.toInt())
        .whereType<int>()
        .toList();
    final requestedCount =
        (data['requested_question_count'] as num?)?.toInt() ??
        questionIndices.length;
    final currentIndex = (data['current_index'] as num?)?.toInt() ?? 0;
    final correctCount = (data['correct_count'] as num?)?.toInt() ?? 0;
    final results = (data['results'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();

    _loadQuizFromPayload(
      {
        'type': 'quiz',
        'payload': payload,
        '_id': gameId,
        'learning_pack_id': packId,
      },
      includeQuestionIndices: questionIndices,
      backendSessionId: sessionId,
      requestedQuestionCount: requestedCount,
      startIndex: currentIndex,
      correctCount: correctCount,
      previousResults: results,
    );

    notifyListeners();
    return true;
  }

  Future<void> startPackSession({String? packId}) async {
    inPackSession = true;
    packSessionStage = PackSessionStage.flashcards;
    final id =
        packId ?? selectedPackId ?? (packs.isNotEmpty ? packs.first.id : null);
    if (id != null) {
      selectedPackId = id;
    }
    if (id != null) {
      await _loadReadyGamesForPack(id);
    }
    notifyListeners();
  }

  Future<String?> startReviewFromDueConcepts() async {
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

    await startPackSession(packId: targetPack.id);
    final firstType = currentPackGameType;
    if (firstType == null) {
      return null;
    }
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

  Future<bool> startRevision({String? packId}) async {
    final id =
        packId ?? selectedPackId ?? (packs.isNotEmpty ? packs.first.id : null);
    if (id == null) {
      return false;
    }
    selectedPackId = id;
    _revisionSubmissionPayload = [];
    revisionSession = null;
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
          return true;
        }
      }
    } catch (_) {}
    return false;
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
            selectionReason: item['selection_reason']?.toString(),
            confidence: (item['confidence'] as num?)?.toDouble(),
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
      await _refreshHomeRecommendations();
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
      generationError = 'No image selected.';
      generationStatus = 'Generation failed';
      notifyListeners();
      return;
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
    String? title,
    String? subject,
    String? language,
    String? learningGoal,
    String? contextText,
  }) {
    pendingTitle = title;
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
    Uint8List? imageBytes,
    String? imageFilename,
    String? imageMimeType,
  }) async {
    try {
      final session = await _ensureBackendSession();
      final payload = await backend.suggestDocumentMetadata(
        childId: session.childId,
        filename: filename,
        contextText: contextText,
        languageHint: languageHint,
        imageBytes: imageBytes,
        imageFilename: imageFilename,
        imageMimeType: imageMimeType,
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
    uploadProgressPercent = 5;
    processingProgressPercent = 0;
    processingStageLabel = 'Uploading';
    pipelineStage = 'uploading';
    hasFirstPlayableSignal = false;
    awaitingScanValidation = false;
    scanSuggestedTopic = null;
    scanSuggestedLanguage = null;
    scanSuggestionConfidence = 0.0;
    scanSuggestionAlternatives = [];
    scanSuggestionModel = null;
    notifyListeners();

    try {
      final session = await _ensureBackendSession();
      final document = await backend.uploadDocument(
        childId: session.childId,
        bytes: bytes,
        filename: filename,
        title: pendingTitle,
        subject: pendingSubject,
        language: pendingLanguage,
        gradeLevel: BackendConfig.childGrade,
        learningGoal: pendingLearningGoal,
        contextText: pendingContextText,
        requestedGameTypes: pendingGameTypes,
      );
      lastDocumentId = _extractId(document);

      generationStatus = 'Analyzing document before generation...';
      uploadProgressPercent = 100;
      processingProgressPercent = 10;
      processingStageLabel = 'Quick Scan Queue';
      pipelineStage = 'quick_scan_queued';
      notifyListeners();

      await _pollForPackAndQuiz(session.childId, lastDocumentId);
      if (awaitingScanValidation) {
        generationStatus = 'Review topic and language before continuing.';
        return;
      }
      generationStatus = 'Quiz ready!';
      processingProgressPercent = 100;
      processingStageLabel = 'Ready';
      pipelineStage = 'ready';
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
    uploadProgressPercent = 5;
    processingProgressPercent = 0;
    processingStageLabel = 'Uploading';
    pipelineStage = 'uploading';
    hasFirstPlayableSignal = false;
    awaitingScanValidation = false;
    scanSuggestedTopic = null;
    scanSuggestedLanguage = null;
    scanSuggestionConfidence = 0.0;
    scanSuggestionAlternatives = [];
    scanSuggestionModel = null;
    notifyListeners();

    try {
      final session = await _ensureBackendSession();
      final document = await backend.uploadDocumentBatch(
        childId: session.childId,
        files: images,
        filenames: filenames,
        title: pendingTitle,
        subject: pendingSubject,
        language: pendingLanguage,
        gradeLevel: BackendConfig.childGrade,
        learningGoal: pendingLearningGoal,
        contextText: pendingContextText,
        requestedGameTypes: pendingGameTypes,
      );
      lastDocumentId = _extractId(document);

      generationStatus = 'Analyzing document before generation...';
      uploadProgressPercent = 100;
      processingProgressPercent = 10;
      processingStageLabel = 'Quick Scan Queue';
      pipelineStage = 'quick_scan_queued';
      notifyListeners();

      await _pollForPackAndQuiz(session.childId, lastDocumentId);
      if (awaitingScanValidation) {
        generationStatus = 'Review topic and language before continuing.';
        return;
      }
      generationStatus = 'Quiz ready!';
      processingProgressPercent = 100;
      processingStageLabel = 'Ready';
      pipelineStage = 'ready';
    } catch (error) {
      generationError = error.toString();
      generationStatus = 'Generation failed';
    } finally {
      isGeneratingQuiz = false;
      pendingSubject = null;
      pendingTitle = null;
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
        final payload = await backend.login(
          email: _demoEmail,
          password: _demoPassword,
        );
        _syncProfileFromAuthPayload(payload);
      } catch (error) {
        try {
          final payload = await backend.register(
            name: BackendConfig.demoName,
            email: _demoEmail,
            password: _demoPassword,
          );
          _syncProfileFromAuthPayload(payload);
        } catch (registerError) {
          if (_isEmailTaken(registerError)) {
            final payload = await backend.login(
              email: _demoEmail,
              password: _demoPassword,
            );
            _syncProfileFromAuthPayload(payload);
          } else {
            rethrow;
          }
        }
      }
    }

    if (backendChildId == null) {
      final backendChildren = await backend.listChildren();
      children = backendChildren
          .whereType<Map<String, dynamic>>()
          .map(_mapChildProfile)
          .whereType<ChildProfile>()
          .toList();

      final selectedChild = backendChildren
          .whereType<Map<String, dynamic>>()
          .firstWhere(
            (child) => child['name']?.toString() == BackendConfig.childName,
            orElse: () => backendChildren.isNotEmpty
                ? backendChildren.first as Map<String, dynamic>
                : <String, dynamic>{},
          );
      backendChildId = _extractId(selectedChild);
      _syncGamificationFromBackendChild(selectedChild);
      _syncLocaleFromLanguage(selectedChild['preferred_language']?.toString());

      if (backendChildId == null) {
        final created = await backend.createChild(
          name: BackendConfig.childName,
          gradeLevel: BackendConfig.childGrade,
        );
        backendChildId = _extractId(created);
        _syncGamificationFromBackendChild(created);
        if (backendChildId == null && children.isEmpty) {
          final refreshed = await backend.listChildren();
          children = refreshed
              .whereType<Map<String, dynamic>>()
              .map(_mapChildProfile)
              .whereType<ChildProfile>()
              .toList();
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

  Future<void> _hydrateFromBackend() async {
    final childId = backendChildId;
    if (childId == null) {
      return;
    }

    try {
      final rawDocuments = await backend.listDocuments(childId: childId);
      documents = rawDocuments
          .whereType<Map<String, dynamic>>()
          .map(_mapDocumentItem)
          .toList();
      _docCounter = documents.length;
    } catch (_) {
      documents = const [];
    }

    try {
      final payload = await backend.listActivities(
        childId: childId,
        page: 1,
        perPage: _activityPerPage,
      );
      final rawActivities = payload['data'] as List<dynamic>? ?? [];
      activities = rawActivities
          .whereType<Map<String, dynamic>>()
          .map(ActivityItem.fromJson)
          .toList();
      final meta = payload['meta'] as Map<String, dynamic>? ?? const {};
      hasMoreActivities = (meta['has_more'] as bool?) ?? false;
      _activityPage = 1;
    } catch (_) {
      activities = const [];
      hasMoreActivities = false;
      _activityPage = 1;
    }

    try {
      final rawAssessments = await backend.listSchoolAssessments(
        childId: childId,
      );
      schoolAssessments = (rawAssessments.whereType<Map<String, dynamic>>())
          .map(SchoolAssessment.fromJson)
          .toList();
    } catch (_) {
      schoolAssessments = const [];
    }

    try {
      final rawPacks = await backend.listLearningPacks(childId: childId);
      packs = rawPacks
          .whereType<Map<String, dynamic>>()
          .map(_learningPackFromBackend)
          .whereType<LearningPack>()
          .toList();
      if (packs.isNotEmpty &&
          (selectedPackId == null ||
              !packs.any((pack) => pack.id == selectedPackId))) {
        selectedPackId = packs.first.id;
      }
      mastery = {
        for (final pack in packs)
          if (pack.title.isNotEmpty) pack.title: pack.progress,
      };
    } catch (_) {
      packs = const [];
      mastery = const {};
      selectedPackId = null;
    }

    weeklySummary = WeeklySummary(
      minutesSpent: xpToday,
      newBadges: achievements.where((item) => item.isUnlocked).length,
      sessionsCompleted: streakDays,
      topSubject: packs.isNotEmpty ? packs.first.subject : 'N/A',
    );
    notifyListeners();
  }

  Future<void> refreshSchoolAssessments() async {
    final childId = backendChildId;
    if (childId == null) return;
    try {
      final raw = await backend.listSchoolAssessments(childId: childId);
      schoolAssessments = (raw.whereType<Map<String, dynamic>>())
          .map(SchoolAssessment.fromJson)
          .toList();
    } catch (_) {
      schoolAssessments = const [];
    }
    notifyListeners();
  }

  Future<SchoolAssessment?> addSchoolAssessment({
    required String subject,
    required String assessmentType,
    required double score,
    required double maxScore,
    required String assessedAt,
    String? grade,
    String? teacherNote,
  }) async {
    final childId = backendChildId;
    if (childId == null) return null;
    final data = await backend.createSchoolAssessment(
      childId: childId,
      subject: subject,
      assessmentType: assessmentType,
      score: score,
      maxScore: maxScore,
      assessedAt: assessedAt,
      grade: grade,
      teacherNote: teacherNote,
    );
    final assessment = SchoolAssessment.fromJson(data);
    schoolAssessments = [assessment, ...schoolAssessments];
    notifyListeners();
    return assessment;
  }

  Future<void> removeSchoolAssessment(String assessmentId) async {
    final childId = backendChildId;
    if (childId == null) return;
    await backend.deleteSchoolAssessment(
      childId: childId,
      assessmentId: assessmentId,
    );
    schoolAssessments = schoolAssessments
        .where((a) => a.id != assessmentId)
        .toList();
    notifyListeners();
  }

  Future<void> _loadReadyGamesForPack(String packId) async {
    final childId = backendChildId;
    if (childId == null) {
      return;
    }

    try {
      final games = await backend.listGames(childId: childId, packId: packId);
      _setGamePayloadsFromBackendList(games.cast<Map<String, dynamic>>());
    } catch (_) {}
  }

  void _setGamePayloadsFromBackendList(List<Map<String, dynamic>> games) {
    final payloadsByType = <String, Map<String, dynamic>>{};
    final idsByType = <String, String>{};
    for (final entry in games) {
      final status = entry['status']?.toString();
      final type = entry['type']?.toString();
      final payload = entry['payload'];
      final id = _extractId(entry);
      if (status == 'ready' &&
          type != null &&
          payload is Map<String, dynamic>) {
        payloadsByType[type] = payload;
        if (id != null) {
          idsByType[type] = id;
        }
      }
    }
    gamePayloads = payloadsByType;
    gameIds = idsByType;
    flashcardsPayload = payloadsByType['flashcards'];
    matchingPayload = payloadsByType['matching'];
    _setPackGameQueue(payloadsByType.keys.toList());
  }

  void _syncProfileFromAuthPayload(Map<String, dynamic> payload) {
    final rawUser = payload['user'];
    if (rawUser is! Map<String, dynamic>) {
      return;
    }

    final userId =
        _extractId(rawUser) ?? rawUser['id']?.toString() ?? profile.id;
    final name = rawUser['name']?.toString();
    final email = rawUser['email']?.toString();

    profile = profile.copyWith(
      id: userId,
      name: (name == null || name.isEmpty) ? profile.name : name,
      gradeLabel: BackendConfig.childGrade,
      planName: currentPlan,
    );
    parentProfile = ParentProfile(
      name: (name == null || name.isEmpty) ? parentProfile.name : name,
      email: email ?? parentProfile.email,
    );
    notifyListeners();
  }

  ChildProfile? _mapChildProfile(Map<String, dynamic> child) {
    return ChildProfile.fromJson(child);
  }

  DocumentItem _mapDocumentItem(Map<String, dynamic> doc) {
    final id = _extractId(doc) ?? '';
    final title = doc['title']?.toString() ?? doc['original_filename']?.toString() ?? 'Document';
    final subject = doc['subject']?.toString() ?? 'General';
    final language = doc['language']?.toString();
    final status = doc['status']?.toString() ?? 'unknown';
    final stage = doc['pipeline_stage']?.toString();
    final createdAt =
        DateTime.tryParse(doc['created_at']?.toString() ?? '') ??
        DateTime.now();
    return DocumentItem(
      id: id,
      title: title,
      subject: subject,
      language: language,
      createdAt: createdAt,
      statusLabel: _statusLabelForDocument(status, stage: stage),
    );
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
      final docStage = doc['pipeline_stage']?.toString();
      final progressHint = (doc['progress_hint'] as num?)?.toInt();
      final scanStatus = doc['scan_status']?.toString();
      final validationStatus = doc['validation_status']?.toString();
      final firstPlayableGameType = doc['first_playable_game_type']?.toString();
      final readyGameTypesRaw = doc['ready_game_types'] as List<dynamic>? ?? [];
      final hasFirstPlayable =
          (firstPlayableGameType != null && firstPlayableGameType.isNotEmpty) ||
          readyGameTypesRaw.isNotEmpty;
      hasFirstPlayableSignal = hasFirstPlayable;
      pipelineStage = docStage ?? status;
      if (progressHint != null) {
        processingProgressPercent = min(100, max(0, progressHint));
      }
      processingStageLabel = _shortStageLabel(
        pipelineStage: docStage,
        status: status,
        hasFirstPlayableSignal: hasFirstPlayable,
      );

      // Update status message based on document status
      final stageMessage = _generationStatusForStage(
        pipelineStage: docStage,
        status: status,
        progressHint: progressHint,
        hasFirstPlayableSignal: hasFirstPlayable,
      );
      if (stageMessage != null) {
        generationStatus = stageMessage;
        notifyListeners();
      }

      final shouldAwaitValidation =
          docStage == 'awaiting_validation' ||
          docStage == 'quick_scan_failed' ||
          (validationStatus == 'pending' && scanStatus == 'ready');
      if (shouldAwaitValidation) {
        awaitingScanValidation = true;
        scanSuggestedTopic =
            doc['scan_topic_suggestion']?.toString() ??
            doc['subject']?.toString() ??
            pendingSubject;
        scanSuggestedLanguage =
            doc['scan_language_suggestion']?.toString() ??
            doc['language']?.toString() ??
            pendingLanguage;
        scanSuggestionConfidence =
            (doc['scan_confidence'] as num?)?.toDouble() ?? 0.0;
        scanSuggestionAlternatives =
            (doc['scan_alternatives'] as List<dynamic>? ?? [])
                .map((value) => value.toString())
                .where((value) => value.isNotEmpty)
                .toList();
        scanSuggestionModel = doc['scan_model']?.toString();
        processingStageLabel = 'Awaiting Validation';
        generationStatus = scanStatus == 'failed'
            ? 'Scan failed. Enter topic/language manually and confirm.'
            : 'Validate topic and language to continue.';
        notifyListeners();
        return;
      }

      awaitingScanValidation = false;

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
          _setGamePayloadsFromBackendList(
            games.whereType<Map<String, dynamic>>().toList(),
          );

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

  Future<bool> confirmCurrentDocumentScan({
    required String topic,
    required String language,
  }) async {
    final documentId = lastDocumentId;
    if (documentId == null) {
      generationError = 'Missing document ID for scan confirmation.';
      notifyListeners();
      return false;
    }

    isGeneratingQuiz = true;
    generationError = null;
    generationStatus = 'Starting deep analysis...';
    processingStageLabel = 'Queued';
    pipelineStage = 'queued';
    processingProgressPercent = max(processingProgressPercent, 35);
    awaitingScanValidation = false;
    notifyListeners();

    try {
      final session = await _ensureBackendSession();
      await backend.confirmDocumentScan(
        childId: session.childId,
        documentId: documentId,
        topic: topic,
        language: language,
      );

      await _pollForPackAndQuiz(session.childId, documentId);
      if (awaitingScanValidation) {
        isGeneratingQuiz = false;
        notifyListeners();
        return false;
      }

      generationStatus = 'Quiz ready!';
      processingProgressPercent = 100;
      processingStageLabel = 'Ready';
      pipelineStage = 'ready';
      isGeneratingQuiz = false;
      notifyListeners();
      return true;
    } catch (error) {
      generationError = error.toString();
      generationStatus = 'Generation failed';
      isGeneratingQuiz = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> rescanCurrentDocument() async {
    final documentId = lastDocumentId;
    if (documentId == null) {
      generationError = 'Missing document ID for rescan.';
      notifyListeners();
      return false;
    }

    isGeneratingQuiz = true;
    generationError = null;
    generationStatus = 'Re-running quick scan...';
    processingStageLabel = 'Quick Scan Queue';
    pipelineStage = 'quick_scan_queued';
    processingProgressPercent = 10;
    awaitingScanValidation = false;
    notifyListeners();

    try {
      final session = await _ensureBackendSession();
      await backend.rescanDocument(
        childId: session.childId,
        documentId: documentId,
      );
      await _pollForPackAndQuiz(session.childId, documentId);
      isGeneratingQuiz = false;
      notifyListeners();
      return true;
    } catch (error) {
      generationError = error.toString();
      generationStatus = 'Quick scan failed';
      isGeneratingQuiz = false;
      notifyListeners();
      return false;
    }
  }

  String? _generationStatusForStage({
    required String? pipelineStage,
    required String? status,
    required int? progressHint,
    required bool hasFirstPlayableSignal,
  }) {
    final prefix = progressHint == null ? '' : '$progressHint% • ';
    if (hasFirstPlayableSignal &&
        pipelineStage != 'ready' &&
        pipelineStage != 'game_generation_failed') {
      return '${prefix}First game is ready. Finishing remaining games...';
    }

    return switch (pipelineStage) {
      'quick_scan_queued' => '${prefix}Preparing quick scan...',
      'quick_scan_processing' => '${prefix}Scanning topic and language...',
      'awaiting_validation' => '${prefix}Review AI topic/language suggestions.',
      'queued' => '${prefix}Waiting in queue...',
      'ocr' => '${prefix}Reading your document...',
      'concept_extraction_queued' => '${prefix}Preparing concepts...',
      'concept_extraction' => '${prefix}Extracting key concepts...',
      'learning_pack_queued' => '${prefix}Preparing learning pack...',
      'learning_pack_generation' => '${prefix}Building learning pack...',
      'game_generation_queued' => '${prefix}Preparing games...',
      'game_generation' => '${prefix}Generating games and quizzes...',
      'ready' => '100% • Quiz ready!',
      'quick_scan_failed' =>
        'Quick scan failed. Please rescan or edit manually.',
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

  String _shortStageLabel({
    required String? pipelineStage,
    required String? status,
    required bool hasFirstPlayableSignal,
  }) {
    if (hasFirstPlayableSignal &&
        pipelineStage != 'ready' &&
        pipelineStage != 'game_generation_failed') {
      return 'First Game Ready';
    }

    return switch (pipelineStage) {
      'quick_scan_queued' => 'Quick Scan Queue',
      'quick_scan_processing' => 'Quick Scan',
      'awaiting_validation' => 'Awaiting Validation',
      'queued' => 'Queued',
      'ocr' => 'OCR',
      'concept_extraction_queued' => 'Concept Queue',
      'concept_extraction' => 'Concept Extraction',
      'learning_pack_queued' => 'Pack Queue',
      'learning_pack_generation' => 'Pack Generation',
      'game_generation_queued' => 'Game Queue',
      'game_generation' => 'Game Generation',
      'ready' => 'Ready',
      'quick_scan_failed' => 'Quick Scan Failed',
      'ocr_failed' => 'OCR Failed',
      'concept_extraction_failed' => 'Concept Failed',
      'learning_pack_failed' => 'Pack Failed',
      'game_generation_failed' => 'Game Failed',
      _ => switch (status) {
        'queued' => 'Queued',
        'processing' => 'Processing',
        'processed' => 'Processed',
        'ready' => 'Ready',
        _ => 'Processing',
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
      packs = data
          .whereType<Map<String, dynamic>>()
          .map(_learningPackFromBackend)
          .whereType<LearningPack>()
          .toList();
      mastery = {
        for (final pack in packs)
          if (pack.title.isNotEmpty) pack.title: pack.progress,
      };
      if (packs.isEmpty) {
        selectedPackId = null;
      } else if (!packs.any((pack) => pack.id == selectedPackId)) {
        selectedPackId = packs.first.id;
      }
      notifyListeners();
    } catch (_) {
      // Ignore transient refresh failures.
    }
  }

  void _loadQuizFromPayload(
    Map<String, dynamic> game, {
    List<int>? includeQuestionIndices,
    String? backendSessionId,
    int? requestedQuestionCount,
    int? startIndex,
    int? correctCount,
    List<Map<String, dynamic>>? previousResults,
  }) {
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
      final filteredIndices = includeQuestionIndices
          ?.where((index) => index >= 0 && index < questions.length)
          .toSet();
      for (final entry in questions.asMap().entries) {
        final index = entry.key;
        final item = entry.value;
        if (filteredIndices != null && !filteredIndices.contains(index)) {
          continue;
        }
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

    final normalizedIndices = includeQuestionIndices == null
        ? List<int>.generate(mapped.length, (index) => index)
        : includeQuestionIndices
              .where((index) => index >= 0)
              .toList(growable: false);

    quizSession = QuizSession(
      packId: packId,
      questions: mapped,
      backendSessionId: backendSessionId,
      questionIndices: normalizedIndices,
      requestedQuestionCount: requestedQuestionCount,
    );

    final session = quizSession!;
    final restoredResults = (previousResults ?? <Map<String, dynamic>>[])
        .map((entry) => Map<String, dynamic>.from(entry))
        .toList();
    session.results = restoredResults;
    session.incorrectIndices = <int>[];
    for (var i = 0; i < restoredResults.length; i += 1) {
      final correct = restoredResults[i]['correct'] == true;
      if (!correct) {
        session.incorrectIndices.add(i);
      }
    }
    session.correctCount = max(0, correctCount ?? 0);
    final resolvedIndex = max(startIndex ?? 0, restoredResults.length);
    session.currentIndex = resolvedIndex.clamp(0, mapped.length).toInt();
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

    if (type == 'quiz') {
      quizSession = null;
      activeQuizSessionData = null;
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
    quizSession = QuizSession(
      packId: selectedPackId ?? '',
      questions: const [],
    );
    notifyListeners();
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
    if (type == 'quiz') {
      return AppRoutes.quizSetup;
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
    packGameQueue = ordered;
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

  Future<void> _syncQuizSessionProgress({String status = 'active'}) async {
    final childId = backendChildId;
    final session = quizSession;
    final backendSessionId = session?.backendSessionId;
    if (childId == null || session == null || backendSessionId == null) {
      return;
    }

    try {
      final payload = await backend.updateQuizSession(
        childId: childId,
        sessionId: backendSessionId,
        currentIndex: session.currentIndex,
        correctCount: session.correctCount,
        results: List<Map<String, dynamic>>.from(session.results),
        status: status,
      );
      final data = payload['data'];
      if (data is Map<String, dynamic>) {
        if (status == 'completed' || status == 'abandoned') {
          activeQuizSessionData = null;
        } else {
          activeQuizSessionData = data;
        }
      }
    } catch (error) {
      lastResultSyncError = error.toString();
    }
  }

  Future<void> saveAndExitQuiz() async {
    await _syncQuizSessionProgress(status: 'paused');
    quizSession = null;
    notifyListeners();
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
      await _syncQuizSessionProgress(status: 'completed');
    } else {
      await _syncQuizSessionProgress(status: 'active');
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
      await _syncQuizSessionProgress(status: 'completed');
    } else {
      await _syncQuizSessionProgress(status: 'active');
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
      await _syncQuizSessionProgress(status: 'completed');
    } else {
      await _syncQuizSessionProgress(status: 'active');
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
      await _syncQuizSessionProgress(status: 'completed');
    } else {
      await _syncQuizSessionProgress(status: 'active');
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
        await refreshActivitiesFromBackend();
        return;
      } catch (error) {
        lastError = error;
        if (attempt == 0) {
          await Future.delayed(_submitRetryDelay);
        }
      }
    }

    lastResultSyncError = lastError.toString();
    debugPrint('Game result submission failed: $lastError');
    notifyListeners();
    await _refreshReviewCount();
    await refreshActivitiesFromBackend();
    await _refreshHomeRecommendations();
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
      } else {
        reviewDueCount = 0;
        reviewDueConceptKeys = [];
        notifyListeners();
      }
    } catch (_) {
      // Ignore transient refresh failures.
    }
  }

  Future<void> _refreshHomeRecommendations() async {
    final childId = backendChildId;
    if (childId == null) {
      return;
    }

    try {
      final data = await backend.fetchHomeRecommendations(childId: childId);
      homeRecommendations = data == null
          ? []
          : data
                .whereType<Map<String, dynamic>>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList();
      notifyListeners();
    } catch (_) {
      // Ignore transient refresh failures.
    }
  }

  Future<void> _refreshMemoryPreferences() async {
    final childId = backendChildId;
    if (childId == null) {
      return;
    }

    try {
      final data = await backend.fetchMemoryPreferences(childId: childId);
      if (data == null) {
        return;
      }
      _syncMemoryPreferencesFromBackend(data);
      notifyListeners();
    } catch (_) {
      // Ignore transient refresh failures.
    }
  }

  void _syncMemoryPreferencesFromBackend(Map<String, dynamic> data) {
    memoryPersonalizationEnabled =
        (data['memory_personalization_enabled'] as bool?) ?? true;
    recommendationWhyEnabled =
        (data['recommendation_why_enabled'] as bool?) ?? true;
    recommendationWhyLevel =
        data['recommendation_why_level']?.toString() ?? 'detailed';
    lastMemoryResetScope = data['last_memory_reset_scope']?.toString();
    final rawResetAt = data['last_memory_reset_at']?.toString();
    lastMemoryResetAt = rawResetAt == null
        ? null
        : DateTime.tryParse(rawResetAt);
  }

  Future<void> updateMemoryPreferences({
    bool? memoryPersonalizationEnabled,
    bool? recommendationWhyEnabled,
    String? recommendationWhyLevel,
  }) async {
    final childId = backendChildId;
    if (childId == null) {
      return;
    }

    memorySettingsBusy = true;
    memorySettingsError = null;
    notifyListeners();
    try {
      final data = await backend.updateMemoryPreferences(
        childId: childId,
        memoryPersonalizationEnabled: memoryPersonalizationEnabled,
        recommendationWhyEnabled: recommendationWhyEnabled,
        recommendationWhyLevel: recommendationWhyLevel,
      );
      _syncMemoryPreferencesFromBackend(data);
      await _refreshHomeRecommendations();
    } catch (error) {
      memorySettingsError = error.toString();
    } finally {
      memorySettingsBusy = false;
      notifyListeners();
    }
  }

  Future<bool> clearMemoryScope(String scope) async {
    final childId = backendChildId;
    if (childId == null) {
      return false;
    }

    memorySettingsBusy = true;
    memorySettingsError = null;
    notifyListeners();

    try {
      final payload = await backend.clearMemoryScope(
        childId: childId,
        scope: scope,
      );
      final preferences = payload['preferences'];
      if (preferences is Map<String, dynamic>) {
        _syncMemoryPreferencesFromBackend(preferences);
      } else {
        lastMemoryResetScope = scope;
        lastMemoryResetAt = DateTime.now().toUtc();
      }
      final childSummary = payload['child_summary'];
      if (childSummary is Map<String, dynamic>) {
        _syncGamificationFromBackendChild(childSummary);
      }
      await _refreshReviewCount();
      await refreshActivitiesFromBackend();
      await _refreshPacksFromBackend();
      await _refreshHomeRecommendations();
      return true;
    } catch (error) {
      memorySettingsError = error.toString();
      return false;
    } finally {
      memorySettingsBusy = false;
      notifyListeners();
    }
  }

  Future<String> runRecommendationAction(
    Map<String, dynamic> recommendation,
  ) async {
    final action = recommendation['action']?.toString() ?? 'start_learning';
    await _trackRecommendationEvent(recommendation, event: 'tap');

    switch (action) {
      case 'start_revision':
        return AppRoutes.revisionSetup;
      case 'start_streak_rescue':
        final rescueRoute = await startReviewFromDueConcepts();
        return rescueRoute ?? AppRoutes.revisionSetup;
      case 'resume_recent_upload':
        final payload = recommendation['action_payload'];
        final documentId = payload is Map
            ? payload['document_id']?.toString()
            : null;
        final route = await _startLearningFromDocument(documentId);
        return route ?? AppRoutes.cameraCapture;
      case 'start_learning':
      default:
        return AppRoutes.cameraCapture;
    }
  }

  Future<String?> _startLearningFromDocument(String? documentId) async {
    final childId = backendChildId;
    if (childId == null || documentId == null || documentId.isEmpty) {
      return null;
    }

    try {
      final packsData = await backend.listLearningPacks(
        childId: childId,
        documentId: documentId,
      );
      if (packsData.isEmpty) {
        return null;
      }
      final firstPack = packsData.first as Map<String, dynamic>;
      final packId = _extractId(firstPack);
      if (packId == null || packId.isEmpty) {
        return null;
      }
      _syncPackFromBackend(firstPack, selectPack: true);
      await _loadReadyGamesForPack(packId);
      final gameType = currentPackGameType;
      if (gameType == null) {
        return null;
      }
      startGameType(gameType);
      return routeForGameType(gameType);
    } catch (_) {
      return null;
    }
  }

  Future<void> _trackRecommendationEvent(
    Map<String, dynamic> recommendation, {
    String event = 'tap',
  }) async {
    final childId = backendChildId;
    if (childId == null) {
      return;
    }

    try {
      await backend.trackRecommendationEvent(
        childId: childId,
        recommendationId: recommendation['id']?.toString() ?? 'unknown',
        recommendationType: recommendation['type']?.toString() ?? 'unknown',
        action: recommendation['action']?.toString() ?? 'unknown',
        event: event,
      );
    } catch (_) {
      // Ignore telemetry failures.
    }
  }

  Future<void> refreshActivitiesFromBackend() async {
    final childId = backendChildId;
    if (childId == null) {
      activities = const [];
      hasMoreActivities = false;
      _activityPage = 1;
      return;
    }

    isSyncingActivities = true;
    activitySyncError = null;
    notifyListeners();

    try {
      final payload = await backend.listActivities(
        childId: childId,
        page: 1,
        perPage: _activityPerPage,
      );
      final data = payload['data'] as List<dynamic>? ?? [];
      activities = data
          .whereType<Map<String, dynamic>>()
          .map(ActivityItem.fromJson)
          .toList();
      final meta = payload['meta'] as Map<String, dynamic>? ?? const {};
      hasMoreActivities = (meta['has_more'] as bool?) ?? false;
      _activityPage = 1;
    } catch (error) {
      activitySyncError = error.toString();
    } finally {
      isSyncingActivities = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreActivitiesFromBackend() async {
    final childId = backendChildId;
    if (childId == null || isSyncingActivities || !hasMoreActivities) {
      return;
    }

    isSyncingActivities = true;
    activitySyncError = null;
    notifyListeners();

    try {
      final nextPage = _activityPage + 1;
      final payload = await backend.listActivities(
        childId: childId,
        page: nextPage,
        perPage: _activityPerPage,
      );
      final data = payload['data'] as List<dynamic>? ?? [];
      final nextItems = data
          .whereType<Map<String, dynamic>>()
          .map(ActivityItem.fromJson)
          .toList();

      activities = [...activities, ...nextItems];
      final meta = payload['meta'] as Map<String, dynamic>? ?? const {};
      hasMoreActivities = (meta['has_more'] as bool?) ?? false;
      _activityPage = nextPage;
    } catch (error) {
      activitySyncError = error.toString();
    } finally {
      isSyncingActivities = false;
      notifyListeners();
    }
  }

  void resetQuiz() {
    quizSession = null;
    activeQuizSessionData = null;
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
      documents = data
          .whereType<Map<String, dynamic>>()
          .map(_mapDocumentItem)
          .toList();
      _docCounter = documents.length;
    } catch (error) {
      documentSyncError = error.toString();
    } finally {
      isSyncingDocuments = false;
      notifyListeners();
    }
  }

  String _statusLabelForDocument(String status, {String? stage}) {
    if (stage == 'awaiting_validation') {
      return 'awaiting_validation';
    }
    if (stage == 'quick_scan_queued' || stage == 'quick_scan_processing') {
      return stage!;
    }
    if (stage == 'quick_scan_failed') {
      return 'quick_scan_failed';
    }
    return status;
  }

  Future<bool> regenerateDocument(
    String documentId, {
    List<String>? requestedGameTypes,
  }) async {
    try {
      final session = await _ensureBackendSession();
      await backend.regenerateDocument(
        childId: session.childId,
        documentId: documentId,
        requestedGameTypes: requestedGameTypes,
      );
      documents = documents
          .map(
            (doc) => doc.id == documentId
                ? doc.copyWith(statusLabel: 'Queued')
                : doc,
          )
          .toList();
      notifyListeners();
      await refreshDocumentsFromBackend();
      return true;
    } catch (error) {
      documentSyncError = error.toString();
      notifyListeners();
      return false;
    }
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
