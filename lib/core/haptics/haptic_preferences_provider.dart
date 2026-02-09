import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'haptic_service.dart';

/// State for haptic preferences
class HapticPreferencesState {
  final bool isEnabled;
  final bool isLoading;

  const HapticPreferencesState({
    required this.isEnabled,
    this.isLoading = false,
  });

  HapticPreferencesState copyWith({
    bool? isEnabled,
    bool? isLoading,
  }) {
    return HapticPreferencesState(
      isEnabled: isEnabled ?? this.isEnabled,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Notifier for managing haptic preferences
class HapticPreferencesNotifier extends Notifier<HapticPreferencesState> {
  static const _prefKey = 'haptics_enabled';

  @override
  HapticPreferencesState build() {
    _loadPreference();
    return const HapticPreferencesState(isEnabled: true);
  }

  /// Load saved preference from SharedPreferences
  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool(_prefKey) ?? true;

    state = HapticPreferencesState(isEnabled: isEnabled);
    hapticService.setEnabled(isEnabled);
  }

  /// Toggle haptic feedback on/off
  Future<void> toggle() async {
    final newValue = !state.isEnabled;
    state = state.copyWith(isLoading: true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKey, newValue);

      state = HapticPreferencesState(isEnabled: newValue);
      hapticService.setEnabled(newValue);

      // Provide feedback if haptics are being enabled
      if (newValue) {
        hapticService.toggle();
      }
    } catch (e) {
      // Revert on error
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  /// Set haptic preference explicitly
  Future<void> setEnabled(bool enabled) async {
    if (state.isEnabled == enabled) return;

    state = state.copyWith(isLoading: true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKey, enabled);

      state = HapticPreferencesState(isEnabled: enabled);
      hapticService.setEnabled(enabled);

      // Provide feedback if haptics are being enabled
      if (enabled) {
        hapticService.toggle();
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }
}

/// Provider for haptic preferences
final hapticPreferencesProvider = NotifierProvider<HapticPreferencesNotifier, HapticPreferencesState>(
  HapticPreferencesNotifier.new,
);
