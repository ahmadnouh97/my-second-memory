import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:second_memory/models/chat_message.dart';
import 'package:second_memory/services/chat_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  final message = ChatMessage(
    id: 'message-1',
    role: ChatRole.user,
    content: 'Private research',
    createdAt: DateTime.utc(2026, 1, 1),
  );

  test(
    'History is isolated between accounts and survives returning to an account',
    () async {
      const alice = ChatStorageService(userId: 'alice');
      const bob = ChatStorageService(userId: 'bob');
      await alice.save([message]);
      expect(await bob.load(), isEmpty);
      await bob.save([message.copyWith(id: 'bob-message')]);
      await bob.clear();
      expect(await bob.load(), isEmpty);
      expect(await alice.load(), [message]);
    },
  );

  test('Signed-out users and old unscoped history are never loaded', () async {
    SharedPreferences.setMockInitialValues({
      'chat_history': '[{"content":"legacy private data"}]',
    });
    const signedOut = ChatStorageService(userId: null);
    await signedOut.save([message]);
    expect(await signedOut.load(), isEmpty);
    expect(await const ChatStorageService(userId: 'alice').load(), isEmpty);
  });

  test('Incomplete streamed messages are not persisted', () async {
    const storage = ChatStorageService(userId: 'alice');
    await storage.save([
      message,
      message.copyWith(id: 'partial', isStreaming: true),
    ]);
    expect(await storage.load(), [message]);
  });
}
