import 'package:flutter/material.dart';
import 'app_text.dart';
import '../../tokens/index.dart';

/// Example showcase of AppText component with theme support
/// This demonstrates all variants and semantic colors in both light and dark themes
class AppTextExample extends StatefulWidget {
  const AppTextExample({super.key});

  @override
  State<AppTextExample> createState() => _AppTextExampleState();
}

class _AppTextExampleState extends State<AppTextExample> {
  var _isDark = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _isDark ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('AppText Component Examples'),
          actions: [
            IconButton(
              icon: Icon(_isDark ? Icons.light_mode : Icons.dark_mode),
              onPressed: () => setState(() => _isDark = !_isDark),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // Display variants
            _buildSection(
              'Display Variants',
              [
                const AppText('Display Large', variant: AppTextVariant.displayLarge),
                const AppText('Display Medium', variant: AppTextVariant.displayMedium),
                const AppText('Display Small', variant: AppTextVariant.displaySmall),
              ],
            ),

            // Headline variants
            _buildSection(
              'Headline Variants',
              [
                const AppText('Headline Large', variant: AppTextVariant.headlineLarge),
                const AppText('Headline Medium', variant: AppTextVariant.headlineMedium),
                const AppText('Headline Small', variant: AppTextVariant.headlineSmall),
              ],
            ),

            // Title variants
            _buildSection(
              'Title Variants',
              [
                const AppText('Title Large', variant: AppTextVariant.titleLarge),
                const AppText('Title Medium', variant: AppTextVariant.titleMedium),
                const AppText('Title Small', variant: AppTextVariant.titleSmall),
              ],
            ),

            // Body variants
            _buildSection(
              'Body Variants',
              [
                const AppText('Body Large - Lorem ipsum dolor sit amet', variant: AppTextVariant.bodyLarge),
                const AppText('Body Medium - Lorem ipsum dolor sit amet', variant: AppTextVariant.bodyMedium),
                const AppText('Body Small - Lorem ipsum dolor sit amet', variant: AppTextVariant.bodySmall),
              ],
            ),

            // Label variants
            _buildSection(
              'Label Variants',
              [
                const AppText('Label Large', variant: AppTextVariant.labelLarge),
                const AppText('Label Medium', variant: AppTextVariant.labelMedium),
                const AppText('Label Small', variant: AppTextVariant.labelSmall),
              ],
            ),

            // Mono variants
            _buildSection(
              'Monospace Variants',
              [
                const AppText('1234567890', variant: AppTextVariant.monoLarge),
                const AppText('ABC-123-XYZ', variant: AppTextVariant.monoMedium),
                const AppText('0x1a2b3c4d', variant: AppTextVariant.monoSmall),
              ],
            ),

            // Special variants
            _buildSection(
              'Special Variants',
              [
                const AppText('\$12,345.67', variant: AppTextVariant.balance),
                const AppText('+12.5%', variant: AppTextVariant.percentage),
                const AppText('Card Label', variant: AppTextVariant.cardLabel),
              ],
            ),

            // Semantic colors
            _buildSection(
              'Semantic Colors (Theme-Aware)',
              [
                const AppText('Primary Text', semanticColor: AppTextColor.primary),
                const AppText('Secondary Text', semanticColor: AppTextColor.secondary),
                const AppText('Tertiary Text', semanticColor: AppTextColor.tertiary),
                const AppText('Disabled Text', semanticColor: AppTextColor.disabled),
                const AppText('Error Text', semanticColor: AppTextColor.error),
                const AppText('Success Text', semanticColor: AppTextColor.success),
                const AppText('Warning Text', semanticColor: AppTextColor.warning),
                const AppText('Info Text', semanticColor: AppTextColor.info),
                const AppText('Link Text', semanticColor: AppTextColor.link),
              ],
            ),

            // Text on colored backgrounds
            _buildSection(
              'Text on Colored Backgrounds',
              [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: _isDark ? AppColors.gold500 : AppColorsLight.gold500,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const AppText(
                    'Inverse Text on Gold Background',
                    semanticColor: AppTextColor.inverse,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: _isDark ? AppColors.errorBase : AppColorsLight.errorBase,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const AppText(
                    'Inverse Text on Error Background',
                    semanticColor: AppTextColor.inverse,
                  ),
                ),
              ],
            ),

            // Custom styling
            _buildSection(
              'Custom Styling',
              [
                const AppText(
                  'Bold Body Text',
                  variant: AppTextVariant.bodyLarge,
                  fontWeight: FontWeight.w700,
                ),
                const AppText(
                  'Custom Purple Color',
                  variant: AppTextVariant.titleMedium,
                  color: Colors.purple,
                ),
                const SizedBox(
                  width: 200,
                  child: AppText(
                    'Very long text that will be truncated with ellipsis when it exceeds one line',
                    variant: AppTextVariant.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            // Accessibility
            _buildSection(
              'Accessibility Examples',
              [
                const AppText(
                  '\$1,234.56',
                  variant: AppTextVariant.balance,
                  semanticLabel: 'Balance: one thousand two hundred thirty four dollars and fifty six cents',
                ),
                const AppText(
                  'Decorative Icon Text',
                  variant: AppTextVariant.labelSmall,
                  excludeSemantics: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.xl),
        AppText(
          title,
          variant: AppTextVariant.titleLarge,
          semanticColor: AppTextColor.primary,
        ),
        const Divider(height: AppSpacing.lg),
        ...children.map((child) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: child,
            )),
      ],
    );
  }
}

// Usage example:
// void main() => runApp(const AppTextExample());
