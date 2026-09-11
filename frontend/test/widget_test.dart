import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:second_memory/providers/items_provider.dart';
import 'package:second_memory/services/api_service.dart';
import 'package:second_memory/widgets/chat/welcome_screen.dart';

void main() {
  testWidgets('Empty library loads tags once and shows useful suggestions', (
    tester,
  ) async {
    var requests = 0;
    final client = MockClient((request) async {
      requests++;
      expect(request.url.path, '/api/tags');
      return http.Response('[]', 200);
    });
    addTearDown(client.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiServiceProvider.overrideWithValue(ApiService(client: client)),
        ],
        child: const MaterialApp(home: Scaffold(body: WelcomeScreen())),
      ),
    );
    // The welcome animation repeats, so pump bounded frames instead of settling.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(requests, 1);
    expect(find.text('Memory Assistant'), findsOneWidget);
    expect(find.text('What did I save recently?'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
