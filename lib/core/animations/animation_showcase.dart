import 'package:flutter/material.dart';
import '../../design/tokens/colors.dart';
import '../../design/tokens/spacing.dart';
import '../../design/tokens/typography.dart';
import '../../design/components/primitives/app_text.dart';
import '../../design/components/primitives/app_button.dart';
import 'index.dart';

/// Animation Showcase Screen
///
/// Demo screen showing all available animations
/// Access via: context.push('/animation-showcase')
///
/// Use this for:
/// - Testing animations on devices
/// - Showing stakeholders animation options
/// - Quick reference during development
class AnimationShowcase extends StatefulWidget {
  const AnimationShowcase({super.key});

  @override
  State<AnimationShowcase> createState() => _AnimationShowcaseState();
}

class _AnimationShowcaseState extends State<AnimationShowcase> {
  bool _showElements = false;
  bool _triggerShake = false;
  double _balance = 1234.56;
  int _counter = 42;

  @override
  void initState() {
    super.initState();
    // Start animations after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _showElements = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: AppText('Animation Showcase', style: AppTypography.headlineSmall),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          children: [
            _buildSection(
              'Entrance Animations',
              [
                _buildDemo(
                  'FadeSlide from Bottom',
                  FadeSlide(
                    direction: SlideDirection.fromBottom,
                    child: _buildDemoCard('Slides up & fades in'),
                  ),
                ),
                _buildDemo(
                  'FadeSlide from Top',
                  FadeSlide(
                    direction: SlideDirection.fromTop,
                    child: _buildDemoCard('Slides down & fades in'),
                  ),
                ),
                _buildDemo(
                  'FadeSlide from Left',
                  FadeSlide(
                    direction: SlideDirection.fromLeft,
                    child: _buildDemoCard('Slides right & fades in'),
                  ),
                ),
                _buildDemo(
                  'Staggered List',
                  StaggeredFadeSlide(
                    itemDelay: const Duration(milliseconds: 100),
                    children: List.generate(
                      3,
                      (i) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _buildDemoCard('Item ${i + 1}'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            _buildSection(
              'Scale Animations',
              [
                _buildDemo(
                  'ScaleIn Smooth',
                  ScaleIn(
                    scaleType: ScaleType.smooth,
                    child: _buildDemoCard('Smooth scale'),
                  ),
                ),
                _buildDemo(
                  'ScaleIn Bounce',
                  ScaleIn(
                    scaleType: ScaleType.bounceIn,
                    child: _buildDemoCard('Elastic bounce'),
                  ),
                ),
                _buildDemo(
                  'ScaleIn Spring',
                  ScaleIn(
                    scaleType: ScaleType.spring,
                    child: _buildDemoCard('Spring bounce'),
                  ),
                ),
                _buildDemo(
                  'Pulse Animation',
                  PulseAnimation(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.gold500,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.star, color: AppColors.obsidian),
                    ),
                  ),
                ),
              ],
            ),
            _buildSection(
              'Micro-Interactions',
              [
                _buildDemo(
                  'Pop Animation',
                  PopAnimation(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Popped!')),
                      );
                    },
                    child: AppButton(label: 'Press Me', onPressed: () {}),
                  ),
                ),
                _buildDemo(
                  'Shake Animation',
                  Column(
                    children: [
                      ShakeAnimation(
                        trigger: _triggerShake,
                        child: _buildDemoCard('Shake on error'),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppButton(
                        label: 'Trigger Shake',
                        variant: AppButtonVariant.secondary,
                        onPressed: () {
                          setState(() => _triggerShake = true);
                          Future.delayed(const Duration(milliseconds: 500), () {
                            if (mounted) {
                              setState(() => _triggerShake = false);
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
                _buildDemo(
                  'Glow Animation',
                  GlowAnimation(
                    glowColor: AppColors.gold500,
                    continuous: true,
                    child: Container(
                      width: 120,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.slate,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: Center(
                        child: AppText('Glowing', style: AppTypography.bodyMedium),
                      ),
                    ),
                  ),
                ),
                _buildDemo(
                  'Success Checkmark',
                  SuccessCheckmark(
                    size: 80,
                    color: AppColors.successText,
                  ),
                ),
              ],
            ),
            _buildSection(
              'Balance & Numbers',
              [
                _buildDemo(
                  'Animated Balance',
                  Column(
                    children: [
                      AnimatedBalance(
                        balance: _balance,
                        currency: 'USDC',
                        style: AppTypography.displaySmall,
                        showChangeIndicator: true,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppButton(
                            label: 'Add \$100',
                            size: AppButtonSize.small,
                            onPressed: () {
                              setState(() => _balance += 100);
                            },
                          ),
                          const SizedBox(width: AppSpacing.md),
                          AppButton(
                            label: 'Remove \$50',
                            variant: AppButtonVariant.secondary,
                            size: AppButtonSize.small,
                            onPressed: () {
                              setState(() => _balance -= 50);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildDemo(
                  'Animated Counter',
                  Column(
                    children: [
                      AnimatedCounter(
                        value: _counter,
                        prefix: '+',
                        suffix: ' transactions',
                        style: AppTypography.headlineMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppButton(
                        label: 'Increment',
                        size: AppButtonSize.small,
                        onPressed: () {
                          setState(() => _counter += 5);
                        },
                      ),
                    ],
                  ),
                ),
                _buildDemo(
                  'Animated Progress Bar',
                  Column(
                    children: [
                      const AnimatedProgressBar(
                        progress: 0.3,
                        height: 8,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const AnimatedProgressBar(
                        progress: 0.65,
                        height: 8,
                        foregroundColor: AppColors.successBase,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const AnimatedProgressBar(
                        progress: 0.9,
                        height: 8,
                        foregroundColor: AppColors.warningBase,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            _buildSection(
              'Loading States',
              [
                _buildDemo(
                  'Skeleton Lines',
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonLine(height: 16, width: 200),
                      SizedBox(height: AppSpacing.sm),
                      SkeletonLine(height: 16, width: 150),
                      SizedBox(height: AppSpacing.sm),
                      SkeletonLine(height: 16, width: 180),
                    ],
                  ),
                ),
                _buildDemo(
                  'Skeleton Circle',
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SkeletonCircle(size: 40),
                      SkeletonCircle(size: 60),
                      SkeletonCircle(size: 80),
                    ],
                  ),
                ),
                _buildDemo(
                  'Skeleton Card',
                  const SkeletonCard(height: 120),
                ),
                _buildDemo(
                  'Skeleton Transaction',
                  const SkeletonTransactionItem(),
                ),
                _buildDemo(
                  'Skeleton Balance Card',
                  const SkeletonBalanceCard(),
                ),
              ],
            ),
            _buildSection(
              'Reveal Animations',
              [
                _buildDemo(
                  'Slide Reveal',
                  Column(
                    children: [
                      AppButton(
                        label: _showElements ? 'Hide Panel' : 'Show Panel',
                        onPressed: () {
                          setState(() => _showElements = !_showElements);
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SlideReveal(
                        isRevealed: _showElements,
                        revealDirection: RevealDirection.fromRight,
                        child: _buildDemoCard('Revealed content!'),
                      ),
                    ],
                  ),
                ),
                _buildDemo(
                  'Expandable Content',
                  ExpandableContent(
                    isExpanded: _showElements,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      color: AppColors.slate,
                      child: AppText(
                        'This content expands and collapses smoothly',
                        style: AppTypography.bodyMedium,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            _buildSection(
              'Combined Effects',
              [
                _buildDemo(
                  'Hero Card',
                  FadeSlide(
                    child: GlowAnimation(
                      continuous: true,
                      glowColor: AppColors.gold500,
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.cardPaddingLarge),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: AppColors.goldGradient,
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                        ),
                        child: Column(
                          children: [
                            AppText(
                              'Premium Card',
                              style: AppTypography.headlineMedium,
                            ),
                            SizedBox(height: AppSpacing.sm),
                            AppText(
                              'Fade + Slide + Glow',
                              style: AppTypography.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> demos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.xxl,
            bottom: AppSpacing.lg,
          ),
          child: AppText(
            title,
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.gold500,
            ),
          ),
        ),
        ...demos,
      ],
    );
  }

  Widget _buildDemo(String label, Widget widget) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            label,
            style: AppTypography.titleSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          widget,
        ],
      ),
    );
  }

  Widget _buildDemoCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.slate,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.gold500.withOpacity(0.2),
        ),
      ),
      child: AppText(
        text,
        style: AppTypography.bodyMedium,
        textAlign: TextAlign.center,
      ),
    );
  }
}
