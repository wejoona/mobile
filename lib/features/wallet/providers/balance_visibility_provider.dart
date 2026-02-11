import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/storage/secure_prefs.dart';

/// Controls whether wallet balance is visible or hidden.
class BalanceVisibilityNotifier extends Notifier<bool> {
  static const _key = 'balance_visible';

  @override
  bool build() {
    _loadSaved();
    return true; // Default: visible
  }

  Future<void> _loadSaved() async {
    try {
      final prefs = ref.read(securePrefsProvider);
      final saved = await prefs.read(_key);
      if (saved != null) {
        state = saved == 'true';
      }
    } catch (_) {}
  }

  void toggle() {
    state = !state;
    _save();
  }

  void show() {
    state = true;
    _save();
  }

  void hide() {
    state = false;
    _save();
  }

  Future<void> _save() async {
    try {
      final prefs = ref.read(securePrefsProvider);
      await prefs.write(_key, state.toString());
    } catch (_) {}
  }
}

final balanceVisibilityProvider =
    NotifierProvider<BalanceVisibilityNotifier, bool>(
  BalanceVisibilityNotifier.new,
);
