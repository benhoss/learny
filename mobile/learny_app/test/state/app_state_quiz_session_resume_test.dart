import 'package:flutter_test/flutter_test.dart';
import 'package:learny_app/services/backend_client.dart';
import 'package:learny_app/state/app_state.dart';

class _QuizSessionBackendClient extends BackendClient {
  _QuizSessionBackendClient() : super(baseUrl: 'http://localhost');

  int createCalls = 0;
  int updateCalls = 0;
  String? lastStatus;

  Map<String, dynamic>? activeSession;

  @override
  Future<List<dynamic>> listGames({
    required String childId,
    required String packId,
  }) async {
    return [
      {
        '_id': 'game-quiz-1',
        'type': 'quiz',
        'status': 'ready',
        'payload': {
          'title': 'Quick Quiz',
          'questions': List.generate(10, (index) {
            return {
              'id': 'q-${index + 1}',
              'prompt': 'Question ${index + 1}',
              'choices': ['A', 'B', 'C', 'D'],
              'answer_index': 0,
              'topic': index.isEven
                  ? 'fractions.addition'
                  : 'fractions.subtraction',
            };
          }),
        },
      },
    ];
  }

  @override
  Future<Map<String, dynamic>> createQuizSession({
    required String childId,
    required String packId,
    required String gameId,
    required int questionCount,
  }) async {
    createCalls += 1;
    final data = {
      'id': 'quiz-session-1',
      'status': 'active',
      'learning_pack_id': packId,
      'game_id': gameId,
      'requested_question_count': questionCount,
      'question_indices': [0, 2, 4, 6, 8].take(questionCount).toList(),
      'current_index': 0,
      'correct_count': 0,
      'results': <Map<String, dynamic>>[],
    };
    activeSession = data;
    return {'data': data, 'idempotent_replay': false};
  }

  @override
  Future<Map<String, dynamic>?> fetchActiveQuizSession({
    required String childId,
  }) async {
    return activeSession;
  }

  @override
  Future<Map<String, dynamic>> updateQuizSession({
    required String childId,
    required String sessionId,
    int? currentIndex,
    int? correctCount,
    List<Map<String, dynamic>>? results,
    String? status,
  }) async {
    updateCalls += 1;
    lastStatus = status;
    final updated = {
      'id': sessionId,
      'status': status ?? (activeSession?['status'] ?? 'active'),
      'learning_pack_id': activeSession?['learning_pack_id'] ?? 'pack-1',
      'game_id': activeSession?['game_id'] ?? 'game-quiz-1',
      'requested_question_count':
          activeSession?['requested_question_count'] ?? 5,
      'question_indices': activeSession?['question_indices'] ?? [0, 2, 4, 6, 8],
      'current_index': currentIndex ?? 0,
      'correct_count': correctCount ?? 0,
      'results': results ?? <Map<String, dynamic>>[],
    };
    activeSession = updated;
    return {'data': updated, 'idempotent_replay': false};
  }
}

void main() {
  group('AppState quiz session setup + resume', () {
    test('startQuizFromSetup hydrates filtered question set', () async {
      final backend = _QuizSessionBackendClient();
      final state = AppState(
        backendClient: backend,
        initializeBackendSession: false,
        submitRetryDelay: Duration.zero,
      );

      state.backendChildId = 'child-1';
      state.selectedPackId = 'pack-1';

      final started = await state.startQuizFromSetup(questionCount: 5);

      expect(started, isTrue);
      expect(backend.createCalls, 1);
      expect(state.quizSession, isNotNull);
      expect(state.quizSession!.questions.length, 5);
      expect(state.quizSession!.backendSessionId, 'quiz-session-1');
    });

    test(
      'resumeQuizFromSetup restores progress and saveAndExit pauses session',
      () async {
        final backend = _QuizSessionBackendClient();
        backend.activeSession = {
          'id': 'quiz-session-1',
          'status': 'paused',
          'learning_pack_id': 'pack-1',
          'game_id': 'game-quiz-1',
          'requested_question_count': 5,
          'question_indices': [0, 2, 4, 6, 8],
          'current_index': 2,
          'correct_count': 1,
          'results': [
            {
              'correct': true,
              'prompt': 'Question 1',
              'topic': 'fractions.addition',
              'response': 'A',
              'expected': 'A',
            },
          ],
        };

        final state = AppState(
          backendClient: backend,
          initializeBackendSession: false,
          submitRetryDelay: Duration.zero,
        );

        state.backendChildId = 'child-1';
        state.selectedPackId = 'pack-1';

        final resumed = await state.resumeQuizFromSetup();

        expect(resumed, isTrue);
        expect(state.quizSession, isNotNull);
        expect(state.quizSession!.currentIndex, 2);
        expect(state.quizSession!.correctCount, 1);
        expect(state.quizSession!.results.length, 1);

        await state.saveAndExitQuiz();

        expect(backend.updateCalls, greaterThan(0));
        expect(backend.lastStatus, 'paused');
        expect(state.quizSession, isNull);
      },
    );
  });
}
