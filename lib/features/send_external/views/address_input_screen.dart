import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/send_external/providers/external_transfer_provider.dart';

class AddressInputScreen extends ConsumerStatefulWidget {
  const AddressInputScreen({super.key});

  @override
  ConsumerState<AddressInputScreen> createState() => _AddressInputScreenState();
}

class _AddressInputScreenState extends ConsumerState<AddressInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Load balance
    Future.microtask(() {
      ref.read(externalTransferProvider.notifier).loadBalance();
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(externalTransferProvider);

    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        title: AppText(
          l10n.sendExternal_title,
          variant: AppTextVariant.headlineSmall,
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
                  padding: EdgeInsets.all(AppSpacing.lg),
                  children: [
                    // Info card
                    AppCard(
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: context.colors.gold,
                            size: 20,
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: AppText(
                              l10n.sendExternal_info,
                              variant: AppTextVariant.bodySmall,
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSpacing.xxl),

                    // Wallet address input
                    AppInput(
                      label: l10n.sendExternal_walletAddress,
                      controller: _addressController,
                      hint: l10n.sendExternal_addressHint,
                      keyboardType: TextInputType.text,
                      validator: _validateAddress,
                      onChanged: (_) => _validateAddressRealtime(),
                      maxLines: 2,
                      suffixIcon: state.hasValidAddress
                          ? Icons.check_circle
                          : null,
                    ),
                    SizedBox(height: AppSpacing.lg),

                    // Action buttons row
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: l10n.sendExternal_paste,
                            variant: AppButtonVariant.secondary,
                            size: AppButtonSize.small,
                            icon: Icons.content_paste,
                            onPressed: _pasteFromClipboard,
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: AppButton(
                            label: l10n.sendExternal_scanQr,
                            variant: AppButtonVariant.secondary,
                            size: AppButtonSize.small,
                            icon: Icons.qr_code_scanner,
                            onPressed: _scanQrCode,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.xxl),

                    // Supported networks info
                    AppText(
                      l10n.sendExternal_supportedNetworks,
                      variant: AppTextVariant.labelLarge,
                      color: context.colors.textSecondary,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    _buildNetworkInfoCard(
                      'Polygon (MATIC)',
                      l10n.sendExternal_polygonInfo,
                      Icons.flash_on,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    _buildNetworkInfoCard(
                      'Ethereum (ETH)',
                      l10n.sendExternal_ethereumInfo,
                      Icons.currency_bitcoin,
                    ),
                  ],
                ),
              ),

              // Error message
              if (state.error != null)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: context.colors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: context.colors.error,
                          size: 20,
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: AppText(
                            state.error!,
                            variant: AppTextVariant.bodySmall,
                            color: context.colors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Bottom button
              Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: AppButton(
                  label: l10n.action_continue,
                  onPressed: state.canProceedToAmount ? _handleContinue : null,
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

  Widget _buildNetworkInfoCard(String name, String info, IconData icon) {
    return AppCard(
      child: Row(
        children: [
          Icon(icon, color: context.colors.gold, size: 20),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  name,
                  variant: AppTextVariant.bodyMedium,
                  fontWeight: FontWeight.w600,
                ),
                AppText(
                  info,
                  variant: AppTextVariant.bodySmall,
                  color: context.colors.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.sendExternal_addressRequired;
    }
    final state = ref.read(externalTransferProvider);
    if (state.addressValidation?.isValid == false) {
      return state.addressValidation?.error;
    }
    return null;
  }

  void _validateAddressRealtime() {
    final address = _addressController.text;
    if (address.isNotEmpty) {
      ref.read(externalTransferProvider.notifier).setAddress(address);
    }
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      setState(() {
        _addressController.text = data!.text!;
      });
      _validateAddressRealtime();
    }
  }

  Future<void> _scanQrCode() async {
    final result = await context.push<String>('/qr/scan-address');
    if (result != null && mounted) {
      setState(() {
        _addressController.text = result;
      });
      ref.read(externalTransferProvider.notifier).setAddressFromQr(result);
    }
  }

  Future<void> _handleContinue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      // Address already validated via provider
      if (mounted) {
        context.push('/send-external/amount');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
