import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:second_memory/models/chat_message.dart';
import 'package:second_memory/services/api_service.dart';

void main() {
  test('SSE handles fragmented UTF-8 and trusted item records', () async {
    final record = {
      'id': 'saved-id',
      'title': 'Source',
      'url': 'https://example.com',
      'content_type': 'other',
      'tags': ['ai'],
      'created_at': '2026-01-01T00:00:00Z',
      'updated_at': '2026-01-01T00:00:00Z',
    };
    final bytes = utf8.encode(
      'data: ${jsonEncode({'type': 'text', 'content': 'مرحبا'})}\n\n'
      'data: ${jsonEncode({
        'type': 'items',
        'items': [record],
      })}\n\n'
      'data: [DONE]\n\n',
    );
    final client = MockClient.streaming((request, body) async {
      expect(request.headers['Authorization'], 'Bearer test-token');
      return http.StreamedResponse(
        Stream.fromIterable(bytes.map((b) => [b])),
        200,
      );
    });
    addTearDown(client.close);
    final chunks = await ApiService(
      client: client,
      token: 'test-token',
    ).chatStream('Find my source', [], httpClient: client).toList();
    expect(chunks[0], const ChatChunk.text(content: 'مرحبا'));
    expect((chunks[1] as ChatChunkItems).items.single.id, 'saved-id');
    expect(chunks.last, const ChatChunk.done());
  });

  test('Rate limiting is shown as a recoverable chat error', () async {
    final client = MockClient.streaming(
      (request, body) async => http.StreamedResponse(
        Stream.value(
          utf8.encode(
            '{"error_type":"rate_limit","service":"llm","retry_after":30}',
          ),
        ),
        429,
      ),
    );
    addTearDown(client.close);
    final chunks = await ApiService(
      client: client,
    ).chatStream('query', [], httpClient: client).toList();
    expect(chunks.single, isA<ChatChunkError>());
    expect((chunks.single as ChatChunkError).message, contains('30'));
  });
}
