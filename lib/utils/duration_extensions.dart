/// Duration extension methods for human-readable formatting.
extension DurationExtensions on Duration {
  /// Format as "2h 30m", "45m", "30s", etc.
  String get humanReadable {
    if (inDays > 0) {
      final days = inDays;
      final hours = inHours % 24;
      return hours > 0 ? '${days}d ${hours}h' : '${days}d';
    }
    if (inHours > 0) {
      final hours = inHours;
      final minutes = inMinutes % 60;
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }
    if (inMinutes > 0) {
      return '${inMinutes}m';
    }
    return '${inSeconds}s';
  }

  /// Format as countdown: "02:30:00" or "05:30".
  String get countdown {
    final h = inHours;
    final m = inMinutes % 60;
    final s = inSeconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  /// "Just now", "5 minutes ago", "2 hours ago", "3 days ago".
  String get timeAgo {
    if (inSeconds < 60) return 'Just now';
    if (inMinutes < 60) {
      return '${inMinutes} minute${inMinutes == 1 ? '' : 's'} ago';
    }
    if (inHours < 24) {
      return '${inHours} hour${inHours == 1 ? '' : 's'} ago';
    }
    if (inDays < 30) {
      return '${inDays} day${inDays == 1 ? '' : 's'} ago';
    }
    final months = inDays ~/ 30;
    return '$months month${months == 1 ? '' : 's'} ago';
  }
}

/// DateTime extension for relative time.
extension DateTimeRelative on DateTime {
  /// Time elapsed since this date.
  Duration get elapsed => DateTime.now().difference(this);

  /// Human-readable time ago string.
  String get timeAgo => elapsed.timeAgo;

  /// Whether this date is today.
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Whether this date is yesterday.
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Whether this date is within the current week.
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return isAfter(startOfWeek) || isAtSameMomentAs(startOfWeek);
  }

  /// Smart date label: "Today", "Yesterday", "Mon", or "Jan 15".
  String get smartLabel {
    if (isToday) return 'Today';
    if (isYesterday) return 'Yesterday';
    if (isThisWeek) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[weekday - 1];
    }
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[month - 1]} $day';
  }
}
