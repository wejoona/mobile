import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../design/components/composed/index.dart';
import '../../../services/index.dart';
import '../../../services/contacts/contacts_service.dart';
import '../../../state/index.dart';
import '../providers/wallet_provider.dart';

class SendView extends ConsumerStatefulWidget {
  const SendView({super.key});

  @override
  ConsumerState<SendView> createState() => _SendViewState();
}

class _SendViewState extends ConsumerState<SendView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _amountController = TextEditingController();
  String _countryCode = '+225';

  // Selected contact
  AppContact? _selectedContact;

  // Validation
  String? _amountError;
  String? _addressError;
  double _availableBalance = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transferState = ref.watch(transferProvider);
    final walletState = ref.watch(walletStateMachineProvider);
    final recentContactsAsync = ref.watch(recentContactsProvider);

    // Update available balance from FSM
    _availableBalance = walletState.availableBalance;

    ref.listen(transferProvider, (prev, next) {
      if (next.response != null) {
        // Add to recent contacts
        if (_selectedContact != null) {
          ref.read(contactsServiceProvider).addToRecent(_selectedContact!);
        } else if (_phoneController.text.isNotEmpty) {
          ref.read(contactsServiceProvider).addToRecent(AppContact(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: '$_countryCode${_phoneController.text}',
            phone: '$_countryCode${_phoneController.text}',
          ));
        }

        // Refresh wallet and transactions via FSM
        ref.read(walletStateMachineProvider.notifier).refresh();
        ref.read(transactionStateMachineProvider.notifier).refresh();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transfer successful!'),
            backgroundColor: AppColors.successBase,
          ),
        );
        context.pop();
      } else if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.errorBase,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const AppText(
          'Send Money',
          variant: AppTextVariant.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gold500,
          labelColor: AppColors.gold500,
          unselectedLabelColor: AppColors.textTertiary,
          tabs: const [
            Tab(text: 'To Phone'),
            Tab(text: 'To Wallet'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Internal Transfer (Phone)
          _buildInternalTransfer(walletState, transferState, recentContactsAsync),
          // External Transfer (Wallet Address)
          _buildExternalTransfer(walletState, transferState),
        ],
      ),
    );
  }

  Widget _buildInternalTransfer(
    WalletState walletState,
    TransferState transferState,
    AsyncValue<List<AppContact>> recentContactsAsync,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Available Balance from FSM
          AppCard(
            variant: AppCardVariant.subtle,
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppText(
                  'Available Balance',
                  variant: AppTextVariant.bodyMedium,
                  color: AppColors.textSecondary,
                ),
                walletState.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.gold500,
                        ),
                      )
                    : AppText(
                        '\$${walletState.availableBalance.toStringAsFixed(2)}',
                        variant: AppTextVariant.titleMedium,
                        color: AppColors.gold500,
                      ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Recent Contacts
          recentContactsAsync.when(
            data: (contacts) => contacts.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText(
                        'Recent',
                        variant: AppTextVariant.labelMedium,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        height: 90,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: contacts.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: AppSpacing.md),
                          itemBuilder: (context, index) {
                            final contact = contacts[index];
                            return _RecentContactChip(
                              contact: contact,
                              isSelected: _selectedContact?.phone == contact.phone,
                              onTap: () => _selectContact(contact),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  )
                : const SizedBox(),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),

          // Recipient Section
          Row(
            children: [
              const Expanded(
                child: AppText(
                  'Recipient',
                  variant: AppTextVariant.labelMedium,
                  color: AppColors.textSecondary,
                ),
              ),
              // Open Contacts Button
              TextButton.icon(
                onPressed: _openContacts,
                icon: const Icon(Icons.contacts, size: 18, color: AppColors.gold500),
                label: const AppText(
                  'Contacts',
                  variant: AppTextVariant.labelMedium,
                  color: AppColors.gold500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Selected contact or phone input
          if (_selectedContact != null)
            _SelectedContactCard(
              contact: _selectedContact!,
              onClear: () {
                setState(() {
                  _selectedContact = null;
                  _phoneController.clear();
                });
              },
            )
          else
            PhoneInput(
              controller: _phoneController,
              countryCode: _countryCode,
              label: 'Phone Number',
              onCountryCodeTap: () => _showCountryPicker(),
              onChanged: (value) => setState(() {}),
            ),

          const SizedBox(height: AppSpacing.xxl),

          // Amount
          const AppText(
            'Amount (USD)',
            variant: AppTextVariant.labelMedium,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.sm),
          _AmountInput(
            controller: _amountController,
            error: _amountError,
            onChanged: (_) => _validateAmount(),
          ),

          // Quick amounts
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _QuickAmountChip(amount: 5, onTap: () => _setAmount(5)),
              const SizedBox(width: AppSpacing.sm),
              _QuickAmountChip(amount: 10, onTap: () => _setAmount(10)),
              const SizedBox(width: AppSpacing.sm),
              _QuickAmountChip(amount: 25, onTap: () => _setAmount(25)),
              const SizedBox(width: AppSpacing.sm),
              _QuickAmountChip(amount: 50, onTap: () => _setAmount(50)),
              const SizedBox(width: AppSpacing.sm),
              _QuickAmountChip(
                label: 'MAX',
                onTap: () => _setAmount(_availableBalance),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xxxl),

          // Send Button
          AppButton(
            label: 'Send',
            onPressed: _canSendInternal() ? () => _sendInternal() : null,
            variant: AppButtonVariant.primary,
            isFullWidth: true,
            isLoading: transferState.isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildExternalTransfer(
    WalletState walletState,
    TransferState transferState,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Available Balance from FSM
          AppCard(
            variant: AppCardVariant.subtle,
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppText(
                  'Available Balance',
                  variant: AppTextVariant.bodyMedium,
                  color: AppColors.textSecondary,
                ),
                walletState.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.gold500,
                        ),
                      )
                    : AppText(
                        '\$${walletState.availableBalance.toStringAsFixed(2)}',
                        variant: AppTextVariant.titleMedium,
                        color: AppColors.gold500,
                      ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Wallet Address
          Row(
            children: [
              const Expanded(
                child: AppText(
                  'Wallet Address',
                  variant: AppTextVariant.labelMedium,
                  color: AppColors.textSecondary,
                ),
              ),
              // Scan QR Button
              TextButton.icon(
                onPressed: () => context.push('/scan'),
                icon: const Icon(Icons.qr_code_scanner, size: 18, color: AppColors.gold500),
                label: const AppText(
                  'Scan',
                  variant: AppTextVariant.labelMedium,
                  color: AppColors.gold500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppInput(
                controller: _addressController,
                hint: '0x...',
                prefixIcon: Icons.account_balance_wallet,
                onChanged: (_) => _validateAddress(),
              ),
              if (_addressError != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs, left: AppSpacing.sm),
                  child: AppText(
                    _addressError!,
                    variant: AppTextVariant.bodySmall,
                    color: AppColors.errorBase,
                  ),
                ),
            ],
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Amount
          const AppText(
            'Amount (USD)',
            variant: AppTextVariant.labelMedium,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.sm),
          _AmountInput(
            controller: _amountController,
            error: _amountError,
            onChanged: (_) => _validateAmount(),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Network info
          AppCard(
            variant: AppCardVariant.subtle,
            padding: const EdgeInsets.all(AppSpacing.md),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.warningBase,
                  size: 20,
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppText(
                    'External transfers are on the Polygon network. Network fees apply.',
                    variant: AppTextVariant.bodySmall,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xxxl),

          // Send Button
          AppButton(
            label: 'Send',
            onPressed: _canSendExternal() ? () => _sendExternal() : null,
            variant: AppButtonVariant.primary,
            isFullWidth: true,
            isLoading: transferState.isLoading,
          ),
        ],
      ),
    );
  }

  void _selectContact(AppContact contact) {
    setState(() {
      _selectedContact = contact;
      // Extract phone without country code if present
      final phone = contact.phone;
      if (phone.startsWith('+')) {
        final parts = phone.split(RegExp(r'(?<=^\+\d{3})'));
        if (parts.length > 1) {
          _phoneController.text = parts[1];
        } else {
          _phoneController.text = phone.substring(4);
        }
      } else {
        _phoneController.text = phone;
      }
    });
  }

  Future<void> _openContacts() async {
    final contacts = await ref.read(contactsServiceProvider).getDeviceContacts();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.slate,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _ContactsSheet(
          contacts: contacts,
          scrollController: scrollController,
          onContactSelected: (contact) {
            final appContact = ref
                .read(contactsServiceProvider)
                .deviceToAppContact(contact);
            _selectContact(appContact);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _showCountryPicker() {
    final countries = [
      ('+225', 'Ivory Coast', 'CI'),
      ('+234', 'Nigeria', 'NG'),
      ('+254', 'Kenya', 'KE'),
      ('+233', 'Ghana', 'GH'),
      ('+221', 'Senegal', 'SN'),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.slate,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.lg),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          const AppText(
            'Select Country',
            variant: AppTextVariant.titleMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          ...countries.map((c) => ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.elevated,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Center(
                    child: AppText(
                      c.$3,
                      variant: AppTextVariant.labelMedium,
                      color: AppColors.gold500,
                    ),
                  ),
                ),
                title: AppText(c.$2, variant: AppTextVariant.bodyLarge),
                trailing: AppText(
                  c.$1,
                  variant: AppTextVariant.bodyMedium,
                  color: AppColors.textTertiary,
                ),
                onTap: () {
                  setState(() {
                    _countryCode = c.$1;
                  });
                  Navigator.pop(context);
                },
              )),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  void _validateAmount() {
    final amount = double.tryParse(_amountController.text) ?? 0;

    setState(() {
      if (_amountController.text.isEmpty) {
        _amountError = null;
      } else if (amount <= 0) {
        _amountError = 'Enter a valid amount';
      } else if (amount > _availableBalance) {
        _amountError = 'Insufficient balance';
      } else {
        _amountError = null;
      }
    });
  }

  void _validateAddress() {
    final address = _addressController.text;

    setState(() {
      if (address.isEmpty) {
        _addressError = null;
      } else if (!address.startsWith('0x')) {
        _addressError = 'Address must start with 0x';
      } else if (address.length != 42) {
        _addressError = 'Address must be exactly 42 characters';
      } else if (!_isValidEthereumAddress(address)) {
        _addressError = 'Invalid Ethereum address format';
      } else {
        _addressError = null;
      }
    });
  }

  void _setAmount(double amount) {
    _amountController.text = amount.toStringAsFixed(2);
    _validateAmount();
  }

  bool _canSendInternal() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final phoneNumber = _phoneController.text.replaceAll(RegExp(r'\s+'), '');
    final hasRecipient = _selectedContact != null || _isValidPhoneNumber(phoneNumber);
    return amount > 0 && amount <= _availableBalance && hasRecipient && _amountError == null;
  }

  /// Validate phone number format (9-15 digits)
  /// SECURITY: International phone number validation
  bool _isValidPhoneNumber(String phoneNumber) {
    final phoneRegex = RegExp(r'^\d{9,15}$');
    return phoneRegex.hasMatch(phoneNumber);
  }

  bool _canSendExternal() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    return amount > 0 &&
           amount <= _availableBalance &&
           _isValidEthereumAddress(_addressController.text) &&
           _amountError == null;
  }

  /// Validate Ethereum address format
  /// SECURITY: Check for valid Ethereum address format (0x + 40 hex chars = 42 total)
  bool _isValidEthereumAddress(String address) {
    // Must start with 0x and be exactly 42 characters
    if (!address.startsWith('0x') || address.length != 42) {
      return false;
    }

    // Check if remaining 40 characters are valid hexadecimal
    final hexPart = address.substring(2);
    final hexRegex = RegExp(r'^[0-9a-fA-F]{40}$');
    return hexRegex.hasMatch(hexPart);
  }

  Future<void> _sendInternal() async {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final phone = _selectedContact?.phone ?? '$_countryCode${_phoneController.text}';
    final recipientName = _selectedContact?.name ?? phone;

    // Show PIN confirmation - SECURITY: Verify PIN with backend for financial transactions
    final result = await PinConfirmationSheet.show(
      context: context,
      title: 'Confirm Transfer',
      subtitle: 'Enter your PIN to send money',
      amount: amount,
      recipient: recipientName,
      onConfirm: (pin) async {
        // SECURITY: Verify PIN with backend before authorizing transfer
        final pinService = ref.read(pinServiceProvider);
        final verification = await pinService.verifyPinWithBackend(pin);
        return verification.success;
      },
    );

    if (result == PinConfirmationResult.success) {
      ref.read(transferProvider.notifier).internalTransfer(
            toPhone: phone,
            amount: amount,
            currency: 'USD',
          );
    } else if (result == PinConfirmationResult.failed) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Too many incorrect attempts. Please try again later.'),
            backgroundColor: AppColors.errorBase,
          ),
        );
      }
    }
  }

  Future<void> _sendExternal() async {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final address = _addressController.text;
    final shortAddress = '${address.substring(0, 6)}...${address.substring(address.length - 4)}';

    // Show PIN confirmation - SECURITY: Verify PIN with backend for financial transactions
    final result = await PinConfirmationSheet.show(
      context: context,
      title: 'Confirm Transfer',
      subtitle: 'Enter your PIN to send to external wallet',
      amount: amount,
      recipient: shortAddress,
      onConfirm: (pin) async {
        // SECURITY: Verify PIN with backend before authorizing transfer
        final pinService = ref.read(pinServiceProvider);
        final verification = await pinService.verifyPinWithBackend(pin);
        return verification.success;
      },
    );

    if (result == PinConfirmationResult.success) {
      ref.read(transferProvider.notifier).externalTransfer(
            toAddress: address,
            amount: amount,
            currency: 'USD',
            network: 'MATIC',
          );
    } else if (result == PinConfirmationResult.failed) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Too many incorrect attempts. Please try again later.'),
            backgroundColor: AppColors.errorBase,
          ),
        );
      }
    }
  }
}

