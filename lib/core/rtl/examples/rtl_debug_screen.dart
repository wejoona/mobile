/// RTL Debug Screen
///
/// A development-only screen to quickly test RTL layouts.
/// Add to your router during development to visually verify RTL support.
///
/// Usage:
/// ```dart
/// // In app_router.dart
/// GoRoute(
///   path: '/debug/rtl',
///   builder: (context, state) => RTLDebugScreen(),
/// ),
/// ```

import 'package:flutter/material.dart';
import '../rtl_support.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';

class RTLDebugScreen extends StatefulWidget {
  const RTLDebugScreen({super.key});

  @override
  State<RTLDebugScreen> createState() => _RTLDebugScreenState();
}

class _RTLDebugScreenState extends State<RTLDebugScreen> {
  bool _forceRTL = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // Force RTL for testing if toggle is on
    final textDirection = _forceRTL ? TextDirection.rtl : TextDirection.ltr;

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        backgroundColor: colors.canvas,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(RTLSupport.arrowBack(context)),
            onPressed: () => Navigator.pop(context),
          ),
          title: AppText(
            'RTL Debug Screen',
            variant: AppTextVariant.titleLarge,
          ),
          actions: [
            // Toggle RTL mode
            TextButton.icon(
              icon: Icon(_forceRTL ? Icons.check_box : Icons.check_box_outline_blank),
              label: Text('Force RTL'),
              onPressed: () {
                setState(() {
                  _forceRTL = !_forceRTL;
                });
              },
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsetsDirectional.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Banner
                _buildStatusBanner(context, textDirection),
                SizedBox(height: AppSpacing.xxl),

                // Test Section 1: Padding
                _buildSectionHeader('1. Directional Padding'),
                SizedBox(height: AppSpacing.md),
                _buildPaddingTest(),
                SizedBox(height: AppSpacing.xxl),

                // Test Section 2: Alignment
                _buildSectionHeader('2. Directional Alignment'),
                SizedBox(height: AppSpacing.md),
                _buildAlignmentTest(),
                SizedBox(height: AppSpacing.xxl),

                // Test Section 3: Icons
                _buildSectionHeader('3. Directional Icons'),
                SizedBox(height: AppSpacing.md),
                _buildIconTest(context),
                SizedBox(height: AppSpacing.xxl),

                // Test Section 4: Rows
                _buildSectionHeader('4. DirectionalRow'),
                SizedBox(height: AppSpacing.md),
                _buildRowTest(),
                SizedBox(height: AppSpacing.xxl),

                // Test Section 5: ListTiles
                _buildSectionHeader('5. DirectionalListTile'),
                SizedBox(height: AppSpacing.md),
                _buildListTileTest(context),
                SizedBox(height: AppSpacing.xxl),

                // Test Section 6: Text Alignment
                _buildSectionHeader('6. Text Alignment'),
                SizedBox(height: AppSpacing.md),
                _buildTextAlignmentTest(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBanner(BuildContext context, TextDirection direction) {
    final isRtl = direction == TextDirection.rtl;
    final colors = context.colors;

    return AppCard(
      variant: AppCardVariant.elevated,
      padding: EdgeInsetsDirectional.all(AppSpacing.md),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isRtl ? Icons.check_circle : Icons.warning,
                color: isRtl ? AppColors.successBase : AppColors.warningBase,
              ),
              SizedBox(width: AppSpacing.sm),
              AppText(
                isRtl ? 'RTL Mode Active' : 'LTR Mode Active',
                variant: AppTextVariant.titleMedium,
                color: isRtl ? AppColors.successBase : AppColors.warningBase,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          AppText(
            'Direction: ${direction.name.toUpperCase()}',
            variant: AppTextVariant.bodySmall,
            color: colors.textSecondary,
          ),
          SizedBox(height: AppSpacing.xs),
          AppText(
            'Locale: ${Localizations.localeOf(context).languageCode}',
            variant: AppTextVariant.bodySmall,
            color: colors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return AppText(
      title,
      variant: AppTextVariant.titleMedium,
      fontWeight: FontWeight.w700,
    );
  }

  Widget _buildPaddingTest() {
    return Column(
      children: [
        // Start padding
        Container(
          color: AppColors.gold500.withOpacity(0.1),
          padding: EdgeInsetsDirectional.only(start: AppSpacing.xl),
          child: Container(
            color: AppColors.gold500,
            height: 40,
            alignment: AlignmentDirectional.centerStart,
            child: Padding(
              padding: EdgeInsetsDirectional.all(AppSpacing.sm),
              child: AppText(
                'Start Padding (${AppSpacing.xl}px)',
                variant: AppTextVariant.bodySmall,
                color: AppColors.textInverse,
              ),
            ),
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        // End padding
        Container(
          color: AppColors.errorBase.withOpacity(0.1),
          padding: EdgeInsetsDirectional.only(end: AppSpacing.xl),
          child: Container(
            color: AppColors.errorBase,
            height: 40,
            alignment: AlignmentDirectional.centerEnd,
            child: Padding(
              padding: EdgeInsetsDirectional.all(AppSpacing.sm),
              child: AppText(
                'End Padding (${AppSpacing.xl}px)',
                variant: AppTextVariant.bodySmall,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAlignmentTest() {
    return AppCard(
      variant: AppCardVariant.elevated,
      child: Column(
        children: [
          // Center Start
          Container(
            height: 50,
            color: AppColors.gold500.withOpacity(0.1),
            alignment: AlignmentDirectional.centerStart,
            child: Padding(
              padding: EdgeInsetsDirectional.all(AppSpacing.sm),
              child: AppText(
                '← Center Start',
                variant: AppTextVariant.bodySmall,
              ),
            ),
          ),
          Divider(height: 1),
          // Center
          Container(
            height: 50,
            color: AppColors.infoBase.withOpacity(0.1),
            alignment: Alignment.center,
            child: AppText(
              '↔ Center',
              variant: AppTextVariant.bodySmall,
            ),
          ),
          Divider(height: 1),
          // Center End
          Container(
            height: 50,
            color: AppColors.errorBase.withOpacity(0.1),
            alignment: AlignmentDirectional.centerEnd,
            child: Padding(
              padding: EdgeInsetsDirectional.all(AppSpacing.sm),
              child: AppText(
                'Center End →',
                variant: AppTextVariant.bodySmall,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconTest(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.elevated,
      padding: EdgeInsetsDirectional.all(AppSpacing.md),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildIconExample(
                icon: RTLSupport.arrowBack(context),
                label: 'arrowBack()',
              ),
              _buildIconExample(
                icon: RTLSupport.arrowForward(context),
                label: 'arrowForward()',
              ),
              _buildIconExample(
                icon: context.isRTL ? Icons.chevron_left : Icons.chevron_right,
                label: 'chevron',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconExample({required IconData icon, required String label}) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: context.colors.gold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icon, color: context.colors.gold),
        ),
        SizedBox(height: AppSpacing.xs),
        AppText(
          label,
          variant: AppTextVariant.labelSmall,
          color: context.colors.textSecondary,
        ),
      ],
    );
  }

  Widget _buildRowTest() {
    return Column(
      children: [
        AppCard(
          variant: AppCardVariant.elevated,
          padding: EdgeInsetsDirectional.all(AppSpacing.md),
          child: DirectionalRow(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.gold500,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                alignment: Alignment.center,
                child: AppText(
                  '1',
                  color: AppColors.textInverse,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppText(
                  'This row auto-reverses in RTL',
                  variant: AppTextVariant.bodyMedium,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Icon(Icons.info_outline, color: context.colors.textSecondary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListTileTest(BuildContext context) {
    return Column(
      children: [
        DirectionalListTile(
          leading: Icon(Icons.settings, color: context.colors.gold),
          title: AppText('Settings'),
          trailing: Icon(
            context.isRTL ? Icons.chevron_left : Icons.chevron_right,
            color: context.colors.textSecondary,
          ),
          contentPadding: EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
        ),
        Divider(height: 1),
        DirectionalListTile(
          leading: Icon(Icons.person, color: context.colors.gold),
          title: AppText('Profile'),
          trailing: Icon(
            context.isRTL ? Icons.chevron_left : Icons.chevron_right,
            color: context.colors.textSecondary,
          ),
          contentPadding: EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
        ),
      ],
    );
  }

  Widget _buildTextAlignmentTest(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.elevated,
      padding: EdgeInsetsDirectional.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText(
            'TextAlign.start',
            textAlign: TextAlign.start,
            variant: AppTextVariant.bodyMedium,
          ),
          SizedBox(height: AppSpacing.sm),
          AppText(
            'TextAlign.center',
            textAlign: TextAlign.center,
            variant: AppTextVariant.bodyMedium,
          ),
          SizedBox(height: AppSpacing.sm),
          AppText(
            'TextAlign.end',
            textAlign: TextAlign.end,
            variant: AppTextVariant.bodyMedium,
          ),
        ],
      ),
    );
  }
}
