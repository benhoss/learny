import 'package:flutter_test/flutter_test.dart';
import 'package:learny_app/services/backend_client.dart';
import 'package:learny_app/state/app_state.dart';

class _TestBackendClient extends BackendClient {
  _TestBackendClient({
    this.failFirstSubmit = false,
    this.submitResponse = const {
      'streak_days': 20,
      'total_xp': 2222,
      'xp_earned': 10,
    },
  }) : super(baseUrl: 'http://localhost');

  final bool failFirstSubmit;
  final Map<String, dynamic> submitResponse;
  int submitCalls = 0;
  int fetchReviewCalls = 0;

  @override
  Future<Map<String, dynamic>> submitGameResult({
    required String childId,
    required String packId,
    required String gameId,
    required String gameType,
    required List<Map<String, dynamic>> results,
    required int totalQuestions,
    required int correctAnswers,
  }) async {
    submitCalls += 1;
    if (failFirstSubmit && submitCalls == 1) {
      throw BackendException('Transient failure');
    }
    return submitResponse;
  }

  @override
  Future<Map<String, dynamic>?> fetchReviewQueue({
    required String childId,
  }) async {
    fetchReviewCalls += 1;
    return {'data': <Map<String, dynamic>>[], 'total_due': 0};
  }
}

class _ProgressFlowBackendClient extends BackendClient {
  _ProgressFlowBackendClient() : super(baseUrl: 'http://localhost');

  int listDocumentsCalls = 0;
  int listActivitiesCalls = 0;
  final List<List<String>?> regenerateCalls = [];

  @override
  Future<Map<String, dynamic>> regenerateDocument({
    required String childId,
    required String documentId,
    List<String>? requestedGameTypes,
  }) async {
    regenerateCalls.add(requestedGameTypes);
    return {'id': documentId, 'status': 'queued'};
  }

  @override
  Future<List<dynamic>> listDocuments({required String childId}) async {
    listDocumentsCalls += 1;
    return [
      {
        '_id': 'doc-1',
        'original_filename': 'fractions.pdf',
        'subject': 'Math',
        'status': 'queued',
        'created_at': DateTime.now().toIso8601String(),
      },
    ];
  }

  @override
  Future<Map<String, dynamic>> listActivities({
    required String childId,
    int page = 1,
    int perPage = 20,
  }) async {
    listActivitiesCalls += 1;
    if (page == 1) {
      return {
        'data': [
          {
            'id': 'a-1',
            'completed_at': DateTime.now().toIso8601String(),
            'game_type': 'quiz',
            'subject': 'Math',
            'score_percent': 80,
            'correct_answers': 4,
            'total_questions': 5,
            'xp_earned': 40,
            'cheer_message': 'Great focus.',
          },
          {
            'id': 'a-2',
            'completed_at': DateTime.now().toIso8601String(),
            'game_type': 'flashcards',
            'subject': 'Math',
            'score_percent': 60,
            'correct_answers': 3,
            'total_questions': 5,
            'xp_earned': 30,
            'cheer_message': 'Keep going.',
          },
        ],
        'meta': {'has_more': true},
      };
    }

    return {
      'data': [
        {
          'id': 'a-3',
          'completed_at': DateTime.now().toIso8601String(),
          'game_type': 'matching',
          'subject': 'Math',
          'score_percent': 100,
          'correct_answers': 5,
          'total_questions': 5,
          'xp_earned': 50,
          'cheer_message': 'Excellent.',
        },
      ],
      'meta': {'has_more': false},
    };
  }
}

void main() {
  group('AppState result submission flow', () {
    test('skips submission when identifiers are missing', () async {
      final backend = _TestBackendClient();
      final state = AppState(
        backendClient: backend,
        initializeBackendSession: false,
        submitRetryDelay: Duration.zero,
      );

      expect(state.xpToday, 0);
      expect(state.totalXp, 0);
      expect(state.streakDays, 0);

      await state.completeMatchingGame([
        {'left': 'A', 'right': 'B', 'topic': 'concept.alpha'},
      ]);

      expect(backend.submitCalls, 0);
      expect(state.lastResultSyncError, isNotNull);
      expect(
        state.lastResultSyncError,
        contains('missing childId/packId/gameId'),
      );
      expect(state.xpToday, 0);
      expect(state.totalXp, 0);
      expect(state.streakDays, 0);
    });

    test('retries once and succeeds on second submit attempt', () async {
      final backend = _TestBackendClient(
        failFirstSubmit: true,
        submitResponse: const {
          'streak_days': 20,
          'total_xp': 2222,
          'xp_earned': 10,
        },
      );
      final state = AppState(
        backendClient: backend,
        initializeBackendSession: false,
        submitRetryDelay: Duration.zero,
      );

      state.backendChildId = 'child-1';
      state.selectedPackId = 'pack-1';
      state.currentGameId = 'game-1';
      state.currentGameType = 'matching';

      await state.completeMatchingGame([
        {'left': 'Left', 'right': 'Right', 'topic': 'concept.beta'},
      ]);

      expect(backend.submitCalls, 2);
      expect(backend.fetchReviewCalls, 1);
      expect(state.lastResultSyncError, isNull);
      expect(state.streakDays, 20);
      expect(state.totalXp, 2222);
      expect(state.xpToday, 10);
      expect(state.lastGameOutcome?.xpEarned, 10);
    });
  });

  group('AppState progress and regeneration flow', () {
    test(
      'redo document without explicit game types clears filters path',
      () async {
        final backend = _ProgressFlowBackendClient()..token = 'token';
        final state = AppState(
          backendClient: backend,
          initializeBackendSession: false,
        );

        state.backendChildId = 'child-1';

        final ok = await state.regenerateDocument('doc-1');

        expect(ok, isTrue);
        expect(backend.regenerateCalls, [null]);
        expect(backend.listDocumentsCalls, 1);
      },
    );

    test(
      'refresh and load-more activities append pages using pagination meta',
      () async {
        final backend = _ProgressFlowBackendClient()..token = 'token';
        final state = AppState(
          backendClient: backend,
          initializeBackendSession: false,
        );

        state.backendChildId = 'child-1';

        await state.refreshActivitiesFromBackend();
        expect(state.activities.length, 2);
        expect(state.hasMoreActivities, isTrue);

        await state.loadMoreActivitiesFromBackend();
        expect(state.activities.length, 3);
        expect(state.hasMoreActivities, isFalse);
        expect(backend.listActivitiesCalls, 2);
      },
    );
  });
}
