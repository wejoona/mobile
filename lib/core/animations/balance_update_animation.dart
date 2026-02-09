import 'package:flutter/material.dart';
import '../../design/tokens/colors.dart';
import '../../design/tokens/typography.dart';

/// Animated balance display with smooth number transitions
/// Shows increment/decrement animations with color feedback
///
/// Usage:
/// ```dart
/// AnimatedBalance(
///   balance: 1234.56,
///   currency: 'USDC',
/// )
/// ```
class AnimatedBalance extends StatefulWidget {
  final double balance;
  final String currency;
  final TextStyle? style;
  final Duration duration;
  final bool showChangeIndicator;

  const AnimatedBalance({
    super.key,
    required this.balance,
    this.currency = 'USDC',
    this.style,
    this.duration = const Duration(milliseconds: 600),
    this.showChangeIndicator = true,
  });

  @override
  State<AnimatedBalance> createState() => _AnimatedBalanceState();
}

class _AnimatedBalanceState extends State<AnimatedBalance>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousBalance = 0;
  bool _isIncreasing = false;

  @override
  void initState() {
    super.initState();
    _previousBalance = widget.balance;
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(
      begin: widget.balance,
      end: widget.balance,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void didUpdateWidget(AnimatedBalance oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.balance != widget.balance) {
      _isIncreasing = widget.balance > oldWidget.balance;
      _previousBalance = oldWidget.balance;

      _animation = Tween<double>(
        begin: oldWidget.balance,
        end: widget.balance,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutCubic,
        ),
      );

      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = widget.style ?? AppTypography.displayMedium;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final currentValue = _animation.value;
        final formattedBalance = _formatBalance(currentValue);

        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formattedBalance,
              style: textStyle.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              widget.currency,
              style: textStyle.copyWith(
                fontSize: textStyle.fontSize! * 0.5,
                color: AppColors.textSecondary,
              ),
            ),
            if (widget.showChangeIndicator && _controller.isAnimating)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: _BalanceChangeIndicator(isIncreasing: _isIncreasing),
              ),
          ],
        );
      },
    );
  }

  String _formatBalance(double balance) {
    return balance.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}

class _BalanceChangeIndicator extends StatefulWidget {
  final bool isIncreasing;

  const _BalanceChangeIndicator({
    required this.isIncreasing,
  });

  @override
  State<_BalanceChangeIndicator> createState() =>
      _BalanceChangeIndicatorState();
}

class _BalanceChangeIndicatorState extends State<_BalanceChangeIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<double>(
      begin: widget.isIncreasing ? 5.0 : -5.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Icon(
              widget.isIncreasing ? Icons.arrow_upward : Icons.arrow_downward,
              size: 16,
              color: widget.isIncreasing
                  ? AppColors.successText
                  : AppColors.errorText,
            ),
          ),
        );
      },
    );
  }
}

/// Animated counter for numerical values
class AnimatedCounter extends StatefulWidget {
  final int value;
  final TextStyle? style;
  final Duration duration;
  final String? prefix;
  final String? suffix;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 500),
    this.prefix,
    this.suffix,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = IntTween(
      begin: widget.value,
      end: widget.value,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = IntTween(
        begin: oldWidget.value,
        end: widget.value,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOut,
        ),
      );

      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          '${widget.prefix ?? ''}${_animation.value}${widget.suffix ?? ''}',
          style: widget.style ?? AppTypography.bodyMedium,
        );
      },
    );
  }
}

/// Progress indicator with smooth animation
class AnimatedProgressBar extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final double height;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Duration duration;
  final BorderRadius? borderRadius;

  const AnimatedProgressBar({
    super.key,
    required this.progress,
    this.height = 8,
    this.backgroundColor,
    this.foregroundColor,
    this.duration = const Duration(milliseconds: 600),
    this.borderRadius,
  });

  @override
  State<AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: widget.progress.clamp(0.0, 1.0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.progress.clamp(0.0, 1.0),
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutCubic,
        ),
      );

      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? AppColors.slate;
    final fgColor = widget.foregroundColor ?? AppColors.gold500;
    final radius = widget.borderRadius ??
        BorderRadius.circular(widget.height / 2);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: radius,
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _animation.value,
            child: Container(
              decoration: BoxDecoration(
                color: fgColor,
                borderRadius: radius,
              ),
            ),
          ),
        );
      },
    );
  }
}
