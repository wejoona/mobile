import 'package:flutter/material.dart';
import 'package:usdc_wallet/catalog/widget_catalog_view.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';

class SelectCatalog extends StatefulWidget {
  const SelectCatalog({super.key});

  @override
  State<SelectCatalog> createState() => _SelectCatalogState();
}

class _SelectCatalogState extends State<SelectCatalog> {
  String? _selectedCountry;
  String? _selectedCurrency;
  String? _selectedPaymentMethod;
  String? _errorSelect;

  final List<AppSelectItem<String>> _countries = [
    const AppSelectItem(value: 'ci', label: 'Côte d\'Ivoire', icon: Icons.flag),
    const AppSelectItem(value: 'sn', label: 'Senegal', icon: Icons.flag),
    const AppSelectItem(value: 'ml', label: 'Mali', icon: Icons.flag),
    const AppSelectItem(value: 'bf', label: 'Burkina Faso', icon: Icons.flag),
  ];

  final List<AppSelectItem<String>> _currencies = [
    const AppSelectItem(value: 'xof', label: 'XOF', subtitle: 'CFA Franc'),
    const AppSelectItem(value: 'usd', label: 'USD', subtitle: 'US Dollar'),
    const AppSelectItem(value: 'eur', label: 'EUR', subtitle: 'Euro'),
  ];

  final List<AppSelectItem<String>> _paymentMethods = [
    const AppSelectItem(
      value: 'orange',
      label: 'Orange Money',
      icon: Icons.phone_android,
    ),
    const AppSelectItem(
      value: 'mtn',
      label: 'MTN Mobile Money',
      icon: Icons.phone_android,
    ),
    const AppSelectItem(
      value: 'wave',
      label: 'Wave',
      icon: Icons.phone_android,
    ),
    const AppSelectItem(
      value: 'bank',
      label: 'Bank Transfer',
      icon: Icons.account_balance,
      enabled: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CatalogSection(
          title: 'Basic Select',
          description: 'Simple dropdown with label and hint',
          children: [
            DemoCard(
              label: 'Default Select',
              child: AppSelect<String>(
                items: _countries,
                value: _selectedCountry,
                onChanged: (value) {
                  setState(() => _selectedCountry = value);
                },
                label: 'Country',
                hint: 'Select your country',
              ),
            ),
          ],
        ),
        CatalogSection(
          title: 'With Helper Text',
          description: 'Select with additional context',
          children: [
            DemoCard(
              child: AppSelect<String>(
                items: _currencies,
                value: _selectedCurrency,
                onChanged: (value) {
                  setState(() => _selectedCurrency = value);
                },
                label: 'Currency',
                hint: 'Choose currency',
                helper: 'This will be your default currency',
              ),
            ),
          ],
        ),
        CatalogSection(
          title: 'With Icons',
          description: 'Select items with icons and subtitles',
          children: [
            DemoCard(
              label: 'Payment Method',
              child: AppSelect<String>(
                items: _paymentMethods,
                value: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() => _selectedPaymentMethod = value);
                },
                label: 'Payment Method',
                hint: 'Select payment method',
              ),
            ),
          ],
        ),
        CatalogSection(
          title: 'States',
          description: 'Error and disabled states',
          children: [
            DemoCard(
              label: 'With Error',
              child: AppSelect<String>(
                items: _countries,
                value: _errorSelect,
                onChanged: (value) {
                  setState(() => _errorSelect = value);
                },
                label: 'Country',
                hint: 'Select country',
                error: 'Please select a country',
              ),
            ),
            DemoCard(
              label: 'Disabled',
              child: AppSelect<String>(
                items: _countries,
                value: _selectedCountry,
                onChanged: (value) {},
                label: 'Country',
                hint: 'Select country',
                enabled: false,
              ),
            ),
          ],
        ),
        CatalogSection(
          title: 'With Prefix Icon',
          description: 'Select with leading icon',
          children: [
            DemoCard(
              child: AppSelect<String>(
                items: _currencies,
                value: _selectedCurrency,
                onChanged: (value) {
                  setState(() => _selectedCurrency = value);
                },
                label: 'Currency',
                hint: 'Select currency',
                prefixIcon: Icons.attach_money,
              ),
            ),
          ],
        ),
        CatalogSection(
          title: 'Without Checkmark',
          description: 'Select without selected item indicator',
          children: [
            DemoCard(
              child: AppSelect<String>(
                items: _countries,
                value: _selectedCountry,
                onChanged: (value) {
                  setState(() => _selectedCountry = value);
                },
                label: 'Country',
                hint: 'Select country',
                showCheckmark: false,
              ),
            ),
          ],
        ),
        CatalogSection(
          title: 'Complex Items',
          description: 'Select with subtitles and mixed states',
          children: [
            DemoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSelect<String>(
                    items: _paymentMethods,
                    value: _selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() => _selectedPaymentMethod = value);
                    },
                    label: 'Payment Method',
                    hint: 'Choose payment method',
                    helper: 'Bank transfer is currently unavailable',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (_selectedPaymentMethod != null)
                    AppCard(
                      variant: AppCardVariant.subtle,
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: context.colors.textSecondary,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: AppText(
                              'Selected: ${_paymentMethods.firstWhere((m) => m.value == _selectedPaymentMethod).label}',
                              variant: AppTextVariant.bodySmall,
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
