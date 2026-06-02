import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/features/contacts/models/synced_contact.dart';
import 'package:usdc_wallet/features/send/providers/send_provider.dart';
import 'package:usdc_wallet/features/send/widgets/beneficiary_picker_bottom_sheet.dart';
import 'package:usdc_wallet/features/send/widgets/contact_picker_bottom_sheet.dart';
import 'package:usdc_wallet/features/send/widgets/recent_recipient_card.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/mocks/mock_config.dart';

class RecipientScreen extends ConsumerStatefulWidget {
  const RecipientScreen({super.key, this.initialPhone, this.initialName});

  final String? initialPhone;
  final String? initialName;

  @override
  ConsumerState<RecipientScreen> createState() => _RecipientScreenState();
}

class _RecipientScreenState extends ConsumerState<RecipientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _nameFocusNode = FocusNode();
  bool _isLoading = false;
  String _selectedCountryCode = '+225';
  String? _selectedRecipientName;

  int get _selectedLocalLength {
    switch (_selectedCountryCode) {
      case '+221':
        return 9;
      case '+223':
        return 8;
      case '+225':
      default:
        return 10;
    }
  }

  @override
  void initState() {
    super.initState();
    final initialPhone = widget.initialPhone?.trim();
    if (initialPhone != null && initialPhone.isNotEmpty) {
      _setRecipientFields(initialPhone, widget.initialName);
    }

    // Load recent recipients
    Future.microtask(() {
      ref.read(sendMoneyProvider.notifier).loadRecentRecipients();
      ref.read(sendMoneyProvider.notifier).loadBalance();
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(sendMoneyProvider);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        title: AppText(
          l10n.send_selectRecipient,
          variant: AppTextVariant.titleLarge,
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.screenPadding),
                  children: [
                    AppSelect<String>(
                      label: l10n.auth_country,
                      value: _selectedCountryCode,
                      items: [
                        AppSelectItem(
                          value: '+225',
                          label: l10n.profile_countryIvoryCoast,
                          subtitle: '+225',
                        ),
                        AppSelectItem(
                          value: '+221',
                          label: l10n.profile_countrySenegal,
                          subtitle: '+221',
                        ),
                        const AppSelectItem(
                          value: '+223',
                          label: 'Mali',
                          subtitle: '+223',
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _selectedCountryCode = value;
                          _selectedRecipientName = null;
                          _phoneController.clear();
                        });
                      },
                    ),
                    SizedBox(height: AppSpacing.md),

                    // Phone number input
                    AppInput(
                      label: l10n.send_recipientPhone,
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      prefix: Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Text(
                          '$_selectedCountryCode ',
                          style: TextStyle(color: colors.textPrimary),
                        ),
                      ),
                      validator: _validatePhone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(_selectedLocalLength),
                      ],
                      onChanged: (_) {
                        if (_selectedRecipientName == null) return;
                        setState(() => _selectedRecipientName = null);
                      },
                    ),
                    SizedBox(height: AppSpacing.md),

                    // Action buttons row
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: l10n.send_fromContacts,
                            variant: AppButtonVariant.secondary,
                            size: AppButtonSize.small,
                            icon: Icons.contacts_outlined,
                            onPressed: _selectFromContacts,
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: AppButton(
                            label: l10n.send_fromBeneficiaries,
                            variant: AppButtonVariant.secondary,
                            size: AppButtonSize.small,
                            icon: Icons.bookmark_outline,
                            onPressed: _selectFromBeneficiaries,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.xl),

                    // Recent recipients section
                    if (state.recentRecipients.isNotEmpty) ...[
                      AppText(
                        l10n.send_recentRecipients,
                        variant: AppTextVariant.labelLarge,
                        color: colors.textSecondary,
                      ),
                      SizedBox(height: AppSpacing.sm),
                      ...state.recentRecipients.map(
                        (recipient) => RecentRecipientCard(
                          recipient: recipient,
                          onTap: () => _selectRecipient(
                            recipient.phoneNumber,
                            recipient.name,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Bottom button
              Padding(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                child: AppButton(
                  label: l10n.action_continue,
                  onPressed: _handleContinue,
                  isLoading: _isLoading,
                  isFullWidth: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validatePhone(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l10n.error_phoneRequired;
    }
    if (value.length != _selectedLocalLength) {
      return l10n.error_phoneInvalid;
    }
    return null;
  }

  Future<void> _selectFromContacts() async {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    if (!MockConfig.useMocks) {
      final status = await Permission.contacts.request();
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.send_contactsPermissionDenied),
              backgroundColor: colors.error,
            ),
          );
        }
        return;
      }
    }

    // Show contact picker
    if (mounted) {
      final contact = await showModalBottomSheet<SyncedContact>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const ContactPickerBottomSheet(),
      );

      if (contact != null) {
        _selectRecipient(contact.phone, contact.name);
      }
    }
  }

  Future<void> _selectFromBeneficiaries() async {
    final beneficiary = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const BeneficiaryPickerBottomSheet(),
    );

    if (beneficiary != null && mounted) {
      _selectRecipient(
        // ignore: avoid_dynamic_calls
        beneficiary.phoneE164 ?? '',
        // ignore: avoid_dynamic_calls
        beneficiary.name,
      );
    }
  }

  void _selectRecipient(String phoneNumber, String? name) {
    setState(() => _setRecipientFields(phoneNumber, name));
  }

  void _setRecipientFields(String phoneNumber, String? name) {
    String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    for (final code in ['+225', '+221', '+223']) {
      if (cleanPhone.startsWith(code)) {
        _selectedCountryCode = code;
        cleanPhone = cleanPhone.substring(code.length).trim();
        break;
      }
    }
    cleanPhone = cleanPhone.replaceAll(RegExp(r'\D'), '');

    _phoneController.text = cleanPhone;
    _selectedRecipientName = name;
  }

  Future<void> _handleContinue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final phoneNumber = '$_selectedCountryCode${_phoneController.text}';
      await ref
          .read(sendMoneyProvider.notifier)
          .setRecipient(phoneNumber, name: _selectedRecipientName);

      if (mounted) {
        context.push('/send/amount');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
