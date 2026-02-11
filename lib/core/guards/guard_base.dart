/// Base class for all security guards.
abstract class GuardBase {
  /// Unique guard identifier.
  String get name;

  /// Check if the guarded action is allowed.
  Future<GuardResult> check(GuardContext context);

  /// Called when the guard blocks an action.
  Future<void> onBlocked(GuardContext context, String reason) async {}
}

class GuardContext {
  final String userId;
  final String action;
  final Map<String, dynamic> params;
  final DateTime timestamp;

  GuardContext({
    required this.userId,
    required this.action,
    this.params = const {},
  }) : timestamp = DateTime.now();
}

class GuardResult {
  final bool allowed;
  final String? reason;
  final String? redirectTo;

  const GuardResult.allow() : allowed = true, reason = null, redirectTo = null;
  const GuardResult.deny(this.reason) : allowed = false, redirectTo = null;
  const GuardResult.redirect(this.redirectTo) : allowed = false, reason = 'Redirect required';
}
