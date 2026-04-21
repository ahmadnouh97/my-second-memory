import 'package:intl/intl.dart';

String formatRelativeTime(DateTime time) {
  final now = DateTime.now();
  final diff = now.difference(time);

  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return DateFormat('HH:mm').format(time);
  if (diff.inDays == 1) return 'Yesterday ${DateFormat('HH:mm').format(time)}';
  if (diff.inDays < 7) return DateFormat('EEE HH:mm').format(time);
  return DateFormat('MMM d, HH:mm').format(time);
}
