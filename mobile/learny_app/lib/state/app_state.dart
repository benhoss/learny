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
import '../models/revision_session.dart';
import '../models/user_profile.dart';
import '../models/weak_area.dart';
import '../models/weekly_summary.dart';
import '../services/backend_client.dart';
import '../theme/app_theme.dart';

class AppState extends ChangeNotifier {
  AppState({FakeRepositories? repositories})
      : _repositories = repositories ?? FakeRepositories(),
        backend = BackendClient(baseUrl: BackendConfig.baseUrl) {
    _load();
    _initializeBackendSession();
  }

  final FakeRepositories _repositories;
  final BackendClient backend;

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
  List<String> packGameQueue = [];
  int packGameIndex = 0;
  String? currentGameType;
  String? currentGameTitle;

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

  int _docCounter = 0;

  bool notificationsEnabled = true;
  bool soundEnabled = true;
  bool remindersEnabled = true;

  final String _demoEmail = BackendConfig.demoEmail;
  final String _demoPassword = BackendConfig.demoPassword;
  bool _backendSessionReady = false;
  bool _backendSessionInitializing = false;

  void _load() {
    profile = _repositories.user.loadProfile();
    children = _repositories.user.loadChildren();
    packs = List<LearningPack>.from(_repositories.packs.loadPacks());
    achievements = _repositories.progress.loadAchievements();
    mastery = _repositories.progress.loadMastery();
    documents = List<DocumentItem>.from(_repositories.documents.loadDocuments());
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
    final id = packId ?? selectedPackId ?? (packs.isNotEmpty ? packs.first.id : null);
    if (id == null) {
      return;
    }
    selectedPackId = id;
    currentGameType = 'quiz';
    currentGameTitle = 'Quick Quiz';
    currentGameId = null;
    quizSession = QuizSession(
      packId: id,
      questions: _repositories.packs.loadQuestions(id),
    );
    notifyListeners();
  }

  void startPackSession({String? packId}) {
    inPackSession = true;
    packSessionStage = PackSessionStage.flashcards;
    final id = packId ?? selectedPackId ?? (packs.isNotEmpty ? packs.first.id : null);
    if (id != null) {
      selectedPackId = id;
    }
    if (packGameQueue.isEmpty) {
      _setPackGameQueue(['flashcards', 'quiz', 'matching']);
    }
    notifyListeners();
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
    streakDays += 1;
    xpToday += 20;
    totalXp += 20;
    mastery = mastery.map((key, value) {
      final next = (value + 0.03).clamp(0.0, 1.0);
      return MapEntry(key, next);
    });
    final packId = selectedPackId;
    if (packId != null) {
      packs = packs
          .map(
            (pack) => pack.id == packId
                ? pack.copyWith(progress: (pack.progress + 0.2).clamp(0.0, 1.0))
                : pack,
          )
          .toList();
    }
    notifyListeners();
  }

  void endPackSession() {
    inPackSession = false;
    packSessionStage = null;
    packGameQueue = [];
    packGameIndex = 0;
    notifyListeners();
  }

  void startRevision({String? packId}) {
    final id = packId ?? selectedPackId ?? (packs.isNotEmpty ? packs.first.id : null);
    if (id == null) {
      return;
    }
    selectedPackId = id;
    final pack = packs.firstWhere((item) => item.id == id, orElse: () => packs.first);
    revisionSession = RevisionSession(
      prompts: _repositories.packs.loadRevisionPrompts(id),
      subjectLabel: '${pack.subject} • ${pack.title}',
      durationMinutes: 5,
    );
    notifyListeners();
  }

