import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';

/// PIN Dots Widget
/// Shows 6 dots representing PIN entry state
class PinDots extends StatefulWidget {
  final int length;
  final int filledCount;
  final bool showError;

  const PinDots({
    super.key,
    this.length = 6,
    required this.filledCount,
    this.showError = false,
  });

  @override
  State<PinDots> createState() => _PinDotsState();
}

class _PinDotsState extends State<PinDots> with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void didUpdateWidget(PinDots oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showError && !oldWidget.showError) {
      _shake();
    }
  }

  void _shake() {
    _shakeController.forward(from: 0).then((_) {
      _shakeController.reverse();
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value * (widget.showError ? 1 : 0), 0),
          child: SecurityCodeDots(
            length: widget.length,
            filled: widget.filledCount,
            error: widget.showError,
          ),
        );
      },
    );
  }
}
