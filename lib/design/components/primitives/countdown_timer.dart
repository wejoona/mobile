import 'dart:async';
import 'package:flutter/material.dart';

/// A countdown timer widget for OTP expiry, session timeout, etc.
class CountdownTimer extends StatefulWidget {
  final Duration duration;
  final VoidCallback? onComplete;
  final Widget Function(Duration remaining)? builder;
  final TextStyle? style;

  const CountdownTimer({
    super.key,
    required this.duration,
    this.onComplete,
    this.builder,
    this.style,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Duration _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.duration;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining.inSeconds <= 0) {
        _timer?.cancel();
        widget.onComplete?.call();
      } else {
        setState(() {
          _remaining -= const Duration(seconds: 1);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.builder != null) {
      return widget.builder!(_remaining);
    }

    final m = _remaining.inMinutes;
    final s = _remaining.inSeconds % 60;
    final text = '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';

    final isUrgent = _remaining.inSeconds <= 30;

    return Text(
      text,
      style: widget.style ??
          Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isUrgent
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
    );
  }
}
