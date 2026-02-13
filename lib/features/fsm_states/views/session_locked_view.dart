import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/features/pin/views/enter_pin_view.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';
import 'package:usdc_wallet/state/fsm/session_fsm.dart';
import 'package:usdc_wallet/state/fsm/app_fsm.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';
import 'package:usdc_wallet/services/storage/secure_prefs.dart';

/// Lock screen — reuses the existing EnterPinView component
/// for consistent design with the rest of the app.
class SessionLockedView extends ConsumerStatefulWidget {
  const SessionLockedView({super.key});

  @override
  ConsumerState<SessionLockedView> createState() => _SessionLockedViewState();
}

class _SessionLockedViewState extends ConsumerState<SessionLockedView> {
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final storage = ref.read(secureStorageProvider);
    final phone = await storage.read(key: StorageKeys.phone);
    if (mounted && phone != null) {
      setState(() => _userName = phone);
    }
  }

  void _unlock() {
    ref.read(authProvider.notifier).unlock();
    ref.read(appFsmProvider.notifier).dispatch(
          const AppSessionEvent(SessionUnlock()),
        );
  }

  void _logout() {
    ref.read(authProvider.notifier).logout();
    ref.read(appFsmProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Reuse the existing EnterPinView with all its components
        EnterPinView(
          title: 'Bon retour',
          subtitle: _userName != null
              ? 'Entrez votre code PIN pour continuer'
              : null,
          showBiometric: true,
          onSuccess: (_) => _unlock(),
        ),
        // Logout button in top-right
        Positioned(
          top: MediaQuery.of(context).padding.top + 12,
          right: 16,
          child: GestureDetector(
            onTap: _logout,
            child: Text(
              'Déconnexion',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
