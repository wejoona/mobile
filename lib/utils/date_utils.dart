/// Date formatting utilities for the app.

/// Format relative time: "2h ago", "3d ago", "just now"
String relativeTime(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date);

  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
  if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
  return '${(diff.inDays / 365).floor()}y ago';
}

/// Format date as "Jan 15, 2026"
String formatDate(DateTime date) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

/// Format time as "3:45 PM"
String formatTime(DateTime date) {
  final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
  final period = date.hour >= 12 ? 'PM' : 'AM';
  return '$hour:${date.minute.toString().padLeft(2, '0')} $period';
}

/// Format as "Jan 15 at 3:45 PM"
String formatDateTime(DateTime date) {
  return '${formatDate(date)} at ${formatTime(date)}';
}

/// Is the date today?
bool isToday(DateTime date) {
  final now = DateTime.now();
  return date.year == now.year && date.month == now.month && date.day == now.day;
}

/// Is the date yesterday?
bool isYesterday(DateTime date) {
  final yesterday = DateTime.now().subtract(const Duration(days: 1));
  return date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day;
}

/// Smart date: "Today", "Yesterday", or "Jan 15"
String smartDate(DateTime date) {
  if (isToday(date)) return 'Today';
  if (isYesterday(date)) return 'Yesterday';
  return formatDate(date);
}

/// Convenience class wrapper for date utilities
class AppDateUtils {
  AppDateUtils._();
  static String relativeTimeFromNow(DateTime date) => relativeTime(date);
  // ignore: non_constant_identifier_names 
  static String relativeTime_(DateTime date) => relativeTime(date);
  static String format(DateTime date) => formatDate(date);
}
