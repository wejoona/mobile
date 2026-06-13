import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';
import 'package:usdc_wallet/features/contacts/models/synced_contact.dart';
import 'package:usdc_wallet/features/send/providers/send_provider.dart';
import 'package:usdc_wallet/features/send/widgets/beneficiary_picker_bottom_sheet.dart';
import 'package:usdc_wallet/features/send/widgets/contact_picker_bottom_sheet.dart';
import 'package:usdc_wallet/features/send/widgets/recent_recipient_card.dart';
import 'package:usdc_wallet/features/send/widgets/send_flow_visuals.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
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
  bool _selectedRecipientKnownKorido = false;
  bool _recipientLookupAttempted = false;
  bool _recipientLookupFailed = false;
  Timer? _recipientLookupDebounce;
  bool _isRecipientLookupLoading = false;

  String get _typedPhoneNumber =>
      '$_selectedCountryCode${_phoneController.text}';

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
      _lookupCurrentRecipientIfNeeded(isKnownKorido: false);
    }

    // Load recent recipients
    unawaited(
      Future<void>.microtask(() async {
        await ref.read(sendMoneyProvider.notifier).loadRecentRecipients();
        await ref.read(sendMoneyProvider.notifier).loadBalance();
      }),
    );
  }

  @override
  void dispose() {
    _recipientLookupDebounce?.cancel();
    _phoneController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(sendMoneyProvider);
    final authState = ref.watch(authProvider);
    final colors = context.colors;
    final isCompletePhone =
        _phoneController.text.length == _selectedLocalLength;
    final myPhone = authState.user?.phone ?? authState.phone;
    final isSelfRecipient =
        isCompletePhone && _samePhone(_typedPhoneNumber, myPhone);
    final canContinue =
        isCompletePhone &&
        !_isRecipientLookupLoading &&
        !isSelfRecipient &&
        _selectedRecipientKnownKorido;

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
                              if (value == null) {
                                return;
                              }
                              setState(() {
                                _selectedCountryCode = value;
                                _selectedRecipientName = null;
                                _selectedRecipientKnownKorido = false;
                                _recipientLookupAttempted = false;
                                _recipientLookupFailed = false;
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
                            onChanged: _handlePhoneChanged,
                          ),
                          if (isSelfRecipient) ...[
                            const SizedBox(height: AppSpacing.md),
                            SendCallout(
                              icon: Icons.block_rounded,
                              title: localizedSendCopy(
                                context,
                                en: 'This is your Korido account',
                                fr: 'Ceci est votre compte Korido',
                              ),
                              body: localizedSendCopy(
                                context,
                                en: 'Choose another Korido user before sending money.',
                                fr: 'Choisissez un autre utilisateur Korido avant d’envoyer de l’argent.',
                              ),
                              tone: SendCalloutTone.warning,
                            ),
                          ] else if (_isRecipientLookupLoading) ...[
                            const SizedBox(height: AppSpacing.md),
                            SendCallout(
                              icon: Icons.search_rounded,
                              title: localizedSendCopy(
                                context,
                                en: 'Checking Korido account',
                                fr: 'Vérification du compte Korido',
                              ),
                              body: localizedSendCopy(
                                context,
                                en: 'We are matching this number securely.',
                                fr: 'Nous vérifions ce numéro de façon sécurisée.',
                              ),
                            ),
                          ] else if (_recipientLookupFailed &&
                              isCompletePhone) ...[
                            const SizedBox(height: AppSpacing.md),
                            SendCallout(
                              icon: Icons.wifi_off_rounded,
                              title: localizedSendCopy(
                                context,
                                en: 'Could not verify this account',
                                fr: 'Compte impossible à vérifier',
                              ),
                              body: localizedSendCopy(
                                context,
                                en: 'Check your connection and try again before sending.',
                                fr: 'Vérifiez votre connexion puis réessayez avant l’envoi.',
                              ),
                              tone: SendCalloutTone.error,
                            ),
                          ] else if (_recipientLookupAttempted &&
                              !_selectedRecipientKnownKorido &&
                              isCompletePhone) ...[
                            const SizedBox(height: AppSpacing.md),
                            SendCallout(
                              icon: Icons.person_off_outlined,
                              title: localizedSendCopy(
                                context,
                                en: 'No Korido account found',
                                fr: 'Aucun compte Korido trouvé',
                              ),
                              body: localizedSendCopy(
                                context,
                                en: 'Internal transfers currently require a verified Korido recipient.',
                                fr: 'Les transferts internes nécessitent actuellement un destinataire Korido vérifié.',
                              ),
                              tone: SendCalloutTone.warning,
                            ),
                          ],
                          if (!isSelfRecipient &&
                              _selectedRecipientKnownKorido &&
                              _selectedRecipientName != null) ...[
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
                            isKnownKorido: recipient.isKoridoUser,
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
                  onPressed: canContinue ? _handleContinue : null,
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
    if (!mounted) {
      return;
    }

    final contactsService = ref.read(contactsServiceProvider);
    var hasPermission = await contactsService.hasContactsPermission();
    if (!hasPermission) {
      hasPermission = await contactsService.requestContactsPermission();
    }

    if (!mounted) {
      return;
    }

    if (!hasPermission) {
      await _showContactsPermissionDialog();
      return;
    }

    final contact = await showModalBottomSheet<SyncedContact>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ContactPickerBottomSheet(),
    );

    if (contact != null) {
      _selectRecipient(
        contact.phone,
        contact.name,
        isKnownKorido: contact.isKoridoUser,
      );
    }
  }

  Future<void> _showContactsPermissionDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final contactsService = ref.read(contactsServiceProvider);
    final requiresSettings = await contactsService
        .contactsPermissionRequiresSettings();
    if (!mounted) {
      return;
    }

    if (requiresSettings) {
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
      if (shouldOpen ?? false) {
        await contactsService.openContactsSettings();
      }
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.send_contactsPermissionDenied)));
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

  void _selectRecipient(
    String phoneNumber,
    String? name, {
    bool isKnownKorido = false,
  }) {
    setState(
      () =>
          _setRecipientFields(phoneNumber, name, isKnownKorido: isKnownKorido),
    );
    _lookupCurrentRecipientIfNeeded(isKnownKorido: isKnownKorido);
  }

  void _setRecipientFields(
    String phoneNumber,
    String? name, {
    bool isKnownKorido = false,
  }) {
    var cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
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
    _selectedRecipientKnownKorido = isKnownKorido;
    _recipientLookupAttempted = isKnownKorido;
    _recipientLookupFailed = false;
  }

  void _handlePhoneChanged(String value) {
    _recipientLookupDebounce?.cancel();

    setState(() {
      _selectedRecipientName = null;
      _selectedRecipientKnownKorido = false;
      _recipientLookupAttempted = false;
      _recipientLookupFailed = false;
      _isRecipientLookupLoading = false;
    });

    final authState = ref.read(authProvider);
    final myPhone = authState.user?.phone ?? authState.phone;
    if (value.length != _selectedLocalLength ||
        _samePhone(_typedPhoneNumber, myPhone)) {
      return;
    }

    _recipientLookupDebounce = Timer(
      const Duration(milliseconds: 350),
      () => _lookupTypedRecipient(_typedPhoneNumber),
    );
  }

  void _lookupCurrentRecipientIfNeeded({required bool isKnownKorido}) {
    if (isKnownKorido || _phoneController.text.length != _selectedLocalLength) {
      return;
    }

    final authState = ref.read(authProvider);
    final myPhone = authState.user?.phone ?? authState.phone;
    if (_samePhone(_typedPhoneNumber, myPhone)) {
      return;
    }

    _recipientLookupDebounce?.cancel();
    _recipientLookupDebounce = Timer(
      const Duration(milliseconds: 120),
      () => _lookupTypedRecipient(_typedPhoneNumber),
    );
  }

  Future<void> _lookupTypedRecipient(String phoneNumber) async {
    final authState = ref.read(authProvider);
    final myPhone = authState.user?.phone ?? authState.phone;
    if (_samePhone(phoneNumber, myPhone)) {
      return;
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _isRecipientLookupLoading = true;
      _recipientLookupAttempted = false;
      _recipientLookupFailed = false;
    });
    try {
      final matches = await ref
          .read(joonaPayContactsServiceProvider)
          .lookupKoridoUsers(phoneNumber);
      if (!mounted ||
          '$_selectedCountryCode${_phoneController.text}' != phoneNumber) {
        return;
      }
      SyncedContact? match;
      for (final candidate in matches) {
        if (candidate.isKoridoUser) {
          match = candidate;
          break;
        }
      }
      setState(() {
        _selectedRecipientName = match?.name;
        _selectedRecipientKnownKorido = match != null;
        _recipientLookupAttempted = true;
        _recipientLookupFailed = false;
      });
    } on Object {
      if (!mounted) {
        return;
      }
      if (_typedPhoneNumber == phoneNumber) {
        setState(() {
          _selectedRecipientName = null;
          _selectedRecipientKnownKorido = false;
          _recipientLookupAttempted = true;
          _recipientLookupFailed = true;
        });
      }
    } finally {
      if (mounted && _typedPhoneNumber == phoneNumber) {
        setState(() => _isRecipientLookupLoading = false);
      }
    }
  }

  Future<void> _handleContinue() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      final phoneNumber = '$_selectedCountryCode${_phoneController.text}';
      final authState = ref.read(authProvider);
      final myPhone = authState.user?.phone ?? authState.phone;
      if (_samePhone(phoneNumber, myPhone)) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              localizedSendCopy(
                context,
                en: 'You cannot send money to your own Korido account.',
                fr: 'Vous ne pouvez pas envoyer de l’argent à votre propre compte Korido.',
              ),
            ),
            backgroundColor: context.colors.warning,
          ),
        );
        return;
      }

      await ref
          .read(sendMoneyProvider.notifier)
          .setRecipient(phoneNumber, name: _selectedRecipientName);

      final sendState = ref.read(sendMoneyProvider);
      if (sendState.error != null) {
        if (!mounted) {
          return;
        }
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
        if (!mounted) {
          return;
        }
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
        unawaited(context.push('/send/amount'));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  bool _samePhone(String candidate, String? currentUserPhone) {
    if (currentUserPhone == null || currentUserPhone.trim().isEmpty) {
      return false;
    }
    return _phoneDigits(candidate) == _phoneDigits(currentUserPhone);
  }

  String _phoneDigits(String value) => value.replaceAll(RegExp(r'\D'), '');
}