  void answerRevisionPrompt(int selectedIndex) {
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
      xpToday += 3;
      totalXp += 3;
    }
    session.currentIndex += 1;
    notifyListeners();
  }

  void resetRevision() {
    revisionSession = null;
    notifyListeners();
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
        await backend.login(
          email: _demoEmail,
          password: _demoPassword,
        );
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
        orElse: () => children.isNotEmpty ? children.first : <String, dynamic>{},
      );
      backendChildId = _extractId(selectedChild);

      if (backendChildId == null) {
        final created = await backend.createChild(
          name: BackendConfig.childName,
          gradeLevel: BackendConfig.childGrade,
        );
        backendChildId = _extractId(created);
        if (backendChildId == null && children.isEmpty) {
          final refreshed = await backend.listChildren();
          backendChildId = refreshed.isNotEmpty ? _extractId(refreshed.first) : null;
        }
      }
    }

    final childId = backendChildId;
    if (childId == null) {
      throw BackendException('No child profile available.');
    }

    return _BackendSession(childId: childId);
  }

  bool _isEmailTaken(Object error) {
    return error.toString().toLowerCase().contains('email has already been taken');
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

    const maxAttempts = 20;
    for (var attempt = 0; attempt < maxAttempts; attempt += 1) {
      final doc = await backend.getDocument(childId: childId, documentId: documentId);
      final status = doc['status']?.toString();
      if (status == 'failed') {
        throw BackendException('Document processing failed.');
      }

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
        await _syncPackFromBackend(pack);

        final games = await backend.listGames(childId: childId, packId: packId);
        final payloadsByType = <String, Map<String, dynamic>>{};
        for (final entry in games.cast<Map<String, dynamic>>()) {
          final status = entry['status']?.toString();
          final type = entry['type']?.toString();
          final payload = entry['payload'];
          if (status == 'ready' && type != null && payload is Map<String, dynamic>) {
            payloadsByType[type] = payload;
          }
        }
        gamePayloads = payloadsByType;
        flashcardsPayload = payloadsByType['flashcards'];
        matchingPayload = payloadsByType['matching'];
        _setPackGameQueue(payloadsByType.keys.toList());

        final supportedTypes = [
          'quiz',
          'true_false',
          'multiple_select',
          'fill_blank',
          'short_answer',
          'ordering',
        ];
        Map<String, dynamic> selectedGame = {};
        for (final type in supportedTypes) {
          selectedGame = games.cast<Map<String, dynamic>>().firstWhere(
                (game) => game['type'] == type && game['status'] == 'ready',
                orElse: () => <String, dynamic>{},
              );
          if (selectedGame.isNotEmpty) {
            break;
          }
        }

        if (selectedGame.isNotEmpty) {
          _loadQuizFromPayload(selectedGame);
          return;
        }
      }

      await Future.delayed(const Duration(seconds: 2));
    }

    throw BackendException('Quiz generation timed out.');
  }

  Future<void> _syncPackFromBackend(Map<String, dynamic> pack) async {
    final packId = pack['_id']?.toString() ?? '';
    final title = pack['title']?.toString() ?? 'Learning Pack';
    final summary = pack['summary']?.toString();
    final content = pack['content'] as Map<String, dynamic>?;
    final items = content?['items'] as List<dynamic>? ?? [];
    final subject = summary?.split(' ').first ?? 'Homework';

    final style = _packStyleForSubject(subject);
    final newPack = LearningPack(
      id: packId,
      title: title,
      subject: subject,
      itemCount: items.length,
      minutes: 10,
      icon: style.icon,
      color: style.color,
      progress: 0.0,
    );

    packs = [newPack, ...packs.where((existing) => existing.id != packId)];
    selectedPackId = packId;
  }

  void _loadQuizFromPayload(Map<String, dynamic> game) {
    currentGameId = _extractId(game);
    final type = game['type']?.toString() ?? 'quiz';
    final payload = game['payload'] as Map<String, dynamic>? ?? {};
    currentGameType = type;
    currentGameTitle = payload['title']?.toString();
    final mapped = <QuizQuestion>[];

    if (type == 'ordering') {
      final items = payload['items'] as List<dynamic>? ?? [];
      for (final item in items) {
        final data = item as Map<String, dynamic>;
        final sequence = (data['sequence'] as List<dynamic>? ?? []).map((e) => e.toString()).toList();
        if (sequence.isEmpty) {
          continue;
        }
        final shuffled = List<String>.from(sequence)..shuffle();
        mapped.add(QuizQuestion(
          id: data['id']?.toString() ?? UniqueKey().toString(),
          prompt: data['prompt']?.toString() ?? 'Put these in order',
          options: shuffled,
          correctIndex: 0,
          orderedSequence: sequence,
          hint: data['hint']?.toString(),
          explanation: data['explanation']?.toString(),
        ));
      }
    } else {
      final questions = payload['questions'] as List<dynamic>? ?? [];
      for (final item in questions) {
        final data = item as Map<String, dynamic>;
        if (type == 'true_false') {
          mapped.add(QuizQuestion(
            id: data['id']?.toString() ?? UniqueKey().toString(),
            prompt: data['statement']?.toString() ?? '',
            options: const ['True', 'False'],
            correctIndex: (data['answer'] == true) ? 0 : 1,
            explanation: data['explanation']?.toString(),
          ));
        } else if (type == 'multiple_select') {
          final indices = (data['answer_indices'] as List<dynamic>? ?? [])
              .map((e) => (e as num).toInt())
              .toList();
          mapped.add(QuizQuestion(
            id: data['id']?.toString() ?? UniqueKey().toString(),
            prompt: data['prompt']?.toString() ?? '',
            options: (data['choices'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
            correctIndex: indices.isNotEmpty ? indices.first : 0,
            correctIndices: indices,
            hint: data['hint']?.toString(),
            explanation: data['explanation']?.toString(),
          ));
        } else if (type == 'fill_blank' || type == 'short_answer') {
          mapped.add(QuizQuestion(
            id: data['id']?.toString() ?? UniqueKey().toString(),
            prompt: data['prompt']?.toString() ?? '',
            options: const [],
            correctIndex: 0,
            answerText: data['answer']?.toString(),
            acceptedAnswers: (data['accepted_answers'] as List<dynamic>? ?? [])
                .map((e) => e.toString())
                .toList(),
            hint: data['hint']?.toString(),
            explanation: data['explanation']?.toString(),
          ));
        } else {
          mapped.add(QuizQuestion(
            id: data['id']?.toString() ?? UniqueKey().toString(),
            prompt: data['prompt']?.toString() ?? '',
            options: (data['choices'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
            correctIndex: (data['answer_index'] as int?) ?? 0,
            hint: data['hint']?.toString(),
            explanation: data['explanation']?.toString(),
          ));
        }
      }
    }

    quizSession = QuizSession(
      packId: selectedPackId ?? '',
      questions: mapped,
    );
  }

  void startGameType(String type) {
    if (type == 'flashcards' || type == 'matching') {
      return;
    }
    final payload = gamePayloads[type];
    if (payload != null) {
      _loadQuizFromPayload({'type': type, 'payload': payload});
      notifyListeners();
      return;
    }
    startQuiz();
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

  void answerCurrentQuestion(int selectedIndex) {
    final session = quizSession;
    if (session == null) {
      return;
    }
    final question = session.currentQuestion;
    if (question == null) {
      return;
    }
    final index = session.currentIndex;
    if (selectedIndex == question.correctIndex) {
      session.correctCount += 1;
      xpToday += 5;
      totalXp += 5;
    } else {
      session.incorrectIndices.add(index);
    }
    session.currentIndex += 1;
    notifyListeners();
  }

  void answerCurrentQuestionMulti(List<int> selectedIndices) {
    final session = quizSession;
    if (session == null) {
      return;
    }
    final question = session.currentQuestion;
    if (question == null) {
      return;
    }
    final index = session.currentIndex;
    final correct = (question.correctIndices ?? [question.correctIndex]).toSet();
    final selected = selectedIndices.toSet();
    if (selected.isNotEmpty && selected.length == correct.length && selected.containsAll(correct)) {
      session.correctCount += 1;
      xpToday += 5;
      totalXp += 5;
    } else {
      session.incorrectIndices.add(index);
    }
    session.currentIndex += 1;
    notifyListeners();
  }

  void answerCurrentQuestionText(String value) {
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
    if (answers.contains(normalized)) {
      session.correctCount += 1;
      xpToday += 5;
      totalXp += 5;
    } else {
      session.incorrectIndices.add(index);
    }
    session.currentIndex += 1;
    notifyListeners();
  }

  void answerCurrentQuestionOrdering(List<String> ordered) {
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
    final isCorrect = ordered.length == expected.length &&
        List.generate(ordered.length, (index) => ordered[index] == expected[index]).every((v) => v);
    if (isCorrect) {
      session.correctCount += 1;
      xpToday += 5;
      totalXp += 5;
    } else {
      session.incorrectIndices.add(index);
    }
    session.currentIndex += 1;
    notifyListeners();
  }

  void resetQuiz() {
    quizSession = null;
    flashcardsPayload = null;
    matchingPayload = null;
    currentGameType = null;
    currentGameTitle = null;
    currentGameId = null;
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
          .cast<Map<String, dynamic>>()
          .map((doc) {
            final id = _extractId(doc) ?? '';
            final title = doc['original_filename']?.toString() ?? 'Homework';
            final subject = doc['subject']?.toString() ?? 'Homework';
            final status = doc['status']?.toString() ?? 'unknown';
            final createdAt = DateTime.tryParse(doc['created_at']?.toString() ?? '') ?? DateTime.now();
            return DocumentItem(
              id: id,
              title: title,
              subject: subject,
              createdAt: createdAt,
              statusLabel: _statusLabelForDocument(status),
            );
          })
          .toList();
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
    await backend.regenerateDocument(childId: session.childId, documentId: documentId);
    documents = documents
        .map(
          (doc) => doc.id == documentId ? doc.copyWith(statusLabel: 'Queued') : doc,
        )
        .toList();
    notifyListeners();
  }

  Future<void> retryIncorrectQuestions() async {
    final session = quizSession;
    if (session == null || session.incorrectIndices.isEmpty) {
      return;
    }
    final packId = session.packId;
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

enum PackSessionStage {
  flashcards,
  quiz,
  matching,
  results,
}

class _BackendSession {
  const _BackendSession({required this.childId});

  final String childId;
}