class _RecentContactChip extends StatelessWidget {
  const _RecentContactChip({
    required this.contact,
    required this.isSelected,
    required this.onTap,
  });

  final AppContact contact;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.gold500 : AppColors.elevated,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.gold500 : AppColors.borderSubtle,
                width: 2,
              ),
            ),
            child: Center(
              child: contact.hasApp
                  ? const Icon(Icons.check_circle, color: AppColors.successBase, size: 20)
                  : AppText(
                      _getInitials(contact.name),
                      variant: AppTextVariant.titleMedium,
                      color: isSelected ? AppColors.obsidian : AppColors.textPrimary,
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          SizedBox(
            width: 60,
            child: AppText(
              _getShortName(contact.name),
              variant: AppTextVariant.bodySmall,
              color: AppColors.textSecondary,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  String _getShortName(String name) {
    final parts = name.split(' ');
    return parts.first;
  }
}

class _SelectedContactCard extends StatelessWidget {
  const _SelectedContactCard({
    required this.contact,
    required this.onClear,
  });

  final AppContact contact;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.slate,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.gold500),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.gold500.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: AppText(
                _getInitials(contact.name),
                variant: AppTextVariant.titleMedium,
                color: AppColors.gold500,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  contact.name,
                  variant: AppTextVariant.bodyLarge,
                  color: AppColors.textPrimary,
                ),
                Row(
                  children: [
                    AppText(
                      contact.phone,
                      variant: AppTextVariant.bodySmall,
                      color: AppColors.textTertiary,
                    ),
                    if (contact.hasApp) ...[
                      const SizedBox(width: AppSpacing.xs),
                      const Icon(Icons.verified, color: AppColors.gold500, size: 14),
                      const SizedBox(width: 2),
                      const AppText(
                        'JoonaPay user',
                        variant: AppTextVariant.bodySmall,
                        color: AppColors.gold500,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onClear,
            icon: const Icon(Icons.close, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }
}

class _AmountInput extends StatelessWidget {
  const _AmountInput({
    required this.controller,
    required this.error,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String? error;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.slate,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: error != null ? AppColors.errorBase : AppColors.borderSubtle,
            ),
          ),
          child: Row(
            children: [
              const AppText(
                '\$',
                variant: AppTextVariant.headlineMedium,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  style: AppTypography.headlineMedium,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '0.00',
                    hintStyle: TextStyle(color: AppColors.textTertiary),
                  ),
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs, left: AppSpacing.sm),
            child: AppText(
              error!,
              variant: AppTextVariant.bodySmall,
              color: AppColors.errorBase,
            ),
          ),
      ],
    );
  }
}

class _QuickAmountChip extends StatelessWidget {
  const _QuickAmountChip({
    this.amount,
    this.label,
    required this.onTap,
  });

  final double? amount;
  final String? label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.elevated,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Center(
            child: AppText(
              label ?? '\$${amount?.toStringAsFixed(0)}',
              variant: AppTextVariant.labelSmall,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactsSheet extends StatefulWidget {
  const _ContactsSheet({
    required this.contacts,
    required this.scrollController,
    required this.onContactSelected,
  });

  final List<Contact> contacts;
  final ScrollController scrollController;
  final ValueChanged<Contact> onContactSelected;

  @override
  State<_ContactsSheet> createState() => _ContactsSheetState();
}

class _ContactsSheetState extends State<_ContactsSheet> {
  String _searchQuery = '';

  List<Contact> get _filteredContacts {
    if (_searchQuery.isEmpty) return widget.contacts;

    return widget.contacts.where((c) {
      final name = c.displayName.toLowerCase();
      final phone = c.phones.isNotEmpty ? c.phones.first.number : '';
      return name.contains(_searchQuery.toLowerCase()) ||
          phone.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.lg),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.textTertiary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        const AppText(
          'Select Contact',
          variant: AppTextVariant.titleMedium,
        ),
        const SizedBox(height: AppSpacing.lg),

        // Search
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search contacts...',
              hintStyle: const TextStyle(color: AppColors.textTertiary),
              prefixIcon: const Icon(Icons.search, color: AppColors.textTertiary),
              filled: true,
              fillColor: AppColors.elevated,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Contacts list
        Expanded(
          child: ListView.builder(
            controller: widget.scrollController,
            itemCount: _filteredContacts.length,
            itemBuilder: (context, index) {
              final contact = _filteredContacts[index];
              final phone = contact.phones.isNotEmpty
                  ? contact.phones.first.number
                  : 'No phone';

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.elevated,
                  child: Text(
                    contact.displayName.isNotEmpty
                        ? contact.displayName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                ),
                title: AppText(
                  contact.displayName,
                  variant: AppTextVariant.bodyLarge,
                ),
                subtitle: AppText(
                  phone,
                  variant: AppTextVariant.bodySmall,
                  color: AppColors.textTertiary,
                ),
                onTap: () => widget.onContactSelected(contact),
              );
            },
          ),
        ),
      ],
    );
  }
}
