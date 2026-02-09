// Example: How to add landscape support to a screen
//
// This file demonstrates various patterns for implementing
// landscape mode support in Flutter screens.

import 'package:flutter/material.dart';
import 'package:usdc_wallet/core/orientation/orientation_helper.dart';
import 'package:usdc_wallet/design/utils/responsive_layout.dart';
import 'package:usdc_wallet/design/tokens/index.dart';

// EXAMPLE 1: Simple Portrait/Landscape Switch
class SimpleOrientationExample extends StatelessWidget {
  const SimpleOrientationExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationLayoutBuilder(
        portrait: _buildPortraitLayout(),
        landscape: _buildLandscapeLayout(),
      ),
    );
  }

  Widget _buildPortraitLayout() {
    return Column(
      children: [
        _buildHeader(),
        _buildContent(),
        _buildActions(),
      ],
    );
  }

  Widget _buildLandscapeLayout() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildHeader(),
              _buildContent(),
            ],
          ),
        ),
        Expanded(
          child: _buildActions(),
        ),
      ],
    );
  }

  Widget _buildHeader() => Container(height: 100, color: Colors.blue);
  Widget _buildContent() => Container(height: 200, color: Colors.green);
  Widget _buildActions() => Container(height: 150, color: Colors.orange);
}

// EXAMPLE 2: Orientation + Responsive Combined
class ResponsiveOrientationExample extends StatelessWidget {
  const ResponsiveOrientationExample({super.key});

  @override
  Widget build(BuildContext context) {
    final isLandscape = OrientationHelper.isLandscape(context);
    final isTablet = ResponsiveLayout.isTabletOrLarger(context);

    // Four layout scenarios
    if (isLandscape && isTablet) {
      return _buildTabletLandscapeLayout(); // 3-column
    } else if (isLandscape) {
      return _buildMobileLandscapeLayout(); // 2-column
    } else if (isTablet) {
      return _buildTabletPortraitLayout(); // 2-column
    } else {
      return _buildMobilePortraitLayout(); // 1-column
    }
  }

  Widget _buildMobilePortraitLayout() {
    return const Column(
      children: [
        Text('Mobile Portrait - 1 Column'),
      ],
    );
  }

  Widget _buildMobileLandscapeLayout() {
    return Row(
      children: [
        const Expanded(child: Text('Mobile Landscape')),
        const Expanded(child: Text('2 Columns')),
      ],
    );
  }

  Widget _buildTabletPortraitLayout() {
    return Row(
      children: [
        const Expanded(child: Text('Tablet Portrait')),
        const Expanded(child: Text('2 Columns')),
      ],
    );
  }

  Widget _buildTabletLandscapeLayout() {
    return Row(
      children: [
        const Expanded(child: Text('Tablet Landscape')),
        const Expanded(child: Text('Column 2')),
        const Expanded(child: Text('Column 3')),
      ],
    );
  }
}

// EXAMPLE 3: Adaptive Padding
class AdaptivePaddingExample extends StatelessWidget {
  const AdaptivePaddingExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: OrientationHelper.padding(
          context,
          portrait: const EdgeInsets.all(AppSpacing.screenPadding),
          landscape: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.md,
          ),
        ),
        child: const Text('Content with adaptive padding'),
      ),
    );
  }
}

// EXAMPLE 4: Adaptive Grid
class AdaptiveGridExample extends StatelessWidget {
  const AdaptiveGridExample({super.key});

  @override
  Widget build(BuildContext context) {
    final items = List.generate(12, (index) => _buildGridItem(index));

    return Scaffold(
      body: OrientationAdaptiveGrid(
        portraitColumns: 2,
        landscapeColumns: 3,
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.md,
        children: items,
      ),
    );
  }

  Widget _buildGridItem(int index) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Center(child: Text('Item $index')),
    );
  }
}

// EXAMPLE 5: Switch Layout Direction
class SwitchLayoutExample extends StatelessWidget {
  const SwitchLayoutExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationSwitchLayout(
        spacing: AppSpacing.md,
        children: [
          Container(height: 100, color: Colors.red),
          Container(height: 100, color: Colors.green),
          Container(height: 100, color: Colors.blue),
        ],
      ),
    );
  }
}

