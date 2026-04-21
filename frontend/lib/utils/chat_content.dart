/// Strips the `ITEMS_JSON: [...]` sentinel appended by the AI agent.
String stripItemsJson(String content) {
  final idx = content.indexOf('ITEMS_JSON:');
  if (idx == -1) return content;
  return content.substring(0, idx).trim();
}
