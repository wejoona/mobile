import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

/// Provider to track if onboarding has been completed
final onboardingCompletedProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('onboarding_completed') ?? false;
});

/// Set onboarding as completed
Future<void> completeOnboarding() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('onboarding_completed', true);
}

class OnboardingView extends ConsumerStatefulWidget {
  const OnboardingView({super.key});

  @override
  ConsumerState<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends ConsumerState<OnboardingView>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _illustrationController;
  late AnimationController _contentController;

  static const _pages = [
    _OnboardingPageData(
      illustrationType: _IllustrationType.wallet,
      accentColor: Color(0xFFD4AF37),
      titleFr: 'Votre argent,\nsans limites',
      titleEn: 'Your money,\nwithout limits',
      subtitleFr: 'Un portefeuille USDC sécurisé pour envoyer et recevoir de l\'argent partout en Afrique de l\'Ouest.',
      subtitleEn: 'A secure USDC wallet to send and receive money across West Africa.',
      emoji: '💰',
    ),
    _OnboardingPageData(
      illustrationType: _IllustrationType.transfer,
      accentColor: Color(0xFF00C853),
      titleFr: 'Envoyez en\n3 secondes',
      titleEn: 'Send in\n3 seconds',
      subtitleFr: 'Juste un numéro de téléphone. Pas de RIB, pas d\'IBAN, pas de complications.',
      subtitleEn: 'Just a phone number. No routing numbers, no IBAN, no hassle.',
      emoji: '⚡',
    ),
    _OnboardingPageData(
      illustrationType: _IllustrationType.mobile,
      accentColor: Color(0xFF448AFF),
      titleFr: 'Orange, MTN,\nWave, Moov',
      titleEn: 'Orange, MTN,\nWave, Moov',
      subtitleFr: 'Déposez et retirez via Mobile Money. Tous vos opérateurs, un seul compte.',
      subtitleEn: 'Deposit and withdraw via Mobile Money. All your providers, one account.',
      emoji: '📱',
    ),
    _OnboardingPageData(
      illustrationType: _IllustrationType.shield,
      accentColor: Color(0xFFAA00FF),
      titleFr: 'Protégé.\nToujours.',
      titleEn: 'Protected.\nAlways.',
      subtitleFr: 'Chiffrement de bout en bout, PIN, biométrie. Votre argent dort tranquille.',
      subtitleEn: 'End-to-end encryption, PIN, biometrics. Your money sleeps safe.',
      emoji: '🛡️',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _illustrationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _illustrationController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _illustrationController.reset();
    _contentController.reset();
    _illustrationController.forward();
    _contentController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isFr = Localizations.localeOf(context).languageCode == 'fr';
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: colors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar: Skip
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
                vertical: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!isLastPage)
                    GestureDetector(
                      onTap: _completeOnboarding,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: colors.container,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isFr ? 'Passer' : 'Skip',
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return _OnboardingPageContent(
                    page: page,
                    colors: colors,
                    isFr: isFr,
                    illustrationController: _illustrationController,
                    contentController: _contentController,
                    isActive: index == _currentPage,
                  );
                },
              ),
            ),

            // Bottom section: indicators + CTA
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                0,
                AppSpacing.screenPadding,
                AppSpacing.screenPadding,
              ),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (i) {
                      final isActive = i == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 32 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: isActive
                              ? _pages[_currentPage].accentColor
                              : colors.textTertiary.withValues(alpha: 0.3),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 32),

                  // CTA Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: isLastPage
                            ? LinearGradient(
                                colors: colors.goldGradient,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: isLastPage ? null : colors.container,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _onNextPressed,
                          borderRadius: BorderRadius.circular(16),
                          child: Center(
                            child: Text(
                              isLastPage
                                  ? (isFr ? 'Commencer 🚀' : 'Get Started 🚀')
                                  : (isFr ? 'Continuer' : 'Continue'),
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: isLastPage ? colors.canvas : colors.textPrimary,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onNextPressed() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    await completeOnboarding();
    if (mounted) context.go('/login');
  }
}

// --- Page Content ---

class _OnboardingPageContent extends StatelessWidget {
  const _OnboardingPageContent({
    required this.page,
    required this.colors,
    required this.isFr,
    required this.illustrationController,
    required this.contentController,
    required this.isActive,
  });

  final _OnboardingPageData page;
  final ThemeColors colors;
  final bool isFr;
  final AnimationController illustrationController;
  final AnimationController contentController;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        children: [
          const Spacer(flex: 1),

          // Illustration area
          AnimatedBuilder(
            animation: illustrationController,
            builder: (context, child) {
              final t = CurvedAnimation(
                parent: illustrationController,
                curve: Curves.easeOutBack,
              ).value;
              return Transform.scale(
                scale: 0.7 + 0.3 * t,
                child: Opacity(
                  opacity: t.clamp(0.0, 1.0),
                  child: child,
                ),
              );
            },
            child: SizedBox(
              height: 260,
              child: _OnboardingIllustration(
                type: page.illustrationType,
                accentColor: page.accentColor,
                colors: colors,
              ),
            ),
          ),

          const Spacer(flex: 1),

          // Text content
          AnimatedBuilder(
            animation: contentController,
            builder: (context, child) {
              final t = CurvedAnimation(
                parent: contentController,
                curve: Curves.easeOut,
              ).value;
              return Transform.translate(
                offset: Offset(0, 30 * (1 - t)),
                child: Opacity(opacity: t, child: child),
              );
            },
            child: Column(
              children: [
                // Title
                Text(
                  isFr ? page.titleFr : page.titleEn,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                    height: 1.15,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 16),

                // Subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    isFr ? page.subtitleFr : page.subtitleEn,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: colors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

// --- Illustrations ---

enum _IllustrationType { wallet, transfer, mobile, shield }

class _OnboardingIllustration extends StatefulWidget {
  const _OnboardingIllustration({
    required this.type,
    required this.accentColor,
    required this.colors,
  });

  final _IllustrationType type;
  final Color accentColor;
  final ThemeColors colors;

  @override
  State<_OnboardingIllustration> createState() => _OnboardingIllustrationState();
}

class _OnboardingIllustrationState extends State<_OnboardingIllustration>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, _) {
        final floatY = math.sin(_floatController.value * math.pi) * 8;
        return Transform.translate(
          offset: Offset(0, floatY),
          child: _buildIllustration(),
        );
      },
    );
  }

  Widget _buildIllustration() {
    switch (widget.type) {
      case _IllustrationType.wallet:
        return _WalletIllustration(
          accent: widget.accentColor,
          colors: widget.colors,
        );
      case _IllustrationType.transfer:
        return _TransferIllustration(
          accent: widget.accentColor,
          colors: widget.colors,
        );
      case _IllustrationType.mobile:
        return _MobileIllustration(
          accent: widget.accentColor,
          colors: widget.colors,
        );
      case _IllustrationType.shield:
        return _ShieldIllustration(
          accent: widget.accentColor,
          colors: widget.colors,
        );
    }
  }
}

// --- Custom Painted Illustrations ---

class _WalletIllustration extends StatelessWidget {
  const _WalletIllustration({required this.accent, required this.colors});
  final Color accent;
  final ThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow ring
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                accent.withValues(alpha: 0.15),
                accent.withValues(alpha: 0.05),
                Colors.transparent,
              ],
            ),
          ),
        ),
        // Card stack
        Transform.rotate(
          angle: -0.15,
          child: _buildCard(accent.withValues(alpha: 0.3), -12),
        ),
        Transform.rotate(
          angle: -0.05,
          child: _buildCard(accent.withValues(alpha: 0.5), -4),
        ),
        _buildCard(accent, 0),
        // Dollar sign overlay
        Positioned(
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colors.canvas,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.3),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Center(
              child: Text(
                '\$',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(Color color, double yOffset) {
    return Transform.translate(
      offset: Offset(0, yOffset),
      child: Container(
        width: 180,
        height: 110,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 40,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 80,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransferIllustration extends StatelessWidget {
  const _TransferIllustration({required this.accent, required this.colors});
  final Color accent;
  final ThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Connection line
        Positioned(
          child: Container(
            width: 120,
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accent, accent.withValues(alpha: 0.2)],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        // Arrow dots
        ...List.generate(3, (i) => Positioned(
          left: 140.0 + i * 20,
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: 0.3 + i * 0.2),
            ),
          ),
        )),
        // Sender
        Positioned(
          left: 40,
          child: _buildAvatar('A', accent, colors),
        ),
        // Receiver
        Positioned(
          right: 40,
          child: _buildAvatar('B', accent, colors),
        ),
        // Center flash
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: accent,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.4),
                blurRadius: 20,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.bolt_rounded, color: Colors.white, size: 28),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(String letter, Color color, ThemeColors colors) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              letter,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 50,
          height: 4,
          decoration: BoxDecoration(
            color: colors.textTertiary.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

class _MobileIllustration extends StatelessWidget {
  const _MobileIllustration({required this.accent, required this.colors});
  final Color accent;
  final ThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                accent.withValues(alpha: 0.1),
                Colors.transparent,
              ],
            ),
          ),
        ),
        // Phone frame
        Container(
          width: 140,
          height: 240,
          decoration: BoxDecoration(
            color: colors.container,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colors.textTertiary.withValues(alpha: 0.2),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.1),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Notch
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.textTertiary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                // Operator logos
                ..._buildOperatorRows(accent, colors),
              ],
            ),
          ),
        ),
        // Floating badges
        Positioned(
          top: 20,
          right: 60,
          child: _buildBadge('Orange', const Color(0xFFFF6600), colors),
        ),
        Positioned(
          bottom: 30,
          left: 50,
          child: _buildBadge('Wave', const Color(0xFF1BA2DC), colors),
        ),
      ],
    );
  }

  List<Widget> _buildOperatorRows(Color accent, ThemeColors colors) {
    final operators = [
      ('OM', const Color(0xFFFF6600)),
      ('MTN', const Color(0xFFFFCC00)),
      ('Wave', const Color(0xFF1BA2DC)),
      ('Moov', const Color(0xFF00A651)),
    ];

    return [
      for (final op in operators) ...[
        Container(
          height: 36,
          decoration: BoxDecoration(
            color: op.$2.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const SizedBox(width: 8),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: op.$2,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    op.$1[0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: op.$2.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
        const SizedBox(height: 6),
      ],
    ];
  }

  Widget _buildBadge(String label, Color color, ThemeColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _ShieldIllustration extends StatelessWidget {
  const _ShieldIllustration({required this.accent, required this.colors});
  final Color accent;
  final ThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer rings
        ...List.generate(3, (i) {
          final size = 160.0 + i * 40;
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: accent.withValues(alpha: 0.08 + (2 - i) * 0.04),
                width: 1.5,
              ),
            ),
          );
        }),
        // Shield body
        Container(
          width: 100,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [accent, accent.withValues(alpha: 0.7)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(50),
              topRight: Radius.circular(50),
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 48,
            ),
          ),
        ),
        // Lock badge
        Positioned(
          bottom: 50,
          right: 70,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.canvas,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.2),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Icon(
              Icons.fingerprint_rounded,
              color: accent,
              size: 22,
            ),
          ),
        ),
        // Key badge
        Positioned(
          top: 40,
          left: 60,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.canvas,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.2),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Icon(
              Icons.lock_rounded,
              color: accent,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }
}

// --- Data Model ---

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.illustrationType,
    required this.accentColor,
    required this.titleFr,
    required this.titleEn,
    required this.subtitleFr,
    required this.subtitleEn,
    required this.emoji,
  });

  final _IllustrationType illustrationType;
  final Color accentColor;
  final String titleFr;
  final String titleEn;
  final String subtitleFr;
  final String subtitleEn;
  final String emoji;
}
