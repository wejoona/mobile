import 'package:flutter/material.dart';
import 'page_transitions.dart';

/// Demo screen to showcase all transition types
///
/// This is for testing and demonstration purposes only.
/// Add this route to your router to test transitions:
///
/// ```dart
/// GoRoute(
///   path: '/transition-demo',
///   builder: (context, state) => const TransitionDemoView(),
/// ),
/// ```
class TransitionDemoView extends StatelessWidget {
  const TransitionDemoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transition Demo'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Navigation Transitions',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap each card to see different transition animations',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),

          _TransitionDemoCard(
            title: 'Horizontal Slide',
            description: 'Used for tab navigation and same-level screens',
            color: Colors.blue,
            onTap: () => _navigateWithTransition(
              context,
              'Horizontal Slide Demo',
              TransitionType.horizontalSlide,
            ),
            icon: Icons.swap_horiz,
            duration: '280ms',
          ),

          _TransitionDemoCard(
            title: 'Vertical Slide',
            description: 'Used for modals, actions, and detail views',
            color: Colors.green,
            onTap: () => _navigateWithTransition(
              context,
              'Vertical Slide Demo',
              TransitionType.verticalSlide,
            ),
            icon: Icons.arrow_upward,
            duration: '280ms',
          ),

          _TransitionDemoCard(
            title: 'Fade',
            description: 'Used for auth flows and settings sub-pages',
            color: Colors.orange,
            onTap: () => _navigateWithTransition(
              context,
              'Fade Demo',
              TransitionType.fade,
            ),
            icon: Icons.blur_on,
            duration: '200ms',
          ),

          _TransitionDemoCard(
            title: 'Scale + Fade',
            description: 'Used for success and confirmation screens',
            color: Colors.purple,
            onTap: () => _showSuccessScreen(context),
            icon: Icons.celebration,
            duration: '280ms',
          ),

          _TransitionDemoCard(
            title: 'Shared Axis',
            description: 'Material Design shared axis transition',
            color: Colors.teal,
            onTap: () => _navigateWithSharedAxis(context),
            icon: Icons.layers,
            duration: '280ms',
          ),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),

          const Text(
            'Example Navigation Flows',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          _ExampleFlowCard(
            title: 'Tab Switching',
            description: 'Home → Transactions → Settings',
            icon: Icons.tab,
            examples: const [
              '/home',
              '/transactions',
              '/settings',
            ],
          ),

          _ExampleFlowCard(
            title: 'Modal Actions',
            description: 'Open action screens from bottom',
            icon: Icons.open_in_new,
            examples: const [
              '/send',
              '/receive',
              '/deposit',
            ],
          ),

          _ExampleFlowCard(
            title: 'Settings Flow',
            description: 'Navigate settings sub-pages',
            icon: Icons.settings,
            examples: const [
              '/settings',
              '/settings/profile',
              '/settings/security',
            ],
          ),
        ],
      ),
    );
  }

  void _navigateWithTransition(
    BuildContext context,
    String title,
    TransitionType type,
  ) {
    Navigator.of(context).push(
      _createDemoPage(title, type),
    );
  }

  void _navigateWithSharedAxis(BuildContext context) {
    Navigator.of(context).push(
      _createSharedAxisPage(),
    );
  }

  void _showSuccessScreen(BuildContext context) {
    Navigator.of(context).push(
      _createSuccessPage(),
    );
  }

  PageRoute _createDemoPage(String title, TransitionType type) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        return _DemoDestination(title: title);
      },
      transitionDuration: type == TransitionType.fade
          ? const Duration(milliseconds: 200)
          : const Duration(milliseconds: 280),
      reverseTransitionDuration: type == TransitionType.fade
          ? const Duration(milliseconds: 200)
          : const Duration(milliseconds: 280),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.fastOutSlowIn,
        );

        switch (type) {
          case TransitionType.horizontalSlide:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            );

          case TransitionType.verticalSlide:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 1.0),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );

          case TransitionType.fade:
            return FadeTransition(
              opacity: animation,
              child: child,
            );

          default:
            return child;
        }
      },
    );
  }

  PageRoute _createSuccessPage() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        return const _SuccessDemo();
      },
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 280),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.fastOutSlowIn,
        );

        return ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: child,
          ),
        );
      },
    );
  }

  PageRoute _createSharedAxisPage() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        return const _DemoDestination(title: 'Shared Axis Demo');
      },
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 280),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.fastOutSlowIn,
        );

        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.3, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: child,
          ),
        );
      },
    );
  }
}

class _TransitionDemoCard extends StatelessWidget {
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;
  final IconData icon;
  final String duration;

  const _TransitionDemoCard({
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
    required this.icon,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            duration,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExampleFlowCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final List<String> examples;

  const _ExampleFlowCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.examples,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: examples.map((route) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Text(
                    route,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: Colors.blue[900],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _DemoDestination extends StatelessWidget {
  final String title;

  const _DemoDestination({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Colors.green[400],
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Notice the transition animation',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessDemo extends StatelessWidget {
  const _SuccessDemo();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green[400]!,
              Colors.green[600]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 80,
                    color: Colors.green[600],
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Success!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Scale + Fade Transition',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 48),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.green[600],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
