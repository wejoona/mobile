import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usdc_wallet/utils/logger.dart';
import 'package:usdc_wallet/services/analytics/analytics_service.dart';
// analyticsServiceProvider is now in analytics_service.dart

/// App Review Service Provider
final appReviewServiceProvider = Provider<AppReviewService>((ref) {
  return AppReviewService(
    analytics: ref.watch(analyticsServiceProvider),
  );
});

/// App Review State
/// Manages conditions for showing app review prompts
class AppReviewState {
  final int successfulTransactions;
  final DateTime? firstUsageDate;
  final DateTime? lastReviewPromptDate;
  final bool hasReviewed;

  const AppReviewState({
    this.successfulTransactions = 0,
    this.firstUsageDate,
    this.lastReviewPromptDate,
    this.hasReviewed = false,
  });

  AppReviewState copyWith({
    int? successfulTransactions,
    DateTime? firstUsageDate,
    DateTime? lastReviewPromptDate,
    bool? hasReviewed,
  }) {
    return AppReviewState(
      successfulTransactions:
          successfulTransactions ?? this.successfulTransactions,
      firstUsageDate: firstUsageDate ?? this.firstUsageDate,
      lastReviewPromptDate: lastReviewPromptDate ?? this.lastReviewPromptDate,
      hasReviewed: hasReviewed ?? this.hasReviewed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'successfulTransactions': successfulTransactions,
      'firstUsageDate': firstUsageDate?.toIso8601String(),
      'lastReviewPromptDate': lastReviewPromptDate?.toIso8601String(),
      'hasReviewed': hasReviewed,
    };
  }

  factory AppReviewState.fromJson(Map<String, dynamic> json) {
    return AppReviewState(
      successfulTransactions: json['successfulTransactions'] as int? ?? 0,
      firstUsageDate: json['firstUsageDate'] != null
          ? DateTime.parse(json['firstUsageDate'] as String)
          : null,
      lastReviewPromptDate: json['lastReviewPromptDate'] != null
          ? DateTime.parse(json['lastReviewPromptDate'] as String)
          : null,
      hasReviewed: json['hasReviewed'] as bool? ?? false,
    );
  }
}

/// App Review Service
/// Non-intrusive app review prompts based on user engagement
class AppReviewService {
  static const String _storageKey = 'app_review_state';
  static const int _transactionsThreshold = 5;
  static const int _usageDaysThreshold = 14;
  static const int _daysBetweenPrompts = 30;

  final InAppReview _inAppReview = InAppReview.instance;
  final AnalyticsService _analytics;
  static final _logger = AppLogger('AppReview');

  AppReviewState? _state;

  AppReviewService({
    required AnalyticsService analytics,
  }) : _analytics = analytics;

  /// Initialize the service and load state
  Future<void> initialize() async {
    try {
      await _loadState();

      // Track first usage if not set
      if (_state?.firstUsageDate == null) {
        _state = (_state ?? const AppReviewState())
            .copyWith(firstUsageDate: DateTime.now());
        await _saveState();
        _logger.info('First usage tracked');
      }
    } catch (e) {
      _logger.error('Failed to initialize app review service', e);
    }
  }

  /// Track successful transaction
  /// Call this after a transaction completes successfully
  Future<void> trackSuccessfulTransaction() async {
    try {
      await _loadState();

      _state = (_state ?? const AppReviewState()).copyWith(
        successfulTransactions:
            (_state?.successfulTransactions ?? 0) + 1,
      );
      await _saveState();

      _logger.debug(
          'Successful transactions: ${_state?.successfulTransactions}');

      // Check if we should show review prompt
      await _checkAndShowReview();
    } catch (e) {
      _logger.error('Failed to track successful transaction', e);
    }
  }

  /// Check conditions and show review prompt if appropriate
  Future<void> _checkAndShowReview() async {
    if (!await _shouldShowReview()) {
      return;
    }

    try {
      final isAvailable = await _inAppReview.isAvailable();

      if (!isAvailable) {
        _logger.warn('In-app review is not available on this device');
        return;
      }

      // Request review
      await _inAppReview.requestReview();

      // Update state
      _state = (_state ?? const AppReviewState()).copyWith(
        lastReviewPromptDate: DateTime.now(),
      );
      await _saveState();

      // Track analytics
      _analytics.setUserProperty(
        'review_prompt_shown',
        'true',
      );

      _logger.info('App review prompt shown');
    } catch (e) {
      _logger.error('Failed to show review prompt', e);
    }
  }

