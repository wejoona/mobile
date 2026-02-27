import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/features/liveness/widgets/liveness_check_widget.dart';
import 'package:usdc_wallet/services/liveness/liveness_service.dart';

/// Standalone liveness check view — wraps [LivenessCheckWidget].
/// For KYC-specific liveness, see [KycLivenessView].
class LivenessCheckView extends ConsumerStatefulWidget {
  const LivenessCheckView({super.key});

  @override
  ConsumerState<LivenessCheckView> createState() => _LivenessCheckViewState();
}

class _LivenessCheckViewState extends ConsumerState<LivenessCheckView> {
  bool _isComplete = false;
  String? _errorMessage;

  void _onComplete(LivenessResult result) {
    if (result.isLive) {
      setState(() => _isComplete = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) context.pop(true);
      });
    } else {
      setState(() {
        _errorMessage = result.failureReason ??
            AppLocalizations.of(context)!.liveness_failed;
      });
    }
  }

  void _onCancel() {
    context.pop(false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isComplete) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, size: 80, color: Colors.green),
              const SizedBox(height: 16),
              Text(AppLocalizations.of(context)!.liveness_title),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 80, color: Colors.red),
              const SizedBox(height: 16),
              Text(_errorMessage!),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => setState(() => _errorMessage = null),
                child: Text(AppLocalizations.of(context)!.liveness_tryAgain),
              ),
              TextButton(
                onPressed: _onCancel,
                child: Text(AppLocalizations.of(context)!.liveness_goBack),
              ),
            ],
          ),
        ),
      );
    }

    return LivenessCheckWidget(
      onComplete: _onComplete,
      onCancel: _onCancel,
    );
  }
}
