import 'package:flutter_test/flutter_test.dart';
import 'package:learny_app/services/backend_client.dart';
import 'package:learny_app/state/app_state.dart';

class _OnboardingBackendClient extends BackendClient {
  _OnboardingBackendClient() : super(baseUrl: 'http://localhost');

  int eventCalls = 0;
  int loginCalls = 0;
  int registerCalls = 0;
  int createChildCalls = 0;

  final List<Map<String, dynamic>> _children = [];

  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    loginCalls += 1;
    token = 'token';
    return {
      'user': {'name': 'Parent Tester', 'email': email, '_id': 'u-1'},
    };
  }

  @override
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    registerCalls += 1;
    token = 'token';
    return {
      'user': {'name': name, 'email': email, '_id': 'u-1'},
    };
  }

  @override
  Future<List<dynamic>> listChildren() async {
    return _children;
  }

  @override
  Future<Map<String, dynamic>> createChild({
    required String name,
    String? gradeLevel,
    int? birthYear,
    String? schoolClass,
    String? preferredLanguage,
    String? gender,
    String? genderSelfDescription,
    List<String>? learningStylePreferences,
    Map<String, dynamic>? supportNeeds,
    List<Map<String, dynamic>>? confidenceBySubject,
  }) async {
    createChildCalls += 1;
    final child = {
      '_id': 'child-${_children.length + 1}',
      'name': name,
      'grade_level': gradeLevel ?? '6th',
      'preferred_language': preferredLanguage ?? 'en',
    };
    _children.add(child);
    return child;
  }

  @override
  Future<Map<String, dynamic>> trackOnboardingEvent({
    required String role,
    required String eventName,
    String? step,
    String? instanceId,
    Map<String, dynamic>? metadata,
  }) async {
    eventCalls += 1;
    return {'recorded': true, 'event_name': eventName};
  }

  @override
  Future<Map<String, dynamic>> createOnboardingLinkToken({
    required String childId,
    int expiresInSeconds = 600,
  }) async {
    return {'code': '123456', 'child_id': childId};
  }

  @override
  Future<Map<String, dynamic>> consumeOnboardingLinkToken({
    required String code,
    String? childId,
    required String deviceName,
    String? devicePlatform,
  }) async {
    return {'child_id': childId ?? 'child-1', 'linked': true};
  }

  @override
  Future<List<dynamic>> listChildDevices({required String childId}) async {
    return [
      {'id': 'dev-1', 'name': 'Phone', 'platform': 'ios'},
    ];
  }

  @override
  Future<Map<String, dynamic>> revokeChildDevice({
    required String childId,
    required String deviceId,
  }) async {
    return {'revoked': true};
  }
}

void main() {
  group('AppState onboarding flow', () {
    test('debug skip auto-logins and completes onboarding', () async {
      final backend = _OnboardingBackendClient();
      final state = AppState(
        backendClient: backend,
        initializeBackendSession: false,
      );

      final ok = await state.debugSkipOnboardingAutoLogin();

      expect(ok, isTrue);
      expect(state.onboardingComplete, isTrue);
      expect(backend.loginCalls, 1);
    });

    test(
      'parent onboarding auth + child creation + code link updates state',
      () async {
        final backend = _OnboardingBackendClient();
        final state = AppState(
          backendClient: backend,
          initializeBackendSession: false,
        );

        final authOk = await state.parentAuthenticateForOnboarding(
          name: 'Parent',
          email: 'parent@example.com',
          password: 'secret123',
          loginMode: false,
        );
        expect(authOk, isTrue);

        final child = await state.createChildForOnboarding(
          name: 'Alex',
          gradeLevel: '6th',
        );
        expect(child, isNotNull);

        final code = await state.generateParentLinkCode(child!.id);
        expect(code, '123456');

        final linked = await state.linkChildDeviceWithCode(
          code: code!,
          deviceName: 'Alex phone',
        );
        expect(linked, isTrue);
        expect(state.onboardingCompletedSteps.contains('add_children'), isTrue);
        expect(backend.eventCalls, greaterThan(0));
      },
    );

    test(
      'child onboarding keeps child step and stores child id checkpoint',
      () async {
        final backend = _OnboardingBackendClient();
        final state = AppState(
          backendClient: backend,
          initializeBackendSession: false,
        );

        await state.selectOnboardingRole('child');
        await state.saveOnboardingStep(
          step: 'first_challenge',
          checkpoint: {'age_bracket': '10-11'},
          completedStep: 'child_avatar',
        );

        final child = await state.createChildForOnboarding(
          name: 'Alex',
          gradeLevel: '6th',
          role: 'child',
        );

        expect(child, isNotNull);
        expect(state.onboardingStep, 'first_challenge');
        expect(
          state.onboardingCompletedSteps.contains('child_profile'),
          isTrue,
        );
        expect(state.onboardingCheckpoints['child_id'], child!.id);
        expect(state.backendChildId, child.id);
      },
    );
  });
}
