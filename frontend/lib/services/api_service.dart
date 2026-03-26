import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/environment.dart';
import '../models/chat_message.dart';
import '../models/item.dart';
import '../models/tag.dart';

class ApiException implements Exception {
  final int? statusCode;
  final String message;
  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  String get _base => Environment.baseUrl;

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
    final res = await _client.get(_uri(path, params),
        headers: {'Content-Type': 'application/json'});
    _check(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _post(String path, Object body) async {
    final res = await _client.post(
      _uri(path),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    _check(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _put(String path, Object body) async {
    final res = await _client.put(
      _uri(path),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    _check(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<void> _delete(String path) async {
    final res = await _client.delete(_uri(path));
    _check(res);
  }

  void _check(http.Response res) {
    if (res.statusCode >= 400) {
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
      headers: {'Content-Type': 'application/json'},
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

  // ── Tags ───────────────────────────────────────────────────────────────────

  Future<List<TagCount>> getTags() async {
    final res = await _client.get(
      _uri('/api/tags'),
      headers: {'Content-Type': 'application/json'},
    );
    _check(res);
    final list = jsonDecode(res.body) as List<dynamic>;
    return list.map((e) => TagCount.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ConsolidateResponse> previewConsolidate({double? threshold}) async {
    final json = await _post('/api/tags/consolidate/preview', {
      if (threshold != null) 'threshold': threshold,
    });
    return ConsolidateResponse.fromJson(json);
  }

  Future<ConsolidateResponse> applyConsolidate({double? threshold}) async {
    final json = await _post('/api/tags/consolidate', {
      if (threshold != null) 'threshold': threshold,
    });
    return ConsolidateResponse.fromJson(json);
  }

  // ── Chat SSE ───────────────────────────────────────────────────────────────

  Stream<ChatChunk> chatStream(
    String message,
    List<ChatMessage> history,
  ) async* {
    final client = http.Client();
    try {
      final request = http.Request('POST', _uri('/api/chat'));
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({
        'message': message,
        'history': history.map((m) {
          final rawContent = m.content;
          // Strip ITEMS_JSON from history entries before sending to backend
          final cleanContent = rawContent.contains('ITEMS_JSON:')
              ? rawContent.split('ITEMS_JSON:').first.trim()
              : rawContent;
          return {
            'role': m.role == ChatRole.user ? 'user' : 'assistant',
            'content': cleanContent,
          };
        }).toList(),
      });

      final streamed = await client.send(request);
      if (streamed.statusCode >= 400) {
        yield ChatChunk.error(message: 'Server error ${streamed.statusCode}');
        return;
      }

      String buffer = '';
      await for (final raw
          in streamed.stream.transform(utf8.decoder)) {
        buffer += raw;
        // SSE lines are separated by '\n\n'
        final parts = buffer.split('\n\n');
        buffer = parts.last; // keep incomplete chunk
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
              if (type == 'text') {
                yield ChatChunk.text(content: json['content'] as String);
              } else if (type == 'items') {
                final rawItems = json['items'] as List<dynamic>;
                final items = rawItems
                    .map((e) => Item.fromJson(e as Map<String, dynamic>))
                    .toList();
                yield ChatChunk.items(items: items);
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
      client.close();
    }
  }
}
