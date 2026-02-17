import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/security/risk_based_security_service.dart';
import 'package:usdc_wallet/services/liveness/liveness_service.dart';
import 'package:usdc_wallet/features/liveness/widgets/liveness_check_widget.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';

/// Dialog that handles risk-based step-up verification
/// Shows appropriate UI based on the step-up type required
class RiskStepUpDialog extends ConsumerStatefulWidget {
  final StepUpDecision decision;
  final VoidCallback onSuccess;
  final VoidCallback onCancel;

  const RiskStepUpDialog({
    super.key,
    required this.decision,
    required this.onSuccess,
    required this.onCancel,
  });

  /// Show the step-up dialog and return true if verified
  static Future<bool> show(
    BuildContext context, {
    required StepUpDecision decision,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RiskStepUpDialog(
        decision: decision,
        onSuccess: () => Navigator.pop(context, true),
        onCancel: () => Navigator.pop(context, false),
      ),
    );
    return result ?? false;
  }

  @override
  ConsumerState<RiskStepUpDialog> createState() => _RiskStepUpDialogState();
}

class _RiskStepUpDialogState extends ConsumerState<RiskStepUpDialog> {
  bool _isProcessing = false;
  bool _showLiveness = false;
  bool _showOtp = false;
  String? _error;

  // OTP
  final _otpController = TextEditingController();
  int _resendCountdown = 0;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    if (widget.decision.stepUpType == StepUpType.otp) {
      _showOtp = true;
      // Auto-send OTP on dialog open
      WidgetsBinding.instance.addPostFrameCallback((_) => _sendOtp());
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showOtp) {
      return _buildOtpView();
    }

