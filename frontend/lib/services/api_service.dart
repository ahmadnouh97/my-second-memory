import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../config/environment.dart';
import '../models/chat_message.dart';
import '../models/item.dart';
import '../models/tag.dart';
import '../utils/error_messages.dart';

class ApiException implements Exception {
  final int? statusCode;
  final String message;
  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException() : super('Unauthorized', statusCode: 401);
}

class RateLimitException extends ApiException {
  final String? service;
  final int? retryAfter;
  const RateLimitException({
    required String message,
    this.service,
    this.retryAfter,
  }) : super(message, statusCode: 429);
}

class ApiService {
  ApiService({http.Client? client, this.token}) : _client = client ?? http.Client();

  final http.Client _client;
  final String? token;
  String get _base => Environment.baseUrl;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  // ── Helpers ────────────────────────────────────────────────────────────────

  Uri _uri(String path, [Map<String, dynamic>? params]) {
    final uri = Uri.parse('$_base$path');
    if (params == null || params.isEmpty) return uri;
    final stringParams = <String, dynamic>{};
    for (final entry in params.entries) {
      if (entry.value == null) continue;
      if (entry.value is List) {
        stringParams[entry.key] = (entry.value as List).map((e) => '$e').toList();
      } else {
        stringParams[entry.key] = '${entry.value}';
      }
    }
    return uri.replace(queryParameters: stringParams.cast<String, dynamic>());
  }

