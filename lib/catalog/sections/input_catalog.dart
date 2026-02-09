import 'package:flutter/material.dart';
import 'package:usdc_wallet/catalog/widget_catalog_view.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';

class InputCatalog extends StatefulWidget {
  const InputCatalog({super.key});

  @override
  State<InputCatalog> createState() => _InputCatalogState();
}

class _InputCatalogState extends State<InputCatalog> {
  final _standardController = TextEditingController();
  final _errorController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  final _amountController = TextEditingController();
  final _searchController = TextEditingController();
  final _passwordController = TextEditingController();
  final _multilineController = TextEditingController();

  @override
  void dispose() {
    _standardController.dispose();
    _errorController.dispose();
    _phoneController.dispose();
    _pinController.dispose();
    _amountController.dispose();
    _searchController.dispose();
    _passwordController.dispose();
    _multilineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CatalogSection(
          title: 'Variants',
          description: 'Different input types with specialized formatting',
          children: [
            DemoCard(
              label: 'Standard Input',
              child: AppInput(
                controller: _standardController,
                label: 'Full Name',
                hint: 'Enter your name',
                helper: 'Your legal name as it appears on ID',
              ),
            ),
            DemoCard(
              label: 'Phone Input',
              child: AppInput(
                controller: _phoneController,
                variant: AppInputVariant.phone,
                label: 'Phone Number',
                hint: '0X XX XX XX XX',
              ),
            ),
            DemoCard(
              label: 'PIN Input',
              child: AppInput(
                controller: _pinController,
                variant: AppInputVariant.pin,
                label: 'PIN Code',
                hint: '000000',
                maxLength: 6,
                obscureText: true,
              ),
            ),
            DemoCard(
              label: 'Amount Input',
              child: AppInput(
                controller: _amountController,
                variant: AppInputVariant.amount,
                label: 'Amount',
                hint: '0.00',
                prefix: const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: AppText('XOF', variant: AppTextVariant.bodyLarge),
                ),
              ),
            ),
            DemoCard(
              label: 'Search Input',
              child: AppInput(
                controller: _searchController,
                variant: AppInputVariant.search,
                hint: 'Search...',
                prefixIcon: Icons.search,
              ),
            ),
          ],
        ),
        CatalogSection(
          title: 'States',
          description: 'Error, disabled, and helper text states',
          children: [
            DemoCard(
              label: 'With Error',
              child: AppInput(
                controller: _errorController,
                label: 'Email Address',
                hint: 'email@example.com',
                error: 'Invalid email format',
              ),
            ),
            DemoCard(
              label: 'Disabled',
              child: AppInput(
                controller: TextEditingController(text: 'Disabled value'),
                label: 'Disabled Field',
                enabled: false,
              ),
            ),
            DemoCard(
              label: 'Read Only',
              child: AppInput(
                controller: TextEditingController(text: 'Read-only value'),
                label: 'Read Only Field',
                readOnly: true,
              ),
            ),
          ],
        ),
        CatalogSection(
          title: 'With Icons',
          description: 'Inputs with prefix and suffix icons',
          children: [
            DemoCard(
              label: 'Prefix Icon',
              child: AppInput(
                controller: TextEditingController(),
                label: 'Username',
                hint: 'Enter username',
                prefixIcon: Icons.person,
              ),
            ),
            DemoCard(
              label: 'Suffix Icon',
              child: AppInput(
                controller: TextEditingController(),
                label: 'Email',
                hint: 'email@example.com',
                suffixIcon: Icons.email,
              ),
            ),
            DemoCard(
              label: 'Both Icons',
              child: AppInput(
                controller: TextEditingController(),
                label: 'Website',
                hint: 'www.example.com',
                prefixIcon: Icons.language,
                suffixIcon: Icons.check_circle,
              ),
            ),
          ],
        ),
        CatalogSection(
          title: 'Special Cases',
          description: 'Password, multiline, and custom inputs',
          children: [
            DemoCard(
              label: 'Password Input',
              child: AppInput(
                controller: _passwordController,
                label: 'Password',
                hint: 'Enter password',
                obscureText: true,
                prefixIcon: Icons.lock,
              ),
            ),
            DemoCard(
              label: 'Multiline Input',
              child: AppInput(
                controller: _multilineController,
                label: 'Notes',
                hint: 'Add your notes here...',
                maxLines: 4,
              ),
            ),
            DemoCard(
              label: 'No Label',
              child: AppInput(
                controller: TextEditingController(),
                hint: 'Input without label',
              ),
            ),
          ],
        ),
        CatalogSection(
          title: 'Phone Input Component',
          description: 'Specialized phone input with country code picker',
          children: [
            DemoCard(
              label: 'Phone Input with Country Code',
              child: PhoneInput(
                controller: TextEditingController(),
                label: 'Mobile Number',
                countryCode: '+225',
                onCountryCodeTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: AppText(
                        'Country code picker would open here',
                        color: context.colors.textPrimary,
                      ),
                      backgroundColor: context.colors.container,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