  /// Check if review should be shown based on conditions
  Future<bool> _shouldShowReview() async {
    await _loadState();

    final state = _state ?? const AppReviewState();

    // Don't show if user already reviewed
    if (state.hasReviewed) {
      _logger.debug('User already reviewed, skipping');
      return false;
    }

    // Check transaction threshold
    if (state.successfulTransactions < _transactionsThreshold) {
      _logger.debug(
        'Transaction threshold not met: ${state.successfulTransactions}/$_transactionsThreshold',
      );
      return false;
    }

    // Check usage duration
    if (state.firstUsageDate != null) {
      final daysSinceFirstUse =
          DateTime.now().difference(state.firstUsageDate!).inDays;
      if (daysSinceFirstUse < _usageDaysThreshold) {
        _logger.debug(
          'Usage duration threshold not met: $daysSinceFirstUse/$_usageDaysThreshold days',
        );
        return false;
      }
    }

    // Check time since last prompt
    if (state.lastReviewPromptDate != null) {
      final daysSinceLastPrompt =
          DateTime.now().difference(state.lastReviewPromptDate!).inDays;
      if (daysSinceLastPrompt < _daysBetweenPrompts) {
        _logger.debug(
          'Too soon since last prompt: $daysSinceLastPrompt/$_daysBetweenPrompts days',
        );
        return false;
      }
    }

    _logger.info('All conditions met, showing review prompt');
    return true;
  }

  /// Mark user as reviewed (manual tracking)
  /// Call this if you detect the user has left a review
  Future<void> markAsReviewed() async {
    try {
      await _loadState();

      _state = (_state ?? const AppReviewState()).copyWith(
        hasReviewed: true,
      );
      await _saveState();

      // Track analytics
      _analytics.setUserProperty(
        'user_reviewed',
        'true',
      );

      _logger.info('User marked as reviewed');
    } catch (e) {
      _logger.error('Failed to mark as reviewed', e);
    }
  }

  /// Manually open app store for review
  /// Use this for a "Rate Us" button in settings
  Future<void> openAppStore() async {
    try {
      await _inAppReview.openStoreListing();

      // Track analytics
      _analytics.setUserProperty(
        'manual_review_opened',
        'true',
      );

      _logger.info('App store opened for review');
    } catch (e) {
      _logger.error('Failed to open app store', e);
    }
  }

  /// Load state from storage
  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_storageKey);

      if (json != null) {
        final Map<String, dynamic> data = {};
        // Parse JSON string manually
        json.split(',').forEach((pair) {
          final parts = pair.split(':');
          if (parts.length == 2) {
            final key = parts[0].replaceAll(RegExp(r'[{}\"]'), '').trim();
            final value = parts[1].replaceAll(RegExp(r'[{}\"]'), '').trim();

            if (key == 'successfulTransactions') {
              data[key] = int.tryParse(value) ?? 0;
            } else if (key == 'hasReviewed') {
              data[key] = value == 'true';
            } else {
              data[key] = value == 'null' ? null : value;
            }
          }
        });

        _state = AppReviewState.fromJson(data);
        _logger.debug('State loaded from storage');
      } else {
        _state = const AppReviewState();
        _logger.debug('No previous state found, using default');
      }
    } catch (e) {
      _logger.error('Failed to load state', e);
      _state = const AppReviewState();
    }
  }

  /// Save state to storage
  Future<void> _saveState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_state != null) {
        final json = _state!.toJson().toString();
        await prefs.setString(_storageKey, json);
        _logger.debug('State saved to storage');
      }
    } catch (e) {
      _logger.error('Failed to save state', e);
    }
  }

  /// Reset all review state (for testing)
  Future<void> reset() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      _state = const AppReviewState();
      _logger.info('Review state reset');
    } catch (e) {
      _logger.error('Failed to reset state', e);
    }
  }

  /// Get current state (for debugging)
  AppReviewState? get currentState => _state;
}
