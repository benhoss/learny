import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class BackendClient {
  BackendClient({required this.baseUrl, http.Client? client})
      : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  String? token;

  Future<Map<String, dynamic>> login({required String email, required String password}) async {
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

  Future<Map<String, dynamic>> createChild({
    required String name,
    required String gradeLevel,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/v1/children'),
      headers: _authHeaders(includeContentType: true),
      body: jsonEncode({
        'name': name,
        'grade_level': gradeLevel,
      }),
    );

    if (response.statusCode != 201) {
      throw BackendException('Create child failed: ${response.body}');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return payload['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> uploadDocument({
    required String childId,
    required Uint8List bytes,
    required String filename,
    String? subject,
    String? language,
    String? gradeLevel,
    String? learningGoal,
    String? contextText,
    List<String>? requestedGameTypes,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/v1/children/$childId/documents'),
    );
    request.headers.addAll(_authHeaders());
    request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));
    if (subject != null && subject.isNotEmpty) {
      request.fields['subject'] = subject;
    }
    if (language != null && language.isNotEmpty) {
      request.fields['language'] = language;
    }
    if (gradeLevel != null && gradeLevel.isNotEmpty) {
      request.fields['grade_level'] = gradeLevel;
    }
    if (learningGoal != null && learningGoal.isNotEmpty) {
      request.fields['learning_goal'] = learningGoal;
    }
    if (contextText != null && contextText.isNotEmpty) {
      request.fields['context_text'] = contextText;
    }
    if (requestedGameTypes != null && requestedGameTypes.isNotEmpty) {
      for (var index = 0; index < requestedGameTypes.length; index += 1) {
        request.fields['requested_game_types[$index]'] = requestedGameTypes[index];
      }
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
    String? subject,
    String? language,
    String? gradeLevel,
    String? learningGoal,
    String? contextText,
    List<String>? requestedGameTypes,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/v1/children/$childId/documents'),
    );
    request.headers.addAll(_authHeaders());
    for (var index = 0; index < files.length; index += 1) {
      final filename = index < filenames.length ? filenames[index] : 'page-${index + 1}.jpg';
      request.files.add(http.MultipartFile.fromBytes('files[]', files[index], filename: filename));
    }
    if (subject != null && subject.isNotEmpty) {
      request.fields['subject'] = subject;
    }
    if (language != null && language.isNotEmpty) {
      request.fields['language'] = language;
    }
    if (gradeLevel != null && gradeLevel.isNotEmpty) {
      request.fields['grade_level'] = gradeLevel;
    }
    if (learningGoal != null && learningGoal.isNotEmpty) {
      request.fields['learning_goal'] = learningGoal;
    }
    if (contextText != null && contextText.isNotEmpty) {
      request.fields['context_text'] = contextText;
    }
    if (requestedGameTypes != null && requestedGameTypes.isNotEmpty) {
      for (var index = 0; index < requestedGameTypes.length; index += 1) {
        request.fields['requested_game_types[$index]'] = requestedGameTypes[index];
      }
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 201) {
      throw BackendException('Upload failed: ${response.body}');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return payload['data'] as Map<String, dynamic>;
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
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/v1/children/$childId/documents/$documentId/regenerate'),
      headers: _authHeaders(includeContentType: true),
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

  Future<List<dynamic>> listLearningPacks({
    required String childId,
    String? documentId,
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/children/$childId/learning-packs');
    final url = documentId == null ? uri : uri.replace(queryParameters: {'document_id': documentId});
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
      Uri.parse('$baseUrl/api/v1/children/$childId/learning-packs/$packId/games'),
      headers: _authHeaders(),
    );

    if (response.statusCode != 200) {
      throw BackendException('List games failed: ${response.body}');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return (payload['data'] as List<dynamic>?) ?? [];
  }

  Future<Map<String, dynamic>> createRetryGame({
    required String childId,
    required String packId,
    required String gameId,
    required List<int> questionIndices,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/v1/children/$childId/learning-packs/$packId/games/$gameId/retry'),
      headers: _authHeaders(includeContentType: true),
      body: jsonEncode({'question_indices': questionIndices}),
    );

    if (response.statusCode != 201) {
      throw BackendException('Retry game failed: ${response.body}');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return payload['data'] as Map<String, dynamic>;
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
}

class BackendException implements Exception {
  BackendException(this.message);

  final String message;

  @override
  String toString() => message;
}
