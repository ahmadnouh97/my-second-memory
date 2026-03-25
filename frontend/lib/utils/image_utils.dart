import 'package:flutter/foundation.dart' show kIsWeb;

import '../config/environment.dart';

/// On Flutter web, browsers block cross-origin images from CDNs that don't
/// send CORS headers (e.g. Instagram's fbcdn.net). Route them through the
/// backend proxy instead. On Android the URL is used as-is.
String proxyImageUrl(String url) {
  if (!kIsWeb) return url;
  return '${Environment.baseUrl}/api/proxy/image?url=${Uri.encodeComponent(url)}';
}
