import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:usdc_wallet/features/deposit/models/deposit_response.dart';
import 'package:usdc_wallet/features/deposit/models/mobile_money_provider.dart';
import 'package:usdc_wallet/features/deposit/providers/deposit_provider.dart';

/// Payment Instructions Screen
///
/// Adapts UI based on payment method type:
/// - OTP: Shows instructions + OTP input field + confirm button
/// - PUSH: Shows instructions + "waiting for confirmation" with spinner
/// - QR_LINK: Shows QR code + deep link button + instructions
class PaymentInstructionsScreen extends ConsumerStatefulWidget {
  const PaymentInstructionsScreen({super.key});

  @override
  ConsumerState<PaymentInstructionsScreen> createState() =>
      _PaymentInstructionsScreenState();
}

class _PaymentInstructionsScreenState
    extends ConsumerState<PaymentInstructionsScreen> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(depositProvider);
    final response = state.response;

    if (response == null) {
      return const Scaffold(
        body: Center(child: Text('No deposit data')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => ref.read(depositProvider.notifier).goBack(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Amount display
              _buildAmountCard(state),
              const SizedBox(height: 24),

              // Instructions
              Text(
                response.instructions,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Type-specific content
              Expanded(
                child: _buildTypeSpecificContent(state, response),
              ),

              // Action button
              if (!state.isPushWaiting) _buildActionButton(state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountCard(DepositState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You pay',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  '${state.amountXOF.toStringAsFixed(0)} XOF',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Icon(Icons.arrow_forward, color: Colors.grey),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'You receive',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  '${state.amountUSD.toStringAsFixed(2)} USDC',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSpecificContent(
    DepositState state,
    DepositResponse response,
  ) {
    switch (response.paymentMethodType) {
      case PaymentMethodType.otp:
        return _buildOtpContent(state);
      case PaymentMethodType.push:
        return _buildPushContent(state);
      case PaymentMethodType.qrLink:
        return _buildQrLinkContent(state, response);
      case PaymentMethodType.card:
        return const Center(child: Text('Card payment coming soon'));
    }
  }

  /// OTP flow: USSD instruction + OTP input
  Widget _buildOtpContent(DepositState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.dialpad,
          size: 48,
          color: Colors.orange,
        ),
        const SizedBox(height: 16),
        Text(
          'Enter the OTP code you received',
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 8,
          style: const TextStyle(
            fontSize: 24,
            letterSpacing: 8,
            fontWeight: FontWeight.bold,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: '------',
            counterText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (value) {
            ref.read(depositProvider.notifier).setOtp(value);
          },
        ),
      ],
    );
  }

  /// PUSH flow: Waiting for user to approve on their phone
  Widget _buildPushContent(DepositState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 64,
          height: 64,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
        const SizedBox(height: 24),
        Text(
          'Waiting for your approval...',
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Check your phone and approve the payment\nusing your Mobile Money PIN',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        if (state.response?.expiresAt != null)
          _CountdownTimer(expiresAt: state.response!.expiresAt),
      ],
    );
  }

  /// QR/Link flow: Display QR code + open link button
  Widget _buildQrLinkContent(DepositState state, DepositResponse response) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // QR Code placeholder (would use qr_flutter package)
        if (response.qrCodeData != null)
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.qr_code, size: 80, color: Colors.blue),
                  const SizedBox(height: 8),
                  Text(
                    'Scan to pay',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 24),

        // Deep link button
        if (response.deepLinkUrl != null)
          ElevatedButton.icon(
            onPressed: () => _openDeepLink(response.deepLinkUrl as String),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open Wave'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),

        const SizedBox(height: 16),
        Text(
          'Or scan the QR code above',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Widget _buildActionButton(DepositState state) {
    final isOtp = state.response?.paymentMethodType == PaymentMethodType.otp;
    final canConfirm = !isOtp || (state.otpInput?.length ?? 0) >= 4;

    return ElevatedButton(
      onPressed: state.isLoading || !canConfirm
          ? null
          : () => ref.read(depositProvider.notifier).confirmDeposit(),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: state.isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(
              isOtp ? 'Submit OTP' : 'Confirm Payment',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }

  Future<void> _openDeepLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

/// Countdown timer widget for expiration
class _CountdownTimer extends StatefulWidget {
  final DateTime expiresAt;
  const _CountdownTimer({required this.expiresAt});

  @override
  State<_CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<_CountdownTimer> {
  late Timer _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.expiresAt.difference(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _remaining = widget.expiresAt.difference(DateTime.now());
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining.isNegative) {
      return Text(
        'Expired',
        style: TextStyle(color: Colors.red[400], fontWeight: FontWeight.bold),
      );
    }
    final minutes = _remaining.inMinutes;
    final seconds = _remaining.inSeconds % 60;
    return Text(
      'Expires in ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
      style: TextStyle(color: Colors.grey[600]),
    );
  }
}
