import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/chat_message.dart';

class ChatStorageService {
  static const _key = 'chat_history';
  static const _maxMessages = 50;

  Future<void> save(List<ChatMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final capped = messages.length > _maxMessages
        ? messages.sublist(messages.length - _maxMessages)
        : messages;
    final json = jsonEncode(
      capped.where((m) => !m.isStreaming).map((m) => m.toJson()).toList(),
    );
    await prefs.setString(_key, json);
  }

  Future<List<ChatMessage>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
