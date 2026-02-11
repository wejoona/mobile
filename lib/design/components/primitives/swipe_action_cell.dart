import 'package:flutter/material.dart';

/// A list cell with swipe-to-reveal action buttons.
class SwipeActionCell extends StatefulWidget {
  final Widget child;
  final List<SwipeAction> actions;
  final double actionWidth;
  final VoidCallback? onTap;

  const SwipeActionCell({
    super.key,
    required this.child,
    required this.actions,
    this.actionWidth = 72,
    this.onTap,
  });

  @override
  State<SwipeActionCell> createState() => _SwipeActionCellState();
}

class _SwipeActionCellState extends State<SwipeActionCell>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  double _dragExtent = 0;

  double get _maxSlide => widget.actionWidth * widget.actions.length;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _dragExtent = (_dragExtent + details.delta.dx).clamp(-_maxSlide, 0);
    _slideAnimation = AlwaysStoppedAnimation(
      Offset(_dragExtent / MediaQuery.of(context).size.width, 0),
    );
    setState(() {});
  }

  void _onDragEnd(DragEndDetails details) {
    if (_dragExtent.abs() > _maxSlide / 2) {
      // Snap open
      _slideAnimation = Tween<Offset>(
        begin: Offset(_dragExtent / MediaQuery.of(context).size.width, 0),
        end: Offset(-_maxSlide / MediaQuery.of(context).size.width, 0),
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _dragExtent = -_maxSlide;
    } else {
      // Snap closed
      _slideAnimation = Tween<Offset>(
        begin: Offset(_dragExtent / MediaQuery.of(context).size.width, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _dragExtent = 0;
    }
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Action buttons
        Positioned.fill(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: widget.actions.map((action) {
              return SizedBox(
                width: widget.actionWidth,
                child: Material(
                  color: action.color,
                  child: InkWell(
                    onTap: () {
                      action.onTap();
                      _dragExtent = 0;
                      setState(() {
                        _slideAnimation =
                            const AlwaysStoppedAnimation(Offset.zero);
                      });
                    },
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(action.icon, color: Colors.white, size: 20),
                          const SizedBox(height: 4),
                          Text(
                            action.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        // Content
        GestureDetector(
          onHorizontalDragUpdate: _onDragUpdate,
          onHorizontalDragEnd: _onDragEnd,
          onTap: widget.onTap,
          child: SlideTransition(
            position: _slideAnimation,
            child: widget.child,
          ),
        ),
      ],
    );
  }
}

/// A swipe action button.
class SwipeAction {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const SwipeAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