    if (_showLiveness) {
      return _buildLivenessView();
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Flow indicator
          _buildFlowIndicator(),
          const SizedBox(height: 24),

          // Title and description
          Text(
            _getTitle(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            widget.decision.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),

          // Risk factors (optional)
          if (widget.decision.factors.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildRiskFactors(),
          ],

          // Error message
          if (_error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Action buttons
          _buildActionButtons(),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFlowIndicator() {
    final color = _getFlowColor();
    final icon = _getFlowIcon();

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 40,
        color: color,
      ),
    );
  }

  Color _getFlowColor() {
    switch (widget.decision.flow) {
      case RiskFlow.green:
        return Colors.green;
      case RiskFlow.yellow:
        return Colors.orange;
      case RiskFlow.red:
        return Colors.red;
    }
  }

  IconData _getFlowIcon() {
    switch (widget.decision.stepUpType) {
      case StepUpType.none:
        return Icons.check_circle;
      case StepUpType.biometric:
        return Icons.fingerprint;
      case StepUpType.liveness:
      case StepUpType.biometricAndLiveness:
        return Icons.face;
      case StepUpType.otp:
        return Icons.sms;
      case StepUpType.manualReview:
        return Icons.hourglass_empty;
    }
  }

  String _getTitle() {
    switch (widget.decision.stepUpType) {
      case StepUpType.none:
        return 'Transaction Approved';
      case StepUpType.biometric:
        return 'Verify Your Identity';
      case StepUpType.liveness:
        return 'Liveness Check Required';
      case StepUpType.biometricAndLiveness:
        return 'Enhanced Verification';
      case StepUpType.otp:
        return 'Enter Verification Code';
      case StepUpType.manualReview:
        return 'Manual Review Required';
    }
  }

  Widget _buildRiskFactors() {
    // Filter out technical factors, show user-friendly ones
    final displayFactors = widget.decision.factors
        .where((f) => !f.startsWith('operation:') && !f.contains('_'))
        .take(3)
        .toList();

    if (displayFactors.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Why verification is needed:',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          ...displayFactors.map((factor) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _formatFactor(factor),
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  String _formatFactor(String factor) {
    // Convert technical factors to user-friendly text
    if (factor.contains('high_value')) return 'High-value transaction';
    if (factor.contains('first_external')) return 'First transfer to this recipient';
    if (factor.contains('cross_border')) return 'International transfer';
    if (factor.contains('external_transfer')) return 'External wallet transfer';
    if (factor.contains('new_device')) return 'New device detected';
    return factor.replaceAll('_', ' ').replaceAll(':', ': ');
  }

  Widget _buildActionButtons() {
    if (widget.decision.stepUpType == StepUpType.manualReview) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: widget.onCancel,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[200],
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(AppLocalizations.of(context)!.common_close),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _handleVerify,
            style: ElevatedButton.styleFrom(
              backgroundColor: _getFlowColor(),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isProcessing
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(_getButtonText()),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _isProcessing ? null : widget.onCancel,
          child: Text(AppLocalizations.of(context)!.action_cancel),
        ),
      ],
    );
  }

  String _getButtonText() {
    switch (widget.decision.stepUpType) {
      case StepUpType.biometric:
        return 'Verify with Biometric';
      case StepUpType.liveness:
        return 'Start Liveness Check';
      case StepUpType.biometricAndLiveness:
        return 'Begin Verification';
      case StepUpType.otp:
        return 'Verify Code';
      default:
        return 'Continue';
    }
  }

  Future<void> _handleVerify() async {
    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      final securityService = ref.read(riskBasedSecurityServiceProvider);

      switch (widget.decision.stepUpType) {
        case StepUpType.biometric:
          final success = await securityService.executeStepUp(widget.decision);
          if (success) {
            widget.onSuccess();
          } else {
            setState(() => _error = 'Biometric verification failed');
          }
          break;

        case StepUpType.liveness:
          setState(() => _showLiveness = true);
          break;

        case StepUpType.biometricAndLiveness:
          // First do biometric
          final biometricOk = await securityService.executeStepUp(
            StepUpDecision(
              flow: RiskFlow.yellow,
              riskScore: widget.decision.riskScore,
              riskLevel: widget.decision.riskLevel,
              stepUpRequired: true,
              stepUpType: StepUpType.biometric,
              factors: [],
              expiresAt: widget.decision.expiresAt,
            ),
          );
          if (biometricOk) {
            setState(() => _showLiveness = true);
          } else {
            setState(() => _error = 'Biometric verification failed');
          }
          break;

        default:
          widget.onSuccess();
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted && !_showLiveness) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _sendOtp() async {
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/step-up/send-otp', data: {
        'challengeToken': widget.decision.challengeToken,
      });
      _startResendCountdown();
    } catch (e) {
      if (mounted) setState(() => _error = 'Failed to send OTP: $e');
    }
  }

  void _startResendCountdown() {
    setState(() => _resendCountdown = 60);
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
      setState(() {
        _resendCountdown--;
        if (_resendCountdown <= 0) timer.cancel();
      });
    });
  }

  Future<void> _verifyOtp(String code) async {
    setState(() { _isProcessing = true; _error = null; });
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post('/step-up/verify-otp', data: {
        'challengeToken': widget.decision.challengeToken,
        'code': code,
      });
      // ignore: avoid_dynamic_calls
      if (response.data['success'] == true && response.data['data']['valid'] == true) {
        widget.onSuccess();
      } else {
        setState(() => _error = 'Invalid OTP code');
      }
    } catch (e) {
      setState(() => _error = 'Verification failed: $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Widget _buildOtpView() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 24),
          const Icon(Icons.sms, size: 48, color: Colors.orange),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context)!.bankLinking_enterCode, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('A 6-digit code has been sent to your phone', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 24),

          // 6-digit OTP input with PIN-style boxes
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (index) {
              final hasChar = _otpController.text.length > index;
              return Container(
                width: 44, height: 52,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: hasChar ? Colors.orange : Colors.grey[300]!,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  hasChar ? _otpController.text[index] : '',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              );
            }),
          ),

          // Hidden text field for keyboard input
          SizedBox(
            height: 0,
            child: TextField(
              controller: _otpController,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
              onChanged: (value) {
                setState(() {});
                if (value.length == 6) {
                  _verifyOtp(value);
                }
              },
            ),
          ),

          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],

          if (_isProcessing) ...[
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
          ],

          const SizedBox(height: 24),

          // Resend button
          TextButton(
            onPressed: _resendCountdown > 0 ? null : _sendOtp,
            child: Text(
              _resendCountdown > 0
                  ? 'Resend code in ${_resendCountdown}s'
                  : 'Resend code',
            ),
          ),

          TextButton(
            onPressed: widget.onCancel,
            child: Text(AppLocalizations.of(context)!.action_cancel),
          ),
        ],
      ),
    );
  }

  Widget _buildLivenessView() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: LivenessCheckWidget(
        onComplete: _onLivenessComplete,
        onCancel: () {
          setState(() {
            _showLiveness = false;
            _isProcessing = false;
          });
        },
      ),
    );
  }

  Future<void> _onLivenessComplete(LivenessResult result) async {
    setState(() {
      _showLiveness = false;
    });

    if (result.isLive) {
      // Validate with backend
      try {
        final securityService = ref.read(riskBasedSecurityServiceProvider);
        final validated = await securityService.validateStepUp(
          challengeToken: widget.decision.challengeToken!,
          livenessSessionId: result.sessionId,
          biometricVerified: widget.decision.stepUpType == StepUpType.biometricAndLiveness,
        );

        if (validated) {
          widget.onSuccess();
        } else {
          setState(() => _error = 'Verification failed. Please try again.');
        }
      } catch (e) {
        setState(() => _error = 'Verification error: $e');
      }
    } else {
      setState(() => _error = 'Liveness check failed. Please try again.');
    }

    setState(() => _isProcessing = false);
  }
}

/// Extension to show risk step-up from any widget
extension RiskStepUpExtension on BuildContext {
  /// Show risk step-up dialog if required
  /// Returns true if no step-up needed or step-up succeeded
  Future<bool> handleRiskStepUp(StepUpDecision decision) async {
    if (!decision.stepUpRequired) return true;

    return await RiskStepUpDialog.show(this, decision: decision);
  }
}