  Future<Map<String, dynamic>> _get(String path,
      [Map<String, dynamic>? params]) async {
    final res = await _client.get(_uri(path, params), headers: _headers);
    _check(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _post(String path, Object body) async {
    final res = await _client.post(
      _uri(path),
      headers: _headers,
      body: jsonEncode(body),
    );
    _check(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _put(String path, Object body) async {
    final res = await _client.put(
      _uri(path),
      headers: _headers,
      body: jsonEncode(body),
    );
    _check(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _patch(String path, Object body) async {
    final res = await _client.patch(
      _uri(path),
      headers: _headers,
      body: jsonEncode(body),
    );
    _check(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<void> _delete(String path) async {
    final res = await _client.delete(_uri(path), headers: _headers);
    _check(res);
  }

  void _check(http.Response res) {
    if (res.statusCode >= 400) {
      if (res.statusCode == 401) throw const UnauthorizedException();
      if (res.statusCode == 429) {
        String? service;
        int? retryAfter;
        String message = 'Service temporarily rate-limited. Please try again shortly.';
        try {
          final body = jsonDecode(res.body) as Map<String, dynamic>;
          if (body['error_type'] == 'rate_limit') {
            service = body['service'] as String?;
            final ra = body['retry_after'];
            retryAfter = ra is int ? ra : (ra != null ? int.tryParse('$ra') : null);
            message = rateLimitMessage(service, retryAfter);
          }
        } catch (_) {}
        throw RateLimitException(message: message, service: service, retryAfter: retryAfter);
      }
      String message = 'Request failed';
      try {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        message = body['detail']?.toString() ?? message;
      } catch (_) {}
      throw ApiException(message, statusCode: res.statusCode);
    }
  }

  // ── Items ──────────────────────────────────────────────────────────────────

  Future<ExtractPreview> extractUrl(String url) async {
    final json = await _post('/api/items/extract', {'url': url});
    return ExtractPreview.fromJson(json);
  }

  Future<Item> createItem({
    required String url,
    required String title,
    String? summary,
    required ContentType contentType,
    required List<String> tags,
    String? thumbnailUrl,
  }) async {
    final json = await _post('/api/items', {
      'url': url,
      'title': title,
      if (summary != null) 'summary': summary,
      'content_type': contentType.name,
      'tags': tags,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
    });
    return Item.fromJson(json);
  }

  Future<PaginatedResponse> listItems({
    int page = 1,
    int limit = 20,
    ContentType? contentType,
    String? dateFrom,
    String? dateTo,
    List<String>? tags,
  }) async {
    final json = await _get('/api/items', {
      'page': page,
      'limit': limit,
      if (contentType != null) 'content_type': contentType.name,
      if (dateFrom != null) 'date_from': dateFrom,
      if (dateTo != null) 'date_to': dateTo,
      if (tags != null && tags.isNotEmpty) 'tags': tags,
    });
    return PaginatedResponse.fromJson(json);
  }

  Future<List<Item>> searchItems(
    String query, {
    ContentType? contentType,
    List<String>? tags,
  }) async {
    final res = await _client.get(
      _uri('/api/items/search', {
        'q': query,
        if (contentType != null) 'content_type': contentType.name,
        if (tags != null && tags.isNotEmpty) 'tags': tags,
      }),
      headers: _headers,
    );
    _check(res);
    final decoded = jsonDecode(res.body);
    // Backend returns a plain JSON array for search
    final rawList = decoded is List
        ? decoded
        : (decoded as Map<String, dynamic>)['items'] as List? ?? [];
    return rawList
        .map((e) => Item.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Item> getItem(String id) async {
    final json = await _get('/api/items/$id');
    return Item.fromJson(json);
  }

  Future<Item> updateItem(
    String id, {
    String? title,
    String? summary,
    List<String>? tags,
    String? thumbnailUrl,
  }) async {
    final json = await _put('/api/items/$id', {
      if (title != null) 'title': title,
      if (summary != null) 'summary': summary,
      if (tags != null) 'tags': tags,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
    });
    return Item.fromJson(json);
  }

  Future<void> deleteItem(String id) => _delete('/api/items/$id');

  Future<Uint8List> exportItems(String format) async {
    final res = await _client.get(
      _uri('/api/items/export', {'format': format}),
      headers: _headers,
    );
    _check(res);
    return res.bodyBytes;
  }

  Future<int> clearAllItems() async {
    final res = await _client.delete(_uri('/api/items'), headers: _headers);
    _check(res);
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return body['deleted'] as int;
  }

  Future<ImportResult> importItems(Uint8List fileBytes, String format) async {
    final request = http.MultipartRequest(
      'POST',
      _uri('/api/items/import', {'format': format}),
    );
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      fileBytes,
      filename: 'import.$format',
    ));
    final streamed = await _client.send(request);
    final res = await http.Response.fromStream(streamed);
    _check(res);
    return ImportResult.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  // ── Tags ───────────────────────────────────────────────────────────────────

  Future<List<TagCount>> getTags() async {
    final res = await _client.get(
      _uri('/api/tags'),
      headers: _headers,
    );
    _check(res);
    final list = jsonDecode(res.body) as List<dynamic>;
    return list.map((e) => TagCount.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<TagCount> renameTag(String oldTag, String newTag) async {
    final encoded = Uri.encodeComponent(oldTag);
    final json = await _patch('/api/tags/$encoded', {'new_name': newTag});
    return TagCount.fromJson(json);
  }

  Future<void> deleteTag(String tag) async {
    final encoded = Uri.encodeComponent(tag);
    await _delete('/api/tags/$encoded');
  }

  // ── Chat SSE ───────────────────────────────────────────────────────────────

  Stream<ChatChunk> chatStream(
    String message,
    List<ChatMessage> history, {
    http.Client? httpClient,
  }) async* {
    final client = httpClient ?? http.Client();
    final ownsClient = httpClient == null;
    try {
      final request = http.Request('POST', _uri('/api/chat'));
      request.headers['Content-Type'] = 'application/json';
      if (token != null) request.headers['Authorization'] = 'Bearer $token';
      request.body = jsonEncode({
        'message': message,
        'history': history.map((m) {
          final cleanContent = m.content.contains('ITEMS_JSON:')
              ? m.content.split('ITEMS_JSON:').first.trim()
              : m.content;
          return {
            'role': m.role == ChatRole.user ? 'user' : 'assistant',
            'content': cleanContent,
          };
        }).toList(),
      });

      final streamed = await client.send(request);
      if (streamed.statusCode >= 400) {
        if (streamed.statusCode == 429) {
          String? service;
          int? retryAfter;
          try {
            final body = jsonDecode(
                    await http.Response.fromStream(streamed).then((r) => r.body))
                as Map<String, dynamic>;
            if (body['error_type'] == 'rate_limit') {
              service = body['service'] as String?;
              final ra = body['retry_after'];
              retryAfter =
                  ra is int ? ra : (ra != null ? int.tryParse('$ra') : null);
            }
          } catch (_) {}
          yield ChatChunk.error(message: rateLimitMessage(service, retryAfter));
        } else {
          yield ChatChunk.error(
              message: 'Server error ${streamed.statusCode}');
        }
        return;
      }

      String buffer = '';
      await for (final raw in streamed.stream.transform(utf8.decoder)) {
        buffer += raw;
        final parts = buffer.split('\n\n');
        buffer = parts.last;
        for (final part in parts.sublist(0, parts.length - 1)) {
          for (final line in part.split('\n')) {
            if (!line.startsWith('data: ')) continue;
            final data = line.substring(6).trim();
            if (data == '[DONE]') {
              yield const ChatChunk.done();
              return;
            }
            try {
              final json = jsonDecode(data) as Map<String, dynamic>;
              final type = json['type'] as String?;
              switch (type) {
                case 'text':
                  yield ChatChunk.text(content: json['content'] as String);
                case 'items':
                  final rawItems = json['items'] as List<dynamic>;
                  yield ChatChunk.items(
                    items: rawItems
                        .map((e) => Item.fromJson(e as Map<String, dynamic>))
                        .toList(),
                  );
                case 'tool_start':
                  yield ChatChunk.toolStart(
                      tool: json['tool'] as String? ?? '');
                case 'tool_end':
                  yield ChatChunk.toolEnd(tool: json['tool'] as String? ?? '');
                case 'thinking':
                  yield const ChatChunk.thinking();
                case 'error':
                  if (json['error_type'] == 'rate_limit') {
                    final service = json['service'] as String?;
                    final ra = json['retry_after'];
                    final retryAfter = ra is int
                        ? ra
                        : (ra != null ? int.tryParse('$ra') : null);
                    yield ChatChunk.error(
                        message: rateLimitMessage(service, retryAfter));
                  } else {
                    yield ChatChunk.error(
                        message:
                            json['message'] as String? ?? 'Unknown error');
                  }
              }
            } catch (_) {
              // skip malformed chunk
            }
          }
        }
      }
      yield const ChatChunk.done();
    } catch (e) {
      yield ChatChunk.error(message: e.toString());
    } finally {
      if (ownsClient) client.close();
    }
  }
}
