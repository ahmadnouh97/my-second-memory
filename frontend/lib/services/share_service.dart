import 'package:flutter/foundation.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

/// Listens for incoming Android share intents and exposes the shared URL
/// as a one-shot stream.  On web / non-Android platforms it is a no-op.
class ShareService {
  static Stream<String> get urlStream {
    if (kIsWeb) return const Stream.empty();
    return ReceiveSharingIntent.instance
        .getMediaStream()
        .asyncExpand((files) async* {
      for (final file in files) {
        final text = file.path;
        if (_isUrl(text)) yield text;
      }
    });
  }

  /// Returns the URL that launched the app from a share intent, if any.
  static Future<String?> getInitialSharedUrl() async {
    if (kIsWeb) return null;
    try {
      final files =
          await ReceiveSharingIntent.instance.getInitialMedia();
      for (final file in files) {
        if (_isUrl(file.path)) return file.path;
      }
    } catch (_) {}
    return null;
  }

  static bool _isUrl(String text) =>
      text.startsWith('http://') || text.startsWith('https://');
}
