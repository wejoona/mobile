import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/features/profile/providers/profile_provider.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/services/user/user_service.dart';
import 'package:usdc_wallet/state/user_state_machine.dart';

/// Email verification screen — 6-digit OTP input
class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _isSuccess = false;
  bool _hasError = false;
  bool _isCheckingStatus = true;
  bool _hasPendingCode = false;
  bool _isResending = false;
  bool _autoRequestedCode = false;
  bool _deliveryWarning = false;
  String? _errorMessage;
  String? _resendMessage;
  int _resendCountdown = 0;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    unawaited(_loadEmailStatus());
  }

  Future<void> _loadEmailStatus() async {
    try {
      final status = await ref.read(userServiceProvider).getEmailStatus();
      final verified = _readBool(status, const ['verified', 'emailVerified']);
      final pendingVerification = _readBool(status, const [
        'pendingVerification',
        'pending_verification',
      ]);
      final expiresIn = _readExpiresIn(
        _readValue(status, const ['expiresIn', 'expires_in']),
      );
      final email = (status['email'] as String?)?.trim();
      final shouldAutoRequestCode =
          !verified &&
          !pendingVerification &&
          email != null &&
          email.isNotEmpty &&
          !_autoRequestedCode;

      if (!mounted) return;
      if (verified) {
        await _markEmailVerified();
        if (!mounted) return;
      }
      setState(() {
        _isCheckingStatus = false;
        _isSuccess = verified;
        _hasPendingCode = pendingVerification;
      });
      if (pendingVerification) {
        _startResendCountdown(expiresIn);
      } else if (shouldAutoRequestCode) {
        _autoRequestedCode = true;
        unawaited(_resend());
      }
    } on Object catch (_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _isCheckingStatus = false;
        _resendCountdown = 0;
        _resendMessage = l10n.emailVerification_statusLoadFailed;
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _focusNodes) {
      n.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendCountdown([int seconds = 60]) {
    _resendCountdown = seconds.clamp(0, 30 * 60);
    _resendTimer?.cancel();
    if (_resendCountdown <= 0) {
      return;
    }
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _resendCountdown--;
        if (_resendCountdown <= 0) timer.cancel();
      });
    });
  }

  String get _otp => _controllers.map((c) => c.text).join();

  Future<void> _submit() async {
    final code = _otp;
    if (code.length != 6) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
      _resendMessage = null;
    });

    try {
      final userService = ref.read(userServiceProvider);
      final result = await userService.verifyEmail(code);
      if (!result.verified) {
        throw StateError('Email verification was not confirmed by the API.');
      }

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isSuccess = true;
      });

      await _markEmailVerified();

      // Pop back after a short delay
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) context.pop();
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = l10n.emailVerification_invalidCode;
      });
      _clearOtp();
    }
  }

  void _clearOtp() {
    for (final c in _controllers) {
      c.clear();
    }
    if (_focusNodes.isNotEmpty) _focusNodes[0].requestFocus();
  }

  Future<void> _resend() async {
    if (_isResending) return;

    setState(() {
      _isResending = true;
      _resendMessage = null;
      _deliveryWarning = false;
    });
    try {
      final userService = ref.read(userServiceProvider);
      final result = await userService.resendEmailVerification();
      if (!mounted) return;
      if (!result.pendingVerification && !result.sent) {
        final l10n = AppLocalizations.of(context)!;
        setState(() {
          _isResending = false;
          _isSuccess = true;
          _hasPendingCode = false;
          _resendMessage =
              result.message ?? l10n.emailVerification_alreadyVerified;
        });
        await _markEmailVerified();
        return;
      }

      setState(() {
        _isResending = false;
        _hasPendingCode = true;
        _deliveryWarning = !result.sent;
        _resendMessage = _emailCodeSentMessage(
          result,
          AppLocalizations.of(context)!,
        );
      });
      _startResendCountdown(result.expiresIn);
    } on Object catch (_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _isResending = false;
        _deliveryWarning = true;
        _resendMessage = l10n.emailVerification_resendFailed;
      });
    }
  }

  int _readExpiresIn(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 60;
    }
    return 60;
  }

  Object? _readValue(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      if (source.containsKey(key)) {
        return source[key];
      }
    }
    return null;
  }

  bool _readBool(Map<String, dynamic> source, List<String> keys) {
    final value = _readValue(source, keys);
    if (value is bool) return value;
    if (value is String) {
      final normalized = value.toLowerCase();
      if (normalized == 'true') return true;
      if (normalized == 'false') return false;
    }
    return false;
  }

  void _handleOtpChange(String value, int index) {
    setState(() {
      _hasError = false;
      _errorMessage = null;
    });

    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 1) {
      for (var i = 0; i < _controllers.length; i++) {
        _controllers[i].text = i < digits.length ? digits[i] : '';
      }
      final focusIndex = digits.length >= _controllers.length
          ? _controllers.length - 1
          : digits.length;
      _focusNodes[focusIndex].requestFocus();
      if (_otp.length == 6) {
        unawaited(_submit());
      }
      return;
    }

    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        unawaited(_submit());
      }
    } else if (index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  String _emailCodeSentMessage(
    EmailVerificationResendResult result,
    AppLocalizations l10n,
  ) {
    final debugCode = result.debugCode;
    if (debugCode != null && debugCode.isNotEmpty) {
      return l10n.emailVerification_codeSentDebug(debugCode);
    }
    if (!result.sent && result.message != null && result.message!.isNotEmpty) {
      return result.message!;
    }
    return l10n.emailVerification_codeSent;
  }

  Future<void> _markEmailVerified() async {
    ref
        .read(userStateMachineProvider.notifier)
        .updateProfile(emailVerified: true);

    try {
      await ref.read(profileProvider.notifier).loadProfile();
    } on Object {
      // The local verification state is already correct; the next profile
      // refresh will retry if this network sync fails.
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final userState = ref.watch(userStateMachineProvider);
    final email = userState.email ?? '';

    if (_isSuccess) {
      return _buildSuccessView(colors);
    }

    if (!_isCheckingStatus && email.trim().isEmpty) {
      return _buildMissingEmailView(colors, l10n);
    }

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: AppText(
          l10n.emailVerification_title,
          variant: AppTextVariant.titleLarge,
          color: colors.textPrimary,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),
              AppText(
                _hasPendingCode
                    ? l10n.emailVerification_enterCodeSentTo
                    : l10n.emailVerification_noActiveCodeFor,
                variant: AppTextVariant.bodyLarge,
                color: colors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.xs),
              AppText(
                email,
                variant: AppTextVariant.titleMedium,
                color: colors.textPrimary,
              ),
              const SizedBox(height: AppSpacing.xxxl),

              if (_isCheckingStatus)
                Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(colors.gold),
                  ),
                )
              else if (_hasPendingCode)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        6,
                        (i) => _buildOtpBox(i, colors),
                      ),
                    ),
                    if (_isLoading) ...[
                      const SizedBox(height: AppSpacing.lg),
                      InfoCallout(
                        icon: Icons.sync_rounded,
                        title: l10n.login_verifying,
                        tone: InfoCalloutTone.info,
                      ),
                    ],
                  ],
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: colors.elevated,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: colors.border),
                  ),
                  child: AppText(
                    l10n.emailVerification_sendCodePrompt,
                    variant: AppTextVariant.bodyMedium,
                    color: colors.textSecondary,
                    textAlign: TextAlign.center,
                  ),
                ),

              if (_errorMessage != null) ...[
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: colors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: colors.error),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: colors.errorText,
                        size: 18,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: AppText(
                          _errorMessage!,
                          variant: AppTextVariant.bodySmall,
                          color: colors.errorText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.xxl),

              // Resend
              Center(
                child: _resendCountdown > 0 && _hasPendingCode
                    ? AppText(
                        l10n.emailVerification_resendCountdown(
                          _resendCountdown,
                        ),
                        variant: AppTextVariant.bodyMedium,
                        color: colors.textSecondary,
                      )
                    : AppButton(
                        label: _hasPendingCode
                            ? l10n.emailVerification_resendCode
                            : l10n.emailVerification_sendCode,
                        onPressed: _isCheckingStatus || _isResending
                            ? null
                            : _resend,
                        variant: _hasPendingCode
                            ? AppButtonVariant.ghost
                            : AppButtonVariant.primary,
                        isLoading: _isResending,
                      ),
              ),

              if (_resendMessage != null) ...[
                const SizedBox(height: AppSpacing.md),
                if (_deliveryWarning)
                  InfoCallout(
                    icon: Icons.warning_amber_rounded,
                    title: _resendMessage!,
                    tone: InfoCalloutTone.warning,
                  )
                else
                  Center(
                    child: AppText(
                      _resendMessage!,
                      variant: AppTextVariant.bodySmall,
                      color:
                          _resendMessage ==
                                  l10n.emailVerification_statusLoadFailed ||
                              _resendMessage ==
                                  l10n.emailVerification_resendFailed
                          ? colors.errorText
                          : colors.textSecondary,
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],

              const Spacer(),

              if (_isLoading && !_hasPendingCode)
                Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(colors.gold),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index, ThemeColors colors) {
    return SizedBox(
      width: 48,
      height: 56,
      child: Container(
        decoration: BoxDecoration(
          color: colors.elevated,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: _hasError
                ? colors.error
                : _controllers[index].text.isNotEmpty
                ? colors.gold
                : colors.border,
            width: _controllers[index].text.isNotEmpty ? 2 : 1,
          ),
        ),
        child: Center(
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            autofillHints: index == 0
                ? const [AutofillHints.oneTimeCode]
                : null,
            maxLength: index == 0 ? 6 : 1,
            style: AppTypography.headlineMedium.copyWith(
              color: colors.textPrimary,
            ),
            cursorColor: colors.gold,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (value) => _handleOtpChange(value, index),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessView(ThemeColors colors) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: colors.canvas,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle, color: colors.success, size: 48),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppText(
              l10n.emailVerification_successTitle,
              variant: AppTextVariant.headlineMedium,
              color: colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.md),
            AppText(
              l10n.emailVerification_successMessage,
              variant: AppTextVariant.bodyLarge,
              color: colors.textSecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissingEmailView(ThemeColors colors, AppLocalizations l10n) {
    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: AppText(
          l10n.emailVerification_title,
          variant: AppTextVariant.titleLarge,
          color: colors.textPrimary,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: colors.goldSubtle,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.alternate_email_rounded,
                    color: colors.gold,
                    size: 34,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppText(
                l10n.emailVerification_missingEmailTitle,
                variant: AppTextVariant.headlineSmall,
                color: colors.textPrimary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppText(
                l10n.emailVerification_missingEmailMessage,
                variant: AppTextVariant.bodyMedium,
                color: colors.textSecondary,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              AppButton(
                label: l10n.emailVerification_addEmail,
                icon: Icons.edit_rounded,
                onPressed: () => context.go('/settings/profile/edit'),
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
