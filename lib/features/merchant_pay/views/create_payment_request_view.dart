import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/merchant_provider.dart';
import '../services/merchant_service.dart';

/// Create Payment Request View
/// Allows merchants to create dynamic QR codes with specific amounts
class CreatePaymentRequestView extends ConsumerStatefulWidget {
  final MerchantResponse merchant;

  const CreatePaymentRequestView({
    super.key,
    required this.merchant,
  });

  static const String routeName = '/create-payment-request';

  @override
  ConsumerState<CreatePaymentRequestView> createState() =>
      _CreatePaymentRequestViewState();
}

class _CreatePaymentRequestViewState
    extends ConsumerState<CreatePaymentRequestView> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _referenceController = TextEditingController();
  Timer? _expirationTimer;
  int _remainingSeconds = 0;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _referenceController.dispose();
    _expirationTimer?.cancel();
    super.dispose();
  }

  double? get _amount => double.tryParse(_amountController.text);

  bool get _canCreate {
    final amount = _amount;
    return amount != null && amount > 0 && amount <= 10000;
  }

  void _createPaymentRequest() async {
    final amount = _amount;
    if (amount == null) return;

    final notifier = ref.read(paymentRequestProvider.notifier);
    final success = await notifier.createPaymentRequest(
      merchantId: widget.merchant.merchantId,
      amount: amount,
      description: _descriptionController.text.isNotEmpty
          ? _descriptionController.text
          : null,
      reference: _referenceController.text.isNotEmpty
          ? _referenceController.text
          : null,
    );

    if (success && mounted) {
      final state = ref.read(paymentRequestProvider);
      if (state.paymentRequest != null) {
        _startExpirationTimer(state.paymentRequest!.expiresInSeconds);
      }
    }
  }

  void _startExpirationTimer(int seconds) {
    _remainingSeconds = seconds;
    _expirationTimer?.cancel();
    _expirationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _remainingSeconds--;
          if (_remainingSeconds <= 0) {
            timer.cancel();
            ref.read(paymentRequestProvider.notifier).reset();
          }
        });
      }
    });
  }

  String _formatTimeRemaining() {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _shareQr() {
    final state = ref.read(paymentRequestProvider);
    if (state.paymentRequest == null) return;

    final pr = state.paymentRequest!;
    final text = '''
Payment Request from ${widget.merchant.displayName}

Amount: \$${pr.amount.toStringAsFixed(2)} USDC
${pr.description != null ? 'Description: ${pr.description}\n' : ''}
Scan the QR code or use this link to pay.

Powered by JoonaPay
''';
    Share.share(text);
  }

  void _newRequest() {
    _expirationTimer?.cancel();
    ref.read(paymentRequestProvider.notifier).reset();
    _amountController.clear();
    _descriptionController.clear();
    _referenceController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentRequestProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Payment'),
        actions: [
          if (state.paymentRequest != null)
            IconButton(
              onPressed: _newRequest,
              icon: const Icon(Icons.refresh),
              tooltip: 'New Request',
            ),
        ],
      ),
      body: SafeArea(
        child: state.paymentRequest != null
            ? _buildQrDisplay(context, state.paymentRequest!)
            : _buildRequestForm(context, state),
      ),
    );
  }

  Widget _buildRequestForm(BuildContext context, PaymentRequestState state) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Merchant info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.store,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.merchant.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Creating payment request',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Amount input
          const Text(
            'Amount (USDC)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              prefixText: '\$ ',
              prefixStyle: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
              hintText: '0.00',
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: theme.primaryColor, width: 2),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 24),

          // Description input
          const Text(
            'Description (optional)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descriptionController,
            maxLines: 2,
            maxLength: 200,
            decoration: InputDecoration(
              hintText: 'e.g., Coffee and croissant',
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Reference input
          const Text(
            'Reference (optional)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _referenceController,
            maxLength: 50,
            decoration: InputDecoration(
              hintText: 'e.g., Order #123',
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Error message
          if (state.error != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.error!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Create button
          ElevatedButton(
            onPressed: _canCreate && !state.isLoading
                ? _createPaymentRequest
                : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: state.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : const Text(
                    'Generate QR Code',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrDisplay(BuildContext context, PaymentRequestResponse pr) {
    final theme = Theme.of(context);
    final isExpired = _remainingSeconds <= 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // QR Code Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // Amount
                Text(
                  '\$${pr.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                Text(
                  'USDC',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                if (pr.description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    pr.description!,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 24),

                // QR Code
                if (!isExpired)
                  QrImageView(
                    data: pr.qrData,
                    version: QrVersions.auto,
                    size: 200,
                    backgroundColor: Colors.white,
                  )
                else
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.timer_off,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Request Expired',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),

                // Timer
                if (!isExpired)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _remainingSeconds < 60
                          ? Colors.red.shade50
                          : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer,
                          size: 18,
                          color: _remainingSeconds < 60
                              ? Colors.red.shade700
                              : Colors.green.shade700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Expires in ${_formatTimeRemaining()}',
                          style: TextStyle(
                            color: _remainingSeconds < 60
                                ? Colors.red.shade700
                                : Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action buttons
          if (!isExpired)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _shareQr,
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _newRequest,
                    icon: const Icon(Icons.add),
                    label: const Text('New Request'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            )
          else
            ElevatedButton.icon(
              onPressed: _newRequest,
              icon: const Icon(Icons.refresh),
              label: const Text('Create New Request'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),

          const SizedBox(height: 24),

          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Show this QR code to your customer. The payment will be credited automatically.',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
