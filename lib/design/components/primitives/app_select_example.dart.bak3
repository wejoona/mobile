import 'package:flutter/material.dart';
import 'app_select.dart';
import '../../tokens/index.dart';

/// AppSelect Component Usage Examples
///
/// This file demonstrates various use cases for the AppSelect component
/// with the luxury dark theme and gold accents.

class AppSelectExamples extends StatefulWidget {
  const AppSelectExamples({super.key});

  @override
  State<AppSelectExamples> createState() => _AppSelectExamplesState();
}

class _AppSelectExamplesState extends State<AppSelectExamples> {
  String? _selectedCountry;
  String? _selectedCurrency;
  String? _selectedIdType;
  int? _selectedPeriod;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: const Text('AppSelect Examples'),
        backgroundColor: AppColors.slate,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Example 1: Basic select with icons
            _buildSectionTitle('Basic Select with Icons'),
            const SizedBox(height: AppSpacing.md),
            AppSelect<String>(
              label: 'Country',
              value: _selectedCountry,
              hint: 'Select your country',
              items: const [
                AppSelectItem(
                  value: 'us',
                  label: 'United States',
                  icon: Icons.flag,
                ),
                AppSelectItem(
                  value: 'ci',
                  label: 'Côte d\'Ivoire',
                  icon: Icons.flag,
                ),
                AppSelectItem(
                  value: 'fr',
                  label: 'France',
                  icon: Icons.flag,
                ),
              ],
              onChanged: (value) => setState(() => _selectedCountry = value),
            ),
            const SizedBox(height: AppSpacing.xxxl),

            // Example 2: Select with prefix icon
            _buildSectionTitle('Select with Prefix Icon'),
            const SizedBox(height: AppSpacing.md),
            AppSelect<String>(
              label: 'Currency',
              value: _selectedCurrency,
              hint: 'Select currency',
              prefixIcon: Icons.attach_money,
              items: const [
                AppSelectItem(
                  value: 'usd',
                  label: 'US Dollar (USD)',
                  subtitle: 'United States',
                ),
                AppSelectItem(
                  value: 'xof',
                  label: 'West African CFA Franc (XOF)',
                  subtitle: 'West African nations',
                ),
                AppSelectItem(
                  value: 'eur',
                  label: 'Euro (EUR)',
                  subtitle: 'European Union',
                ),
              ],
              onChanged: (value) => setState(() => _selectedCurrency = value),
            ),
            const SizedBox(height: AppSpacing.xxxl),

            // Example 3: Select with subtitles
            _buildSectionTitle('Select with Subtitles'),
            const SizedBox(height: AppSpacing.md),
            AppSelect<String>(
              label: 'Document Type',
              value: _selectedIdType,
              hint: 'Choose ID type',
              items: const [
                AppSelectItem(
                  value: 'passport',
                  label: 'Passport',
                  subtitle: 'International travel document',
                  icon: Icons.menu_book,
                ),
                AppSelectItem(
                  value: 'national_id',
                  label: 'National ID Card',
                  subtitle: 'Government-issued identification',
                  icon: Icons.credit_card,
                ),
                AppSelectItem(
                  value: 'drivers_license',
                  label: 'Driver\'s License',
                  subtitle: 'Valid driving permit',
                  icon: Icons.drive_eta,
                ),
              ],
              onChanged: (value) => setState(() => _selectedIdType = value),
            ),
            const SizedBox(height: AppSpacing.xxxl),

            // Example 4: Select without checkmarks
            _buildSectionTitle('Select without Checkmarks'),
            const SizedBox(height: AppSpacing.md),
            AppSelect<int>(
              label: 'Analytics Period',
              value: _selectedPeriod,
              hint: 'Select period',
              showCheckmark: false,
              items: const [
                AppSelectItem(
                  value: 1,
                  label: 'Today',
                  icon: Icons.today,
                ),
                AppSelectItem(
                  value: 7,
                  label: 'This Week',
                  icon: Icons.date_range,
                ),
                AppSelectItem(
                  value: 30,
                  label: 'This Month',
                  icon: Icons.calendar_month,
                ),
                AppSelectItem(
                  value: 365,
                  label: 'This Year',
                  icon: Icons.calendar_today,
                ),
              ],
              onChanged: (value) => setState(() => _selectedPeriod = value),
            ),
            const SizedBox(height: AppSpacing.xxxl),

            // Example 5: Disabled select
            _buildSectionTitle('Disabled State'),
            const SizedBox(height: AppSpacing.md),
            AppSelect<String>(
              label: 'Disabled Select',
              value: null,
              hint: 'Not available',
              enabled: false,
              items: const [
                AppSelectItem(value: 'option1', label: 'Option 1'),
                AppSelectItem(value: 'option2', label: 'Option 2'),
              ],
              onChanged: (_) {},
            ),
            const SizedBox(height: AppSpacing.xxxl),

            // Example 6: Select with error
            _buildSectionTitle('Error State'),
            const SizedBox(height: AppSpacing.md),
            AppSelect<String>(
              label: 'Required Field',
              value: null,
              hint: 'Please select an option',
              error: 'This field is required',
              items: const [
                AppSelectItem(value: 'option1', label: 'Option 1'),
                AppSelectItem(value: 'option2', label: 'Option 2'),
              ],
              onChanged: (_) {},
            ),
            const SizedBox(height: AppSpacing.xxxl),

            // Example 7: Select with helper text
            _buildSectionTitle('Helper Text'),
            const SizedBox(height: AppSpacing.md),
            AppSelect<String>(
              label: 'Payment Method',
              value: null,
              hint: 'Choose payment method',
              helper: 'Select how you want to receive payments',
              items: const [
                AppSelectItem(
                  value: 'bank',
                  label: 'Bank Transfer',
                  icon: Icons.account_balance,
                ),
                AppSelectItem(
                  value: 'mobile',
                  label: 'Mobile Money',
                  icon: Icons.phone_android,
                ),
              ],
              onChanged: (_) {},
            ),
            const SizedBox(height: AppSpacing.xxxl),

            // Code example
            _buildCodeExample(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.gold500,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildCodeExample() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.elevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Usage Example:',
            style: TextStyle(
              color: AppColors.gold500,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            '''
AppSelect<String>(
  label: 'Country',
  value: _selectedCountry,
  hint: 'Select your country',
  items: const [
    AppSelectItem(
      value: 'us',
      label: 'United States',
      icon: Icons.flag,
      subtitle: 'Optional subtitle',
    ),
    // More items...
  ],
  onChanged: (value) {
    setState(() => _selectedCountry = value);
  },
  // Optional parameters:
  error: 'Error message',
  helper: 'Helper text',
  enabled: true,
  prefixIcon: Icons.icon_name,
  showCheckmark: true,
)
            ''',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
