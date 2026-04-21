String rateLimitMessage(String? service, int? retryAfter) {
  final suffix = retryAfter != null ? ' (retry in ${retryAfter}s)' : '';
  switch (service) {
    case 'llm':
      return 'AI service is rate-limited. Please wait a moment and try again.$suffix';
    case 'embedding':
      return 'Embedding service is rate-limited. Please retry shortly.$suffix';
    default:
      return 'Service temporarily rate-limited. Please try again shortly.$suffix';
  }
}