// EXAMPLE 6: Constrained Width in Landscape
class ConstrainedWidthExample extends StatelessWidget {
  const ConstrainedWidthExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: List.generate(
            20,
            (index) => Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.md),
              color: Colors.grey.shade200,
              child: Text('Item $index - Width constrained in landscape'),
            ),
          ),
        ),
      ),
    );
  }
}

// EXAMPLE 7: Orientation-Specific Values
class OrientationValuesExample extends StatelessWidget {
  const OrientationValuesExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Get different values based on orientation
    final spacing = OrientationHelper.spacing(
      context,
      portrait: 16.0,
      landscape: 12.0,
    );

    final columns = OrientationHelper.columns(
      context,
      portraitMobile: 1,
      landscapeMobile: 2,
      portraitTablet: 2,
      landscapeTablet: 3,
    );

    final aspectRatio = OrientationHelper.aspectRatio(
      context,
      portrait: 1.5,
      landscape: 2.5,
    );

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Spacing: $spacing'),
            Text('Columns: $columns'),
            Text('Aspect Ratio: $aspectRatio'),
          ],
        ),
      ),
    );
  }
}

// EXAMPLE 8: Real-World Screen with Landscape Support
class RealWorldExample extends StatelessWidget {
  const RealWorldExample({super.key});

  @override
  Widget build(BuildContext context) {
    final isLandscape = OrientationHelper.isLandscape(context);

    return Scaffold(
      appBar: AppBar(title: const Text('My Screen')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: OrientationHelper.padding(
            context,
            portrait: const EdgeInsets.all(AppSpacing.screenPadding),
            landscape: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xxl,
              vertical: AppSpacing.md,
            ),
          ),
          child: isLandscape
              ? _buildLandscapeLayout()
              : ResponsiveBuilder(
                  mobile: _buildMobileLayout(),
                  tablet: _buildTabletLayout(),
                ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: AppSpacing.xl),
        _buildPrimaryContent(),
        const SizedBox(height: AppSpacing.xl),
        _buildSecondaryContent(),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: AppSpacing.xxl),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _buildPrimaryContent(),
            ),
            const SizedBox(width: AppSpacing.xl),
            Expanded(
              child: _buildSecondaryContent(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: AppSpacing.lg),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _buildPrimaryContent(),
            ),
            const SizedBox(width: AppSpacing.xl),
            Expanded(
              flex: 3,
              child: _buildSecondaryContent(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      color: Colors.blue.shade100,
      child: const Text('Header'),
    );
  }

  Widget _buildPrimaryContent() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      color: Colors.green.shade100,
      child: const Text('Primary Content'),
    );
  }

  Widget _buildSecondaryContent() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      color: Colors.orange.shade100,
      child: const Text('Secondary Content'),
    );
  }
}

// EXAMPLE 9: Form Layout (Vertical → Horizontal in Landscape)
class FormLayoutExample extends StatelessWidget {
  const FormLayoutExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Example')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: OrientationSwitchLayout(
          spacing: AppSpacing.md,
          children: [
            _buildInputField('First Name'),
            _buildInputField('Last Name'),
            _buildInputField('Email'),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

// EXAMPLE 10: Conditional Grid/List Based on Orientation
class ConditionalLayoutExample extends StatelessWidget {
  const ConditionalLayoutExample({super.key});

  @override
  Widget build(BuildContext context) {
    final shouldUseGrid = OrientationHelper.shouldUseTwoColumns(context);
    final items = List.generate(20, (index) => _buildItem(index));

    return Scaffold(
      appBar: AppBar(title: const Text('Conditional Layout')),
      body: shouldUseGrid
          ? GridView.count(
              crossAxisCount: OrientationHelper.gridCrossAxisCount(
                context,
                portraitMobile: 2,
                landscapeMobile: 3,
                portraitTablet: 3,
                landscapeTablet: 4,
              ),
              children: items,
            )
          : ListView(children: items),
    );
  }

  Widget _buildItem(int index) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.md),
      color: Colors.blue.shade100,
      child: Center(child: Text('Item $index')),
    );
  }
}
