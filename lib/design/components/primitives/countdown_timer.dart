import 'dart:async';
import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/tokens/index.dart';

/// Countdown timer widget (e.g. for OTP expiry).
class CountdownTimer extends StatefulWidget {
  const CountdownTimer({
    super.key,
    required this.durationSeconds,
    this.onComplete,
    this.onResend,
    this.resendLabel = 'Resend code',
  });

  final int durationSeconds;
  final VoidCallback? onComplete;
  final VoidCallback? onResend;
  final String resendLabel;

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late int _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.durationSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining <= 0) {
        _timer?.cancel();
        widget.onComplete?.call();
      } else {
        setState(() => _remaining--);
      }
    });
  }

  void _handleResend() {
    widget.onResend?.call();
    setState(() => _remaining = widget.durationSeconds);
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = _remaining ~/ 60;
    final seconds = _remaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (_remaining > 0) {
      return Text(
        'Resend in $_formattedTime',
        style: TextStyle(
          color: colors.textSecondary,
          fontSize: 14,
        ),
      );
    }
    return GestureDetector(
      onTap: _handleResend,
      child: Text(
        widget.resendLabel,
        style: TextStyle(
          color: colors.primary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
