import 'package:flutter/material.dart';

/// An expandable/collapsible section with animated height.
class ExpandableSection extends StatefulWidget {
  final String title;
  final Widget child;
  final bool initiallyExpanded;
  final EdgeInsetsGeometry padding;
  final Widget? trailing;

  const ExpandableSection({
    super.key,
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.trailing,
  });

  @override
  State<ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<ExpandableSection>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _controller;
  late Animation<double> _heightFactor;
  late Animation<double> _rotationFactor;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _heightFactor = _controller.drive(CurveTween(curve: Curves.easeInOut));
    _rotationFactor = Tween<double>(begin: 0, end: 0.5)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (_isExpanded) _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _toggle,
          child: Padding(
            padding: widget.padding.add(
              const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (widget.trailing != null) widget.trailing!,
                RotationTransition(
                  turns: _rotationFactor,
                  child: Icon(
                    Icons.expand_more_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        ClipRect(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Align(
                heightFactor: _heightFactor.value,
                child: child,
              );
            },
            child: Padding(
              padding: widget.padding,
              child: widget.child,
            ),
          ),
        ),
      ],
    );
  }
}
