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
import 'package:usdc_wallet/features/send/widgets/send_flow_visuals.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/mocks/mock_config.dart';
import 'package:usdc_wallet/services/contacts/contacts_service.dart';

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
      case '+1':
        return 10;
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
                    SendFlowHeader(
                      icon: Icons.near_me_outlined,
                      title: l10n.send_selectRecipient,
                      subtitle: localizedSendCopy(
                        context,
                        en: 'Choose a Korido contact, saved beneficiary, or phone number.',
                        fr: 'Choisissez un contact Korido, un bénéficiaire enregistré ou un numéro.',
                      ),
                      currentStep: 0,
                      metaLabel: sendStepLabel(context, 1),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    AppCard(
                      variant: AppCardVariant.elevated,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
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
                              AppSelectItem(
                                value: '+1',
                                label: localizedSendCopy(
                                  context,
                                  en: 'United States',
                                  fr: 'États-Unis',
                                ),
                                subtitle: '+1',
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
                          const SizedBox(height: AppSpacing.md),
                          AppInput(
                            label: l10n.send_recipientPhone,
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            prefix: Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: AppText(
                                '$_selectedCountryCode ',
                                variant: AppTextVariant.labelLarge,
                                color: colors.textSecondary,
                              ),
                            ),
                            validator: _validatePhone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(
                                _selectedLocalLength,
                              ),
                            ],
                            onChanged: (_) {
                              if (_selectedRecipientName == null) return;
                              setState(() => _selectedRecipientName = null);
                            },
                          ),
                          if (_selectedRecipientName != null) ...[
                            const SizedBox(height: AppSpacing.md),
                            SendCallout(
                              icon: Icons.verified_user_outlined,
                              title: localizedSendCopy(
                                context,
                                en: 'Korido account selected',
                                fr: 'Compte Korido sélectionné',
                              ),
                              body: _selectedRecipientName!,
                              tone: SendCalloutTone.success,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    SendCallout(
                      icon: Icons.privacy_tip_outlined,
                      title: localizedSendCopy(
                        context,
                        en: 'Private contact matching',
                        fr: 'Recherche privée des contacts',
                      ),
                      body: localizedSendCopy(
                        context,
                        en: 'Phone numbers are matched securely. Non-users are not notified.',
                        fr: 'Les numéros sont vérifiés de façon sécurisée. Les non-utilisateurs ne sont pas notifiés.',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    Row(
                      children: [
                        Expanded(
                          child: SendActionTile(
                            icon: Icons.contacts_outlined,
                            label: l10n.send_fromContacts,
                            subtitle: l10n.send_contacts,
                            onTap: _selectFromContacts,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: SendActionTile(
                            icon: Icons.bookmark_outline,
                            label: l10n.send_fromBeneficiaries,
                            subtitle: l10n.send_saved,
                            onTap: _selectFromBeneficiaries,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Recent recipients section
                    if (state.recentRecipients.isNotEmpty) ...[
                      SendSectionTitle(l10n.send_recentRecipients),
                      const SizedBox(height: AppSpacing.sm),
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
                  key: const ValueKey('send_recipient_continue_button'),
                  label: l10n.action_continue,
                  icon: Icons.arrow_forward_rounded,
                  iconPosition: IconPosition.right,
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
      var status = await Permission.contacts.status;
      if (!status.isGranted && !status.isLimited) {
        // Permission.request() only surfaces the OS dialog the first time.
        // Once the user has permanently denied it, request() returns
        // immediately without prompting — so send them to app settings
        // instead of repeating a dead-end error.
        if (status.isPermanentlyDenied || status.isRestricted) {
          if (mounted) await _showContactsSettingsDialog(l10n);
          return;
        }
        final granted = await ref
            .read(contactsServiceProvider)
            .requestContactsPermission();
        status = await Permission.contacts.status;
        if (!granted) {
          if (!mounted) return;
          if (status.isPermanentlyDenied) {
            await _showContactsSettingsDialog(l10n);
          } else {
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

  /// Shown when contacts permission is permanently denied — request() can no
  /// longer prompt, so guide the user to the system settings page.
  Future<void> _showContactsSettingsDialog(AppLocalizations l10n) async {
    final shouldOpen = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.send_contactsPermissionSettingsTitle),
        content: Text(l10n.send_contactsPermissionSettingsMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.action_cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.action_open_settings),
          ),
        ],
      ),
    );
    if (shouldOpen == true) {
      await openAppSettings();
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
    for (final code in ['+225', '+221', '+223', '+1']) {
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

      final sendState = ref.read(sendMoneyProvider);
      if (sendState.error != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              localizedSendCopy(
                context,
                en: 'We could not verify this Korido account. Please try again.',
                fr: 'Nous n’avons pas pu vérifier ce compte Korido. Veuillez réessayer.',
              ),
            ),
            backgroundColor: context.colors.error,
          ),
        );
        return;
      }

      final recipient = sendState.recipient;
      if (recipient?.isKoridoUser != true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              localizedSendCopy(
                context,
                en: 'This transfer is available only to Korido accounts for now.',
                fr: 'Ce transfert est disponible uniquement vers les comptes Korido pour le moment.',
              ),
            ),
            backgroundColor: context.colors.warning,
          ),
        );
        return;
      }

      if (mounted) {
        context.push('/send/amount');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
