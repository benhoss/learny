import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class BackendClient {
  BackendClient({required this.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  String? token;

  Future<Map<String, dynamic>> createGuestSession({
    required String deviceSignature,
    String? instanceId,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/v1/guest/session'),
      headers: _jsonHeaders(includeContentType: true),
      body: jsonEncode({
        'device_signature': deviceSignature,
        if (instanceId != null) 'instance_id': instanceId,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw BackendException('Create guest session failed: ${response.body}');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return payload['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> linkGuestSessionAccount({
    required String guestSessionId,
    required String childId,
    String? instanceId,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/v1/guest/link-account'),
      headers: _authHeaders(includeContentType: true),
      body: jsonEncode({
        'guest_session_id': guestSessionId,
        'child_id': childId,
        if (instanceId != null) 'instance_id': instanceId,
      }),
    );

    if (response.statusCode != 200) {
      throw BackendException('Link guest account failed: ${response.body}');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return payload['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> trackGuestEvent({
    required String guestSessionId,
    required String eventName,
    String? step,
    String? instanceId,
    Map<String, dynamic>? metadata,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/v1/guest/events'),
      headers: _jsonHeaders(includeContentType: true),
      body: jsonEncode({
        'guest_session_id': guestSessionId,
        'event_name': eventName,
        if (step != null) 'step': step,
        if (instanceId != null) 'instance_id': instanceId,
        if (metadata != null) 'metadata': metadata,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw BackendException('Track guest event failed: ${response.body}');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return payload['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> onboardingPolicy({String? market}) async {
    final uri = Uri.parse('$baseUrl/api/v1/onboarding/policy');
    final target = market == null
        ? uri
        : uri.replace(queryParameters: {'market': market});
    final response = await _client.get(target, headers: _jsonHeaders());

    if (response.statusCode != 200) {
      throw BackendException('Onboarding policy failed: ${response.body}');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return payload['data'] as Map<String, dynamic>;
  }

  /// Get list of available countries with grade systems.
  /// This is a public endpoint (no auth required).
  Future<Map<String, dynamic>> listOnboardingCountries({String? country}) async {
    final uri = Uri.parse('$baseUrl/api/v1/onboarding/countries');
    final target = country == null
        ? uri
        : uri.replace(queryParameters: {'country': country});
    final response = await _client.get(target, headers: _jsonHeaders());

    if (response.statusCode != 200) {
      throw BackendException('List onboarding countries failed: ${response.body}');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return payload['data'] as Map<String, dynamic>;
  }

  /// Get grade suggestions based on country and age.
  /// This is a public endpoint (no auth required).
  Future<Map<String, dynamic>> getGradeSuggestions({
    String? country,
    required int age,
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/onboarding/grade-suggestions');
    final target = uri.replace(queryParameters: {
      if (country != null) 'country': country,
      'age': age.toString(),
    });
    final response = await _client.get(target, headers: _jsonHeaders());

    if (response.statusCode != 200) {
      throw BackendException('Get grade suggestions failed: ${response.body}');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return payload['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/v1/auth/login'),
      headers: _jsonHeaders(includeContentType: true),
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode != 200) {
      throw BackendException('Login failed: ${response.body}');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    token = payload['access_token'] as String?;
    return payload;
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/v1/auth/register'),
      headers: _jsonHeaders(includeContentType: true),
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw BackendException('Register failed: ${response.body}');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    token = payload['access_token'] as String?;
    return payload;
  }

  Future<List<dynamic>> listChildren() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/v1/children'),
      headers: _authHeaders(),
    );

    if (response.statusCode != 200) {
      throw BackendException('List children failed: ${response.body}');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return (payload['data'] as List<dynamic>?) ?? [];
  }

  Future<Map<String, dynamic>> onboardingState() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/v1/onboarding/state'),
      headers: _authHeaders(),
    );

    if (response.statusCode != 200) {
      throw BackendException('Onboarding state failed: ${response.body}');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return payload['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateOnboardingState({
    required String role,
    required String currentStep,
    Map<String, dynamic>? checkpoints,
    List<String>? completedSteps,
    bool markComplete = false,
  }) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/api/v1/onboarding/state'),
      headers: _authHeaders(includeContentType: true),
      body: jsonEncode({
        'role': role,
        'current_step': currentStep,
        if (checkpoints != null) 'checkpoints': checkpoints,
        if (completedSteps != null) 'completed_steps': completedSteps,
        'mark_complete': markComplete,
      }),
    );

    if (response.statusCode != 200) {
      throw BackendException(
        'Update onboarding state failed: ${response.body}',
      );
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return payload['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> trackOnboardingEvent({
    required String role,
    required String eventName,
    String? step,
    String? instanceId,
    Map<String, dynamic>? metadata,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/v1/onboarding/events'),
      headers: _authHeaders(includeContentType: true),
      body: jsonEncode({
        'role': role,
        'event_name': eventName,
        if (step != null) 'step': step,
        if (instanceId != null) 'instance_id': instanceId,
        if (metadata != null) 'metadata': metadata,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw BackendException('Track onboarding event failed: ${response.body}');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return payload['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createOnboardingLinkToken({
    required String childId,
    int expiresInSeconds = 600,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/v1/onboarding/link-tokens'),
      headers: _authHeaders(includeContentType: true),
      body: jsonEncode({
        'child_id': childId,
        'expires_in_seconds': expiresInSeconds,
      }),
    );

    if (response.statusCode != 201) {
      throw BackendException(
        'Create onboarding link token failed: ${response.body}',
      );
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return payload['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> consumeOnboardingLinkToken({
    required String code,
    String? childId,
    required String deviceName,
    String? devicePlatform,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/v1/onboarding/link-tokens/consume'),
      headers: _jsonHeaders(includeContentType: true),
      body: jsonEncode({
        'code': code,
        if (childId != null) 'child_id': childId,
        'device_name': deviceName,
        if (devicePlatform != null) 'device_platform': devicePlatform,
      }),
    );

    if (response.statusCode != 200) {
      throw BackendException(
        'Consume onboarding link token failed: ${response.body}',
      );
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return payload['data'] as Map<String, dynamic>;
  }

  Future<List<dynamic>> listChildDevices({required String childId}) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/v1/children/$childId/devices'),
      headers: _authHeaders(),
    );

    if (response.statusCode != 200) {
      throw BackendException('List child devices failed: ${response.body}');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return (payload['data'] as List<dynamic>?) ?? [];
  }

  Future<Map<String, dynamic>> revokeChildDevice({
    required String childId,
    required String deviceId,
  }) async {
    final response = await _client.delete(
      Uri.parse('$baseUrl/api/v1/children/$childId/devices/$deviceId'),
      headers: _authHeaders(),
    );

    if (response.statusCode != 200) {
      throw BackendException('Revoke child device failed: ${response.body}');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return payload['data'] as Map<String, dynamic>;
  }

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
    final payload = <String, dynamic>{
      'name': name,
      if (gradeLevel != null && gradeLevel.isNotEmpty)
        'grade_level': gradeLevel,
      if (birthYear != null) 'birth_year': birthYear,
      if (schoolClass != null && schoolClass.isNotEmpty)
        'school_class': schoolClass,
      if (preferredLanguage != null && preferredLanguage.isNotEmpty)
        'preferred_language': preferredLanguage,
      if (gender != null && gender.isNotEmpty) 'gender': gender,
      if (genderSelfDescription != null && genderSelfDescription.isNotEmpty)
        'gender_self_description': genderSelfDescription,
      if (learningStylePreferences != null)
        'learning_style_preferences': learningStylePreferences,
      if (supportNeeds != null) 'support_needs': supportNeeds,
      if (confidenceBySubject != null)
        'confidence_by_subject': confidenceBySubject,
    };

    final response = await _client.post(
      Uri.parse('$baseUrl/api/v1/children'),
      headers: _authHeaders(includeContentType: true),
      body: jsonEncode(payload),
    );

    if (response.statusCode != 201) {
      throw BackendException('Create child failed: ${response.body}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return decoded['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> uploadDocument({
    required String childId,
    required Uint8List bytes,
    required String filename,
    String? title,
    String? subject,
    String? topic,
    String? language,
    String? gradeLevel,
    List<String>? collections,
    List<String>? tags,
    String? learningGoal,
    String? contextText,
    List<String>? requestedGameTypes,
    String? guestSessionId,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/v1/children/$childId/documents'),
    );
    request.headers.addAll(_authHeaders());
    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: filename),
    );
    if (title != null && title.isNotEmpty) {
      request.fields['title'] = title;
    }
    if (subject != null && subject.isNotEmpty) {
      request.fields['subject'] = subject;
    }
    if (topic != null && topic.isNotEmpty) {
      request.fields['topic'] = topic;
    }
    if (language != null && language.isNotEmpty) {
      request.fields['language'] = language;
    }
    if (gradeLevel != null && gradeLevel.isNotEmpty) {
      request.fields['grade_level'] = gradeLevel;
    }
    if (collections != null && collections.isNotEmpty) {
      for (var index = 0; index < collections.length; index += 1) {
        request.fields['collections[$index]'] = collections[index];
      }
    }
    if (tags != null && tags.isNotEmpty) {
      for (var index = 0; index < tags.length; index += 1) {
        request.fields['tags[$index]'] = tags[index];
      }
    }
    if (learningGoal != null && learningGoal.isNotEmpty) {
      request.fields['learning_goal'] = learningGoal;
    }
    if (contextText != null && contextText.isNotEmpty) {
      request.fields['context_text'] = contextText;
    }
    if (requestedGameTypes != null && requestedGameTypes.isNotEmpty) {
      for (var index = 0; index < requestedGameTypes.length; index += 1) {
        request.fields['requested_game_types[$index]'] =
            requestedGameTypes[index];
      }
    }
    if (guestSessionId != null && guestSessionId.isNotEmpty) {
      request.fields['guest_session_id'] = guestSessionId;
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 201) {
      throw BackendException('Upload failed: ${response.body}');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return payload['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> uploadDocumentBatch({
    required String childId,
    required List<Uint8List> files,
    required List<String> filenames,
    String? title,
    String? subject,
    String? topic,
    String? language,
    String? gradeLevel,
    List<String>? collections,
    List<String>? tags,
    String? learningGoal,
    String? contextText,
    List<String>? requestedGameTypes,
    String? guestSessionId,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/v1/children/$childId/documents'),
    );
    request.headers.addAll(_authHeaders());
    for (var index = 0; index < files.length; index += 1) {
      final filename = index < filenames.length
          ? filenames[index]
          : 'page-${index + 1}.jpg';
      request.files.add(
        http.MultipartFile.fromBytes(
          'files[]',
          files[index],
          filename: filename,
        ),
      );
    }
    if (title != null && title.isNotEmpty) {
      request.fields['title'] = title;
    }
    if (subject != null && subject.isNotEmpty) {
      request.fields['subject'] = subject;
    }
    if (topic != null && topic.isNotEmpty) {
      request.fields['topic'] = topic;
    }
    if (language != null && language.isNotEmpty) {
      request.fields['language'] = language;
    }
    if (gradeLevel != null && gradeLevel.isNotEmpty) {
      request.fields['grade_level'] = gradeLevel;
    }
    if (collections != null && collections.isNotEmpty) {
      for (var index = 0; index < collections.length; index += 1) {
        request.fields['collections[$index]'] = collections[index];
      }
    }
    if (tags != null && tags.isNotEmpty) {
      for (var index = 0; index < tags.length; index += 1) {
        request.fields['tags[$index]'] = tags[index];
      }
    }
    if (learningGoal != null && learningGoal.isNotEmpty) {
      request.fields['learning_goal'] = learningGoal;
    }
    if (contextText != null && contextText.isNotEmpty) {
      request.fields['context_text'] = contextText;
    }
    if (requestedGameTypes != null && requestedGameTypes.isNotEmpty) {
      for (var index = 0; index < requestedGameTypes.length; index += 1) {
        request.fields['requested_game_types[$index]'] =
            requestedGameTypes[index];
      }
    }
    if (guestSessionId != null && guestSessionId.isNotEmpty) {
      request.fields['guest_session_id'] = guestSessionId;
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 201) {
      throw BackendException('Upload failed: ${response.body}');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return payload['data'] as Map<String, dynamic>;
  }

  Future<List<dynamic>> listSchoolAssessments({required String childId}) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/v1/children/$childId/school-assessments'),
      headers: _authHeaders(),
    );

    if (response.statusCode != 200) {
      throw BackendException(
        'List school assessments failed: ${response.body}',
      );
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return (payload['data'] as List<dynamic>?) ?? [];
  }

  Future<Map<String, dynamic>> createSchoolAssessment({
    required String childId,
    required String subject,
    required String assessmentType,
    required double score,
    required double maxScore,
    required String assessedAt,
    String? grade,
    String? teacherNote,
    String source = 'manual',
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/v1/children/$childId/school-assessments'),
      headers: _authHeaders(includeContentType: true),
      body: jsonEncode({
        'subject': subject,
        'assessment_type': assessmentType,
        'score': score,
        'max_score': maxScore,
        'assessed_at': assessedAt,
        'grade': grade,
        'teacher_note': teacherNote,
        'source': source,
      }),
    );

    if (response.statusCode != 201) {
      throw BackendException(
        'Create school assessment failed: ${response.body}',
      );
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return payload['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateSchoolAssessment({
    required String childId,
    required String assessmentId,
    Map<String, dynamic> updates = const {},
  }) async {
    final response = await _client.patch(
      Uri.parse(
        '$baseUrl/api/v1/children/$childId/school-assessments/$assessmentId',
      ),
      headers: _authHeaders(includeContentType: true),
      body: jsonEncode(updates),
    );

    if (response.statusCode != 200) {
      throw BackendException(
        'Update school assessment failed: ${response.body}',
      );
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return payload['data'] as Map<String, dynamic>;
  }

  Future<void> deleteSchoolAssessment({
    required String childId,
    required String assessmentId,
  }) async {
    final response = await _client.delete(
      Uri.parse(
        '$baseUrl/api/v1/children/$childId/school-assessments/$assessmentId',
      ),
      headers: _authHeaders(),
    );

    if (response.statusCode != 200) {
      throw BackendException(
        'Delete school assessment failed: ${response.body}',
      );
    }
  }

  Future<List<dynamic>> listDocuments({required String childId}) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/v1/children/$childId/documents'),
      headers: _authHeaders(),
    );

    if (response.statusCode != 200) {
      throw BackendException('List documents failed: ${response.body}');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return (payload['data'] as List<dynamic>?) ?? [];
  }

  Future<Map<String, dynamic>> regenerateDocument({
    required String childId,
    required String documentId,
    List<String>? requestedGameTypes,
  }) async {
    final response = await _client.post(
      Uri.parse(
        '$baseUrl/api/v1/children/$childId/documents/$documentId/regenerate',
      ),
      headers: _authHeaders(includeContentType: true),
      body: jsonEncode({
        if (requestedGameTypes != null && requestedGameTypes.isNotEmpty)
          'requested_game_types': requestedGameTypes,
      }),
    );

    if (response.statusCode != 202) {
      throw BackendException('Regenerate failed: ${response.body}');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return payload['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getDocument({
    required String childId,
    required String documentId,
  }) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/v1/children/$childId/documents/$documentId'),
      headers: _authHeaders(),
    );

    if (response.statusCode != 200) {
      throw BackendException('Get document failed: ${response.body}');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return payload['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getDocumentScan({
    required String childId,
    required String documentId,
  }) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/v1/children/$childId/documents/$documentId/scan'),
      headers: _authHeaders(),
    );

    if (response.statusCode != 200) {
      throw BackendException('Get document scan failed: ${response.body}');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return payload['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> confirmDocumentScan({
    required String childId,
    required String documentId,
    required String topic,
    required String language,
  }) async {
    const maxAttempts = 3;
    var delay = const Duration(milliseconds: 400);

    for (var attempt = 1; attempt <= maxAttempts; attempt += 1) {
      final response = await _client.post(
        Uri.parse(
          '$baseUrl/api/v1/children/$childId/documents/$documentId/confirm-scan',
        ),
        headers: _authHeaders(includeContentType: true),
        body: jsonEncode({'topic': topic, 'language': language}),
      );

      if (response.statusCode == 200 || response.statusCode == 202) {
        try {
          final payload = jsonDecode(response.body) as Map<String, dynamic>;
          return payload['data'] as Map<String, dynamic>;
        } catch (_) {
          if (attempt < maxAttempts) {
            await Future.delayed(delay);
            delay *= 2;
            continue;
          }
          throw BackendException(
            'Confirm document scan failed. Please retry.',
            statusCode: response.statusCode,
          );
        }
      }

      if (_shouldRetry(response.statusCode, response.body) &&
          attempt < maxAttempts) {
        await Future.delayed(delay);
        delay *= 2;
        continue;
      }

      throw BackendException.fromResponse(
        'Confirm document scan',
        response.statusCode,
        response.body,
      );
    }

    throw BackendException('Confirm document scan failed. Please retry.');
  }

  Future<Map<String, dynamic>> rescanDocument({
    required String childId,
    required String documentId,
  }) async {
    final response = await _client.post(
      Uri.parse(
        '$baseUrl/api/v1/children/$childId/documents/$documentId/rescan',
      ),
      headers: _authHeaders(),
    );

    if (response.statusCode != 202) {
      throw BackendException('Rescan document failed: ${response.body}');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return payload['data'] as Map<String, dynamic>;
  }

  Future<List<dynamic>> listLearningPacks({
    required String childId,
    String? documentId,
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/children/$childId/learning-packs');
    final url = documentId == null
        ? uri
        : uri.replace(queryParameters: {'document_id': documentId});
    final response = await _client.get(url, headers: _authHeaders());

    if (response.statusCode != 200) {
      throw BackendException('List packs failed: ${response.body}');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return (payload['data'] as List<dynamic>?) ?? [];
  }

  Future<List<dynamic>> listGames({
    required String childId,
    required String packId,
  }) async {
    final response = await _client.get(
      Uri.parse(
        '$baseUrl/api/v1/children/$childId/learning-packs/$packId/games',
      ),
      headers: _authHeaders(),
    );

    if (response.statusCode != 200) {
      throw BackendException('List games failed: ${response.body}');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return (payload['data'] as List<dynamic>?) ?? [];
  }

  Future<Map<String, dynamic>> submitGameResult({
    required String childId,
    required String packId,
    required String gameId,
    required String gameType,
    required List<Map<String, dynamic>> results,
    required int totalQuestions,
    required int correctAnswers,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse(
              '$baseUrl/api/v1/children/$childId/learning-packs/$packId/games/$gameId/results',
            ),
            headers: _authHeaders(includeContentType: true),
            body: jsonEncode({
              'game_type': gameType,
              'results': results,
              'total_questions': totalQuestions,
              'correct_answers': correctAnswers,
              'completed_at': DateTime.now().toUtc().toIso8601String(),
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 201) {
        throw BackendException(
          'Submit game result failed: ${response.statusCode} ${response.body}',
        );
      }

      return jsonDecode(response.body) as Map<String, dynamic>;
    } on TimeoutException {
      throw BackendException('Submit game result timed out.');
    } on BackendException {
      rethrow;
    } catch (error) {
      throw BackendException('Submit game result failed: $error');
    }
  }

  Future<Map<String, dynamic>> createQuizSession({
    required String childId,
    required String packId,
    required String gameId,
    required int questionCount,
  }) async {
    final response = await _client.post(
      Uri.parse(
        '$baseUrl/api/v1/children/$childId/learning-packs/$packId/games/$gameId/quiz-sessions',
      ),
      headers: _authHeaders(includeContentType: true),
      body: jsonEncode({'question_count': questionCount}),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw BackendException('Create quiz session failed: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>?> fetchActiveQuizSession({
    required String childId,
  }) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/v1/children/$childId/quiz-sessions/active'),
      headers: _authHeaders(),
    );

    if (response.statusCode != 200) {
      throw BackendException(
        'Fetch active quiz session failed: ${response.body}',
      );
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }
    return null;
  }

  Future<Map<String, dynamic>> updateQuizSession({
    required String childId,
    required String sessionId,
    int? currentIndex,
    int? correctCount,
    List<Map<String, dynamic>>? results,
    String? status,
  }) async {
    final response = await _client.patch(
      Uri.parse('$baseUrl/api/v1/children/$childId/quiz-sessions/$sessionId'),
      headers: _authHeaders(includeContentType: true),
      body: jsonEncode({
        if (currentIndex != null) 'current_index': currentIndex,
        if (correctCount != null) 'correct_count': correctCount,
        if (results != null) 'results': results,
        if (status != null) 'status': status,
      }),
    );

    if (response.statusCode != 200) {
      throw BackendException('Update quiz session failed: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>?> fetchReviewQueue({
    required String childId,
  }) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl/api/v1/children/$childId/review-queue'),
            headers: _authHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        return null;
      }

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> listActivities({
    required String childId,
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _client.get(
      Uri.parse(
        '$baseUrl/api/v1/children/$childId/activities?page=$page&per_page=$perPage',
      ),
      headers: _authHeaders(),
    );

    if (response.statusCode != 200) {
      throw BackendException('List activities failed: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createRetryGame({
    required String childId,
    required String packId,
    required String gameId,
    required List<int> questionIndices,
  }) async {
    final response = await _client.post(
      Uri.parse(
        '$baseUrl/api/v1/children/$childId/learning-packs/$packId/games/$gameId/retry',
      ),
      headers: _authHeaders(includeContentType: true),
      body: jsonEncode({'question_indices': questionIndices}),
    );

    if (response.statusCode != 201) {
      throw BackendException('Retry game failed: ${response.body}');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return payload['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> startRevisionSession({
    required String childId,
    int limit = 5,
  }) async {
    final response = await _client.get(
      Uri.parse(
        '$baseUrl/api/v1/children/$childId/revision-session?limit=$limit',
      ),
      headers: _authHeaders(),
    );

    if (response.statusCode != 200) {
      throw BackendException('Start revision session failed: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> submitRevisionSession({
    required String childId,
    required String sessionId,
    required List<Map<String, dynamic>> results,
  }) async {
    final response = await _client.post(
      Uri.parse(
        '$baseUrl/api/v1/children/$childId/revision-session/$sessionId',
      ),
      headers: _authHeaders(includeContentType: true),
      body: jsonEncode({'results': results}),
    );

    if (response.statusCode != 200) {
      throw BackendException(
        'Submit revision session failed: ${response.body}',
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> suggestDocumentMetadata({
    required String childId,
    String? filename,
    String? contextText,
    String? ocrSnippet,
    String? languageHint,
    Uint8List? imageBytes,
    String? imageFilename,
    String? imageMimeType,
  }) async {
    if (imageBytes != null) {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(
          '$baseUrl/api/v1/children/$childId/documents/metadata-suggestions',
        ),
      );
      request.headers.addAll(_authHeaders());
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: imageFilename ?? filename ?? 'capture.jpg',
          contentType: imageMimeType == null
              ? null
              : MediaType.parse(imageMimeType),
        ),
      );
      if (filename != null && filename.isNotEmpty) {
        request.fields['filename'] = filename;
      }
      if (contextText != null && contextText.isNotEmpty) {
        request.fields['context_text'] = contextText;
      }
      if (ocrSnippet != null && ocrSnippet.isNotEmpty) {
        request.fields['ocr_snippet'] = ocrSnippet;
      }
      if (languageHint != null && languageHint.isNotEmpty) {
        request.fields['language_hint'] = languageHint;
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode != 200) {
        throw BackendException('Metadata suggestion failed: ${response.body}');
      }

      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    final response = await _client.post(
      Uri.parse(
        '$baseUrl/api/v1/children/$childId/documents/metadata-suggestions',
      ),
      headers: _authHeaders(includeContentType: true),
      body: jsonEncode({
        if (filename != null && filename.isNotEmpty) 'filename': filename,
        if (contextText != null && contextText.isNotEmpty)
          'context_text': contextText,
        if (ocrSnippet != null && ocrSnippet.isNotEmpty)
          'ocr_snippet': ocrSnippet,
        if (languageHint != null && languageHint.isNotEmpty)
          'language_hint': languageHint,
      }),
    );

    if (response.statusCode != 200) {
      throw BackendException('Metadata suggestion failed: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<dynamic>?> fetchHomeRecommendations({
    required String childId,
  }) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/api/v1/children/$childId/home-recommendations'),
        headers: _authHeaders(),
      );

      if (response.statusCode != 200) {
        return null;
      }

      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      return payload['data'] as List<dynamic>? ?? [];
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchMemoryPreferences({
    required String childId,
  }) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/api/v1/children/$childId/memory/preferences'),
        headers: _authHeaders(),
      );

      if (response.statusCode != 200) {
        return null;
      }

      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      return payload['data'] as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> updateMemoryPreferences({
    required String childId,
    bool? memoryPersonalizationEnabled,
    bool? recommendationWhyEnabled,
    String? recommendationWhyLevel,
  }) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/api/v1/children/$childId/memory/preferences'),
      headers: _authHeaders(includeContentType: true),
      body: jsonEncode({
        if (memoryPersonalizationEnabled != null)
          'memory_personalization_enabled': memoryPersonalizationEnabled,
        if (recommendationWhyEnabled != null)
          'recommendation_why_enabled': recommendationWhyEnabled,
        if (recommendationWhyLevel != null)
          'recommendation_why_level': recommendationWhyLevel,
      }),
    );

    if (response.statusCode != 200) {
      throw BackendException(
        'Update memory preferences failed: ${response.body}',
      );
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return payload['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> clearMemoryScope({
    required String childId,
    required String scope,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/v1/children/$childId/memory/clear-scope'),
      headers: _authHeaders(includeContentType: true),
      body: jsonEncode({'scope': scope}),
    );

    if (response.statusCode != 200) {
      throw BackendException('Clear memory scope failed: ${response.body}');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return payload['data'] as Map<String, dynamic>;
  }

  Future<void> trackRecommendationEvent({
    required String childId,
    required String recommendationId,
    required String recommendationType,
    required String action,
    String event = 'tap',
    Map<String, dynamic>? metadata,
  }) async {
    final response = await _client.post(
      Uri.parse(
        '$baseUrl/api/v1/children/$childId/home-recommendations/events',
      ),
      headers: _authHeaders(includeContentType: true),
      body: jsonEncode({
        'recommendation_id': recommendationId,
        'recommendation_type': recommendationType,
        'action': action,
        'event': event,
        if (metadata != null) 'metadata': metadata,
      }),
    );

    if (response.statusCode != 200) {
      throw BackendException(
        'Track recommendation event failed: ${response.body}',
      );
    }
  }

  Map<String, String> _jsonHeaders({bool includeContentType = false}) {
    return {
      'Accept': 'application/json',
      if (includeContentType) 'Content-Type': 'application/json',
    };
  }

  Map<String, String> _authHeaders({bool includeContentType = false}) {
    return {
      ..._jsonHeaders(includeContentType: includeContentType),
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  bool _shouldRetry(int statusCode, String body) {
    if (statusCode >= 500 && statusCode <= 599) {
      return true;
    }
    if (statusCode == 404) {
      return true;
    }
    return _looksLikeHtml(body);
  }

  bool _looksLikeHtml(String body) {
    final trimmed = body.trimLeft();
    return trimmed.startsWith('<!DOCTYPE html') || trimmed.startsWith('<html');
  }
}

class BackendException implements Exception {
  BackendException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;

  static BackendException fromResponse(
    String operation,
    int statusCode,
    String body,
  ) {
    String userMessage;
    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      userMessage = decoded['message']?.toString() ?? '$operation failed';
    } catch (_) {
      userMessage = '$operation failed';
    }
    return BackendException(userMessage, statusCode: statusCode);
  }
}
