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
}
