import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/config/countries.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';
import 'package:usdc_wallet/features/auth/providers/countries_provider.dart';
import 'package:usdc_wallet/features/contacts/models/synced_contact.dart';
import 'package:usdc_wallet/features/send/providers/send_provider.dart';
import 'package:usdc_wallet/features/send/widgets/beneficiary_picker_bottom_sheet.dart';
import 'package:usdc_wallet/features/send/widgets/contact_picker_bottom_sheet.dart';
import 'package:usdc_wallet/features/send/widgets/recent_recipient_card.dart';
import 'package:usdc_wallet/features/send/widgets/send_flow_visuals.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/services/contacts/contacts_service.dart';
import 'package:usdc_wallet/state/user_state_machine.dart';
import 'package:usdc_wallet/utils/phone_number_normalizer.dart';

class RecipientScreen extends ConsumerStatefulWidget {
  const RecipientScreen({
    super.key,
    this.initialPhone,
    this.initialUsername,
    this.initialRecipientId,
    this.initialName,
  });

  final String? initialPhone;
  final String? initialUsername;
  final String? initialRecipientId;
  final String? initialName;

  @override
  ConsumerState<RecipientScreen> createState() => _RecipientScreenState();
}

class _RecipientScreenState extends ConsumerState<RecipientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _nameFocusNode = FocusNode();
  bool _isLoading = false;
  String? _selectedCountryCode;
  String? _selectedRecipientName;
  String? _selectedRecipientUsername;
  String? _selectedRecipientUserId;
  bool _selectedRecipientKnownKorido = false;
  bool _recipientLookupAttempted = false;
  bool _recipientLookupFailed = false;
  Timer? _recipientLookupDebounce;
  bool _isRecipientLookupLoading = false;

  String get _typedPhoneNumber =>
      '${_selectedDialCode()}${_phoneController.text}';

  int get _selectedLocalLength => _selectedCountry().phoneLength;

  @override
  void initState() {
    super.initState();
    _selectedCountryCode = _initialCountry().fullPrefix;
    final initialPhone = widget.initialPhone?.trim();
    final initialUsername = widget.initialUsername?.trim();
    final initialRecipientId = widget.initialRecipientId?.trim();
    if (initialPhone != null && initialPhone.isNotEmpty) {
      final isKnownKorido =
          (initialUsername != null && initialUsername.isNotEmpty) ||
          (initialRecipientId != null && initialRecipientId.isNotEmpty);
      _setRecipientFields(
        initialPhone,
        widget.initialName,
        username: initialUsername,
        userId: initialRecipientId,
        isKnownKorido: isKnownKorido,
      );
      _lookupCurrentRecipientIfNeeded(isKnownKorido: isKnownKorido);
    } else if (initialUsername != null && initialUsername.isNotEmpty) {
      _setRecipientFields(
        '',
        widget.initialName,
        username: initialUsername,
        userId: widget.initialRecipientId,
        isKnownKorido: true,
      );
    } else if (initialRecipientId != null && initialRecipientId.isNotEmpty) {
      _setRecipientFields(
        '',
        widget.initialName,
        userId: initialRecipientId,
        isKnownKorido: true,
      );
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
    final userState = ref.watch(userStateMachineProvider);
    final colors = context.colors;
    final countryOptions = _countryOptions(watch: true);
    final isCompletePhone =
        _phoneController.text.length == _selectedLocalLength;
    final myPhone = authState.user?.phone ?? authState.phone ?? userState.phone;
    final hasUsernameRecipient = _hasUsernameRecipient;
    final hasUserIdRecipient = _hasUserIdRecipient;
    final myUsername = _normalizeUsername(authState.user?.username);
    final isSelfSelectedAccount =
        (_selectedRecipientUserId != null &&
            _selectedRecipientUserId ==
                (authState.user?.id ?? userState.userId)) ||
        (_selectedRecipientUsername != null &&
            myUsername != null &&
            _selectedRecipientUsername == myUsername);
    final isSelfRecipient =
        (isCompletePhone && _samePhone(_typedPhoneNumber, myPhone)) ||
        isSelfSelectedAccount;
    final hasSelectableRecipient =
        _selectedRecipientKnownKorido &&
        (isCompletePhone || hasUsernameRecipient || hasUserIdRecipient);
    final canContinue =
        hasSelectableRecipient &&
        !_isRecipientLookupLoading &&
        !isSelfRecipient;

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
                            value: _selectedDialCode(),
                            items: _countrySelectItems(countryOptions),
                            onChanged: (value) {
                              if (value == null) {
                                return;
                              }
                              setState(() {
                                _selectedCountryCode = value;
                                _selectedRecipientName = null;
                                _selectedRecipientUsername = null;
                                _selectedRecipientUserId = null;
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
                                '${_selectedDialCode()} ',
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
                              (_selectedRecipientName != null ||
                                  _hasUsernameRecipient)) ...[
                            const SizedBox(height: AppSpacing.md),
                            SendCallout(
                              icon: Icons.verified_user_outlined,
                              title: localizedSendCopy(
                                context,
                                en: 'Korido account selected',
                                fr: 'Compte Korido sélectionné',
                              ),
                              body: _selectedRecipientSubtitle,
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
                            username: recipient.username,
                            userId: recipient.userId,
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

  List<AppSelectItem<String>> _countrySelectItems(
    List<CountryConfig> countries,
  ) {
    return countries
        .map(
          (country) => AppSelectItem(
            value: country.fullPrefix,
            label: country.name,
            subtitle: country.fullPrefix,
          ),
        )
        .toList(growable: false);
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
        username: contact.username,
        userId: contact.joonaPayUserId,
        isKnownKorido: contact.isKoridoUser,
      );
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

  void _selectRecipient(
    String phoneNumber,
    String? name, {
    String? username,
    String? userId,
    bool isKnownKorido = false,
  }) {
    setState(
      () => _setRecipientFields(
        phoneNumber,
        name,
        username: username,
        userId: userId,
        isKnownKorido: isKnownKorido,
      ),
    );
    _lookupCurrentRecipientIfNeeded(isKnownKorido: isKnownKorido);
  }

  void _setRecipientFields(
    String phoneNumber,
    String? name, {
    String? username,
    String? userId,
    bool isKnownKorido = false,
  }) {
    final phoneValue = PhoneNumberValue.tryFromAny(
      phoneNumber: phoneNumber,
      countryCode: _selectedDialCode(),
    );
    var cleanPhone = '';
    if (phoneValue != null) {
      if (_countryForDialCode(phoneValue.dialCode) != null) {
        _selectedCountryCode = phoneValue.dialCode;
      }
      cleanPhone = phoneValue.localNumber;
    } else {
      cleanPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
    }

    _phoneController.text = cleanPhone;
    _selectedRecipientName = name;
    _selectedRecipientUsername = _normalizeUsername(username);
    _selectedRecipientUserId = userId;
    _selectedRecipientKnownKorido = isKnownKorido;
    _recipientLookupAttempted = isKnownKorido;
    _recipientLookupFailed = false;
  }

  void _handlePhoneChanged(String value) {
    _recipientLookupDebounce?.cancel();

    setState(() {
      _selectedRecipientName = null;
      _selectedRecipientUsername = null;
      _selectedRecipientUserId = null;
      _selectedRecipientKnownKorido = false;
      _recipientLookupAttempted = false;
      _recipientLookupFailed = false;
      _isRecipientLookupLoading = false;
    });

    final authState = ref.read(authProvider);
    final userState = ref.read(userStateMachineProvider);
    final myPhone = authState.user?.phone ?? authState.phone ?? userState.phone;
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
    final userState = ref.read(userStateMachineProvider);
    final myPhone = authState.user?.phone ?? authState.phone ?? userState.phone;
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
    final userState = ref.read(userStateMachineProvider);
    final myPhone = authState.user?.phone ?? authState.phone ?? userState.phone;
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
          .read(koridoContactsServiceProvider)
          .lookupKoridoUsers(phoneNumber);
      if (!mounted ||
          '${_selectedDialCode()}${_phoneController.text}' != phoneNumber) {
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
        _selectedRecipientUsername = _normalizeUsername(match?.username);
        _selectedRecipientUserId = match?.joonaPayUserId ?? match?.id;
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
          _selectedRecipientUsername = null;
          _selectedRecipientUserId = null;
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
    final hasUsernameRecipient = _hasUsernameRecipient;
    final hasUserIdRecipient = _hasUserIdRecipient;
    if (!hasUsernameRecipient &&
        !hasUserIdRecipient &&
        !_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      final phoneNumber = '${_selectedDialCode()}${_phoneController.text}';
      final authState = ref.read(authProvider);
      final userState = ref.read(userStateMachineProvider);
      final myPhone =
          authState.user?.phone ?? authState.phone ?? userState.phone;
      final sameUserId =
          _selectedRecipientUserId != null &&
          _selectedRecipientUserId == (authState.user?.id ?? userState.userId);
      final myUsername = _normalizeUsername(authState.user?.username);
      final sameUsername =
          _selectedRecipientUsername != null &&
          myUsername != null &&
          _selectedRecipientUsername == myUsername;
      if ((!hasUsernameRecipient && _samePhone(phoneNumber, myPhone)) ||
          sameUserId ||
          sameUsername) {
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

      if (hasUsernameRecipient || hasUserIdRecipient) {
        await ref
            .read(sendMoneyProvider.notifier)
            .setKnownKoridoRecipient(
              phoneNumber: _phoneController.text.length == _selectedLocalLength
                  ? phoneNumber
                  : null,
              username: _selectedRecipientUsername,
              name: _selectedRecipientName,
              userId: _selectedRecipientUserId,
            );
      } else {
        await ref
            .read(sendMoneyProvider.notifier)
            .setRecipient(phoneNumber, name: _selectedRecipientName);
      }

      final sendState = ref.read(sendMoneyProvider);
      if (sendState.error != null) {
        if (!mounted) {
          return;
        }
        final snack = _recipientErrorSnack(sendState.error!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(snack.message), backgroundColor: snack.color),
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

  bool get _hasUsernameRecipient =>
      _selectedRecipientUsername?.trim().isNotEmpty ?? false;

  bool get _hasUserIdRecipient =>
      _selectedRecipientUserId?.trim().isNotEmpty ?? false;

  String get _selectedRecipientSubtitle {
    final label = _selectedRecipientName ?? '';
    final handle = _selectedRecipientUsername;
    if (handle == null || handle.isEmpty) {
      if (label.isEmpty && _hasUserIdRecipient) {
        return localizedSendCopy(
          context,
          en: 'Verified Korido account',
          fr: 'Compte Korido vérifié',
        );
      }
      return label;
    }
    final displayHandle = handle.startsWith('@') ? handle : '@$handle';
    if (label.isEmpty) {
      return displayHandle;
    }
    return '$label · $displayHandle';
  }

  String? _normalizeUsername(String? username) {
    final trimmed = username?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    final withoutPrefix = trimmed.startsWith('@')
        ? trimmed.substring(1)
        : trimmed;
    return withoutPrefix.toLowerCase();
  }

  bool _samePhone(String candidate, String? currentUserPhone) {
    if (currentUserPhone == null || currentUserPhone.trim().isEmpty) {
      return false;
    }
    return localPhoneDigits(
          dialCode: _selectedDialCode(),
          phoneNumber: candidate,
        ) ==
        localPhoneDigits(
          dialCode: _selectedDialCode(),
          phoneNumber: currentUserPhone,
        );
  }

  CountryConfig _initialCountry() {
    final userCountryCode = ref.read(userStateMachineProvider).countryCode;
    final selectedCountry = ref.read(selectedCountryProvider);
    final countries = _countryOptions();
    for (final country in countries) {
      if (country.code == userCountryCode) {
        return country;
      }
    }
    return selectedCountry;
  }

  CountryConfig _selectedCountry() {
    return _countryForDialCode(_selectedCountryCode) ?? _initialCountry();
  }

  CountryConfig? _countryForDialCode(String? dialCode) {
    if (dialCode == null || dialCode.trim().isEmpty) {
      return null;
    }
    for (final country in _countryOptions()) {
      if (country.fullPrefix == dialCode) {
        return country;
      }
    }
    return null;
  }

  String _selectedDialCode() => _selectedCountry().fullPrefix;

  List<CountryConfig> _countryOptions({bool watch = false}) {
    final asyncCountries = watch
        ? ref.watch(countriesProvider)
        : ref.read(countriesProvider);
    final countries = asyncCountries.maybeWhen(
      data: (items) => items.where((country) => country.isEnabled).toList(),
      orElse: () => SupportedCountries.all,
    );
    return countries.isEmpty ? SupportedCountries.all : countries;
  }

  _RecipientSnack _recipientErrorSnack(String errorCode) {
    final colors = context.colors;
    switch (errorCode) {
      case 'recipient_is_current_user':
        return _RecipientSnack(
          localizedSendCopy(
            context,
            en: 'You cannot send money to your own Korido account.',
            fr: 'Vous ne pouvez pas envoyer de l’argent à votre propre compte Korido.',
          ),
          colors.warning,
        );
      case 'recipient_not_korido_user':
        return _RecipientSnack(
          localizedSendCopy(
            context,
            en: 'No Korido account was found for this recipient.',
            fr: 'Aucun compte Korido n’a été trouvé pour ce destinataire.',
          ),
          colors.warning,
        );
      case 'recipient_lookup_unavailable':
        return _RecipientSnack(
          localizedSendCopy(
            context,
            en: 'Korido account lookup is unavailable. Check your connection and try again.',
            fr: 'La vérification du compte Korido est indisponible. Vérifiez votre connexion puis réessayez.',
          ),
          colors.error,
        );
      case 'recipient_identifier_required':
        return _RecipientSnack(
          localizedSendCopy(
            context,
            en: 'Choose a Korido contact or enter a complete phone number.',
            fr: 'Choisissez un contact Korido ou saisissez un numéro complet.',
          ),
          colors.warning,
        );
      default:
        return _RecipientSnack(
          localizedSendCopy(
            context,
            en: 'We could not verify this Korido account. Please try again.',
            fr: 'Nous n’avons pas pu vérifier ce compte Korido. Veuillez réessayer.',
          ),
          colors.error,
        );
    }
  }
}

class _RecipientSnack {
  const _RecipientSnack(this.message, this.color);

  final String message;
  final Color color;
}
